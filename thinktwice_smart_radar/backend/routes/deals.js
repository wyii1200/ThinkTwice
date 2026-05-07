const express = require("express");
const router = express.Router();
const { db, bucket } = require("../firebase");
const { getInitialTrustScore, upvoteDeal, downvoteDeal, isDealVisible, isDealVerified, TRUST_VERIFIED_THRESHOLD } = require("../services/trustScore");
const { recordSavingsProof } = require("../services/savingsCalc");
const axios = require("axios");
 
// ─── GET /deals ───────────────────────────────────────────────────────────────
// Query params: lat, lng, radius (meters), category, verified (true/false)
router.get("/", async (req, res) => {
  try {
    const { lat, lng, radius = 3000, category, verified } = req.query;
 
    let query = db.collection("deals").where("hidden", "!=", true);
 
    if (category) {
      query = query.where("category", "==", category);
    }
 
    if (verified === "true") {
      query = query.where("verified", "==", true);
    }
 
    const snapshot = await query.orderBy("trustScore", "desc").limit(50).get();
 
    let deals = snapshot.docs.map((doc) => doc.data());
 
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
    const { title, storeName, category, price, lat, lng, address, imageBase64, submittedBy } = req.body;
 
    if (!title || !storeName || !category || !price || !lat || !lng || !submittedBy) {
      return res.status(400).json({ success: false, error: "Missing required fields: title, storeName, category, price, lat, lng, submittedBy" });
    }
 
    let imageUrl = null;
 
    // Upload image to Firebase Storage if provided
    if (imageBase64) {
      const buffer = Buffer.from(imageBase64, "base64");
      const filename = `deals/${Date.now()}_${submittedBy}.jpg`;
      const file = bucket.file(filename);
 
      await file.save(buffer, { metadata: { contentType: "image/jpeg" } });
      await file.makePublic();
      imageUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;
    }
 
    const dealRef = db.collection("deals").doc();
    const now = new Date().toISOString();
 
    const dealData = {
      dealId: dealRef.id,
      title,
      storeName,
      category,
      price: parseFloat(price),
      location: { _latitude: parseFloat(lat), _longitude: parseFloat(lng) },
      address: address || "",
      imageUrl,
      submittedBy,
      trustScore: getInitialTrustScore(),
      upvotes: 0,
      downvotes: 0,
      verified: false,
      hidden: false,
      createdAt: now,
      expiresAt: null,
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
 
    const result = await upvoteDeal(req.params.id);
 
    // If deal just became verified, reward the contributor
    if (result.verified) {
      const deal = (await db.collection("deals").doc(req.params.id).get()).data();
      await notifyGamificationService(deal.submittedBy, 10, "deal_verified");
    }
 
    res.json({ success: true, ...result });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
 
// ─── POST /deals/:id/downvote ─────────────────────────────────────────────────
// Body: { userId }
router.post("/:id/downvote", async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).json({ success: false, error: "userId required" });
 
    const result = await downvoteDeal(req.params.id);
    res.json({ success: true, ...result });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
 
// ─── POST /deals/use ──────────────────────────────────────────────────────────
// Called when user confirms they used a deal — records savings proof
// Body: { userId, dealId, amountSaved, category }
router.post("/use", async (req, res) => {
  try {
    const { userId, dealId, amountSaved, category } = req.body;
    if (!userId || !dealId || !amountSaved) {
      return res.status(400).json({ success: false, error: "userId, dealId, amountSaved required" });
    }
 
    const proofId = await recordSavingsProof(db, userId, {
      type: "deal_used",
      amountSaved: parseFloat(amountSaved),
      category: category || "general",
      dealId,
    });
 
    res.json({ success: true, proofId });
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