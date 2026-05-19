const express = require("express");
const router = express.Router();
const { db, bucket } = require("../firebase");
const { getInitialTrustScore, upvoteDeal, downvoteDeal, isDealVisible, isDealVerified, TRUST_VERIFIED_THRESHOLD } = require("../services/trustScore");
const axios = require("axios");

// ─── GET /deals ───────────────────────────────────────────────────────────────
// Query params: lat, lng, radius (meters), category, verified (true/false)
router.get("/", async (req, res) => {
  try {
    const { lat, lng, radius = 3000, category, verified } = req.query;

    // Fetch all then filter in memory — avoids composite index requirement
    const snapshot = await db.collection("deals").limit(100).get();

    let deals = snapshot.docs
      .map((doc) => doc.data())
      .filter((deal) => deal.hidden !== true)
      .filter((deal) => !deal.expiresAt || new Date(deal.expiresAt) > new Date())
      .filter((deal) => !category || deal.category === category)
      .filter((deal) => verified !== "true" || deal.verified === true)
      .sort((a, b) => (b.trustScore || 0) - (a.trustScore || 0))
      .slice(0, 50);

    // If lat/lng provided, filter by radius (simple bounding box)
    if (lat && lng) {
      const userLat = parseFloat(lat);
      const userLng = parseFloat(lng);
      const radiusKm = parseFloat(radius) / 1000;

      deals = deals.filter((deal) => {
        if (!deal.location) return false;
        const dLat = Math.abs(deal.location._latitude - userLat);
        const dLng = Math.abs(deal.location._longitude - userLng);
        // Rough degree-to-km: 1 degree ≈ 111 km
        return Math.sqrt(dLat * dLat + dLng * dLng) * 111 <= radiusKm;
      });
    }

    res.json({ success: true, count: deals.length, deals });
  } catch (err) {
    console.error("GET /deals error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── GET /deals/:id ───────────────────────────────────────────────────────────
router.get("/:id", async (req, res) => {
  try {
    const doc = await db.collection("deals").doc(req.params.id).get();
    if (!doc.exists) return res.status(404).json({ success: false, error: "Deal not found" });
    res.json({ success: true, deal: doc.data() });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /deals ──────────────────────────────────────────────────────────────
// Body: { title, storeName, category, price, lat, lng, address, imageBase64, submittedBy }
router.post("/", async (req, res) => {
  try {
    const { title, storeName, category, price, originalPrice , lat, lng, address, imageBase64, submittedBy,description } = req.body;

    if (!title || !storeName || !category || !price || !lat || !lng || !submittedBy) {
      return res.status(400).json({ success: false, error: "Missing required fields: title, storeName, category, price, lat, lng, submittedBy" });
    }

    let imageUrl = null;

    // Upload image to Firebase Storage if provided
    // Skipped if bucket not configured yet (waiting for Person 1's Firebase setup)
    if (imageBase64 && bucket) {
      const buffer = Buffer.from(imageBase64, "base64");
      const filename = `deals/${Date.now()}_${submittedBy}.jpg`;
      const file = bucket.file(filename);

      await file.save(buffer, { metadata: { contentType: "image/jpeg" } });
      await file.makePublic();
      imageUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(filename)}?alt=media`;
    } else if (imageBase64 && !bucket) {
      console.warn("Image upload skipped — FIREBASE_STORAGE_BUCKET not configured yet");
    }

    const dealRef = db.collection("deals").doc();
    const now = new Date();
    const expiresAt = new Date(now);
    expiresAt.setDate(expiresAt.getDate() + 7); // deals expire after 7 days

    const dealData = {
      dealId: dealRef.id,
      title,
      storeName,
      category,
      price: parseFloat(price),
      originalPrice: originalPrice ? parseFloat(originalPrice) : parseFloat(price) * 1.2, // Fallback for safety
      location: { _latitude: parseFloat(lat), _longitude: parseFloat(lng) },
      address: address || "",
      imageUrl,
      submittedBy,
      trustScore: getInitialTrustScore(),
      upvotes: 0,
      downvotes: 0,
      verified: false,
      hidden: false,
      createdAt: now.toISOString(),
      expiresAt: expiresAt.toISOString(),
      description: description || "",
    };

    await dealRef.set(dealData);
    res.status(201).json({ success: true, dealId: dealRef.id, deal: dealData });
  } catch (err) {
    console.error("POST /deals error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /deals/:id/upvote ───────────────────────────────────────────────────
// Body: { userId }
router.post("/:id/upvote", async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ success: false, error: "userId required" });

    const result = await upvoteDeal(req.params.id, userId);

    // If deal just became verified, reward the contributor
    if (result.verified) {
      const deal = (await db.collection("deals").doc(req.params.id).get()).data();
      await notifyGamificationService(deal.submittedBy, 10, "deal_verified");
    }

    res.json({ success: true, ...result });
  } catch (err) {
    const status = err.message.includes("Already") || err.message.includes("Switch") ? 409 : 500;
    res.status(status).json({ success: false, error: err.message });
  }
});

// ─── POST /deals/:id/downvote ─────────────────────────────────────────────────
// Body: { userId }
router.post("/:id/downvote", async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ success: false, error: "userId required" });

    const result = await downvoteDeal(req.params.id, userId);
    const msg = result.switched ? "Switched from upvote to downvote" : "Downvoted";
    res.json({ success: true, message: msg, ...result });
  } catch (err) {
    const isVoteConflict = err.message.includes("Already") || err.message.includes("Cannot downvote");
    res.status(isVoteConflict ? 409 : 500).json({ success: false, error: err.message });
  }
});

// ─── POST /deals/use ──────────────────────────────────────────────────────────
// Called when user confirms they used a deal — records savings proof
// Body: { userId, dealId, amountSaved, category }
router.post("/use", async (req, res) => {
  try {
    const { userId, dealId, amountSaved, category, dealTitle } = req.body;
    if (!userId || !dealId || !amountSaved) {
      return res.status(400).json({ success: false, error: "userId, dealId, amountSaved required" });
    }

    const dealRef = db.collection("deals").doc(dealId);
    const safeClaimId = `${encodeURIComponent(userId)}_${encodeURIComponent(dealId)}`;
    const claimRef = db.collection("deal_claims").doc(safeClaimId);
    const proofRef = db.collection("savings_proof").doc();
    const now = new Date();
    const month = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

    await db.runTransaction(async (tx) => {
      const [dealDoc, claimDoc] = await Promise.all([
        tx.get(dealRef),
        tx.get(claimRef),
      ]);

      if (!dealDoc.exists) {
        const err = new Error("Deal not found");
        err.statusCode = 404;
        throw err;
      }

      if (claimDoc.exists) {
        const err = new Error("You already claimed this deal.");
        err.statusCode = 409;
        throw err;
      }

      tx.set(claimRef, {
        claimId: safeClaimId,
        userId,
        dealId,
        proofId: proofRef.id,
        claimedAt: now.toISOString(),
      });

      tx.set(proofRef, {
        proofId: proofRef.id,
        userId,
        type: "deal_used",
        amountSaved: parseFloat(amountSaved),
        category: category || "general",
        dealId,
        routeId: null,
        month,
        createdAt: now.toISOString(),
        dealTitle: dealTitle || "Community Deal",
      });
    });

    res.json({ success: true, proofId: proofRef.id });
  } catch (err) {
    res.status(err.statusCode || 500).json({ success: false, error: err.message });
  }
});

// ─── DELETE /deals/:id ───────────────────────────────────────────────────────
// Only the submitter can delete their own deal
// Body: { userId }
router.delete("/:id", async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ success: false, error: "userId required" });

    const ref = db.collection("deals").doc(req.params.id);
    const doc = await ref.get();

    if (!doc.exists) return res.status(404).json({ success: false, error: "Deal not found" });
    if (doc.data().submittedBy !== userId) {
      return res.status(403).json({ success: false, error: "You can only delete your own deals" });
    }

    await ref.delete();
    res.json({ success: true, message: "Deal deleted" });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── PATCH /deals/:id ─────────────────────────────────────────────────────────
// Only the submitter can edit their own deal
// Body: { userId, title?, price?, description? }
router.patch("/:id", async (req, res) => {
  try {
    // 1. Add originalPrice to the destructured body
    const { userId, title, price, originalPrice, description } = req.body;
    
    if (!userId) return res.status(400).json({ success: false, error: "userId required" });

    const ref = db.collection("deals").doc(req.params.id);
    const doc = await ref.get();

    if (!doc.exists) return res.status(404).json({ success: false, error: "Deal not found" });
    if (doc.data().submittedBy !== userId) {
      return res.status(403).json({ success: false, error: "You can only edit your own deals" });
    }

    const updates = { updatedAt: new Date().toISOString() };
    if (title) updates.title = title;
    if (price != null) updates.price = parseFloat(price);
    if (description !== undefined) updates.description = description;
    
    // 2. Add the originalPrice update logic
    if (originalPrice != null) updates.originalPrice = parseFloat(originalPrice);

    await ref.update(updates);
    const updated = (await ref.get()).data();
    res.json({ success: true, deal: updated });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /deals/:id/reset-votes ─────────────────────────────────────────────
// DEV ONLY: clears voter history on a deal so you can re-test voting fresh
// Remove this endpoint before production
router.post("/:id/reset-votes", async (req, res) => {
  try {
    await db.collection("deals").doc(req.params.id).update({
      voters: {},
      upvotes: 0,
      downvotes: 0,
      trustScore: 50,
      verified: false,
      hidden: false,
    });
    res.json({ success: true, message: "Votes reset for deal " + req.params.id });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Helper: tell Person 1's gamification endpoint to award points
async function notifyGamificationService(userId, points, reason) {
  const GAMIFICATION_URL = process.env.GAMIFICATION_SERVICE_URL;
  if (!GAMIFICATION_URL) return; // skip if not configured yet

  try {
    await axios.post(`${GAMIFICATION_URL}/award-points`, { userId, points, reason });
  } catch (err) {
    console.warn("Gamification service unreachable:", err.message);
    // Non-fatal — don't crash if Person 1's service is down
  }
}

module.exports = router;
