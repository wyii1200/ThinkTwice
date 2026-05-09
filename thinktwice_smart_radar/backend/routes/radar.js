const express = require("express");
const router = express.Router();
const { db, bucket } = require("../firebase");
const { getNearbyPlaces, getOptimizedRoute, getDistanceMatrix } = require("../services/mapsService");
const { calculateNetSavings, aggregateMonthlySavings, recordSavingsProof } = require("../services/savingsCalc");

// ─── GET /radar/nearby ────────────────────────────────────────────────────────
router.get("/nearby", async (req, res) => {
  try {
    const { lat, lng, category = "grocery", radius = 2000 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ success: false, error: "lat and lng are required" });
    }

    const [places, dealsSnapshot] = await Promise.all([
      getNearbyPlaces(parseFloat(lat), parseFloat(lng), category, parseInt(radius)),
      db.collection("deals").limit(100).get(),
    ]);

    const communityDeals = dealsSnapshot.docs
      .map((d) => d.data())
      .filter((d) => d.hidden !== true && d.category === category)
      .sort((a, b) => (b.trustScore || 0) - (a.trustScore || 0))
      .slice(0, 20);

    res.json({ success: true, nearbyPlaces: places, communityDeals });
  } catch (err) {
    console.error("GET /radar/nearby error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /radar/route-optimize ───────────────────────────────────────────────
// UPGRADED: Now queries real deals from Firestore and builds intelligent stops
// from actual verified deal locations instead of hardcoded coordinates.
//
// Called by:
//   - Flutter app (when user taps "Generate route" after entering grocery list)
//   - Person 1's backend (when AI orchestrator triggers Smart Radar)
//
// Body: {
//   userId, originLat, originLng,
//   groceryList: ["rice","eggs"],     ← what user wants to buy
//   category: "grocery",             ← optional, defaults to grocery
//   stops: [...]                     ← optional override; if omitted, we find
//                                       real deals from Firestore automatically
// }
router.post("/route-optimize", async (req, res) => {
  try {
    const { userId, originLat, originLng, groceryList, category = "grocery", stops: manualStops } = req.body;

    if (!userId || !originLat || !originLng) {
      return res.status(400).json({
        success: false,
        error: "userId, originLat, originLng are required",
      });
    }

    const oLat = parseFloat(originLat);
    const oLng = parseFloat(originLng);

    // ── INTELLIGENCE: find real deals from Firestore ──────────────────────────
    // If no manual stops provided, query our own deals database to find the
    // best verified deals nearby and use those as route stops
    let stops = manualStops;

    if (!stops || stops.length === 0) {
      const dealsSnapshot = await db.collection("deals").limit(100).get();

      const nearbyDeals = dealsSnapshot.docs
        .map((d) => d.data())
        .filter((d) => {
          if (d.hidden) return false;
          if (category && d.category !== category) return false;
          if (!d.location) return false;

          // Validate coordinates are real numbers before using in Maps API
          const dLat = parseFloat(d.location._latitude);
          const dLng = parseFloat(d.location._longitude);
          if (isNaN(dLat) || isNaN(dLng)) return false;

          // Filter by rough distance (within ~5km)
          const distKm = Math.sqrt(
            Math.pow(dLat - oLat, 2) + Math.pow(dLng - oLng, 2)
          ) * 111;
          return distKm <= 5;
        })
        .sort((a, b) => {
          // Sort by trust score first, then by price (cheapest = best)
          if (b.trustScore !== a.trustScore) return (b.trustScore || 0) - (a.trustScore || 0);
          return (a.price || 0) - (b.price || 0);
        })
        .slice(0, 3); // top 3 real deals as stops

      if (nearbyDeals.length > 0) {
        // Split grocery list across stops intelligently
        const items = groceryList || [];
        const itemsPerStop = Math.ceil(items.length / nearbyDeals.length) || 1;

        stops = nearbyDeals.map((deal, i) => ({
          storeName: deal.storeName,
          address: deal.address || deal.storeName,
          lat: deal.location._latitude,
          lng: deal.location._longitude,
          dealId: deal.dealId,
          dealTitle: deal.title,
          dealPrice: deal.price,
          trustScore: deal.trustScore,
          items: items.slice(i * itemsPerStop, (i + 1) * itemsPerStop),
        }));
      } else {
        // No real deals found — fallback to a generic nearby stop
        stops = [{
          storeName: "Nearby Store",
          lat: parseFloat((oLat + 0.005).toFixed(6)),
          lng: parseFloat((oLng + 0.005).toFixed(6)),
          items: groceryList || [],
        }];
      }
    }

    // ── Calculate savings from actual deal prices in Firestore ────────────────
    const dealPriceSavings = stops.reduce((total, stop) => {
      if (stop.dealPrice) {
        // Real saving = estimated original price (20% above deal) minus deal price
        return total + (stop.dealPrice * 0.2);
      }
      return total + 1.5; // fallback estimate
    }, 0);

    // ── Call Directions API to get optimized route ────────────────────────────
    let routeResult;
    let distanceMatrix = [];

    try {
      routeResult = await getOptimizedRoute(oLat, oLng, stops);

      const addresses = stops.map((s) => s.address || `${s.lat},${s.lng}`);
      distanceMatrix = await getDistanceMatrix(oLat, oLng, addresses);
    } catch (mapsErr) {
      // Maps API failed (no key or quota) — use distance estimate fallback
      console.warn("Directions API failed, using distance estimate:", mapsErr.message);

      const avgDistKm = stops.reduce((sum, stop) => {
        const dLat = stop.lat - oLat;
        const dLng = stop.lng - oLng;
        return sum + Math.sqrt(dLat * dLat + dLng * dLng) * 111;
      }, 0) / stops.length;

      routeResult = {
        optimizedStopOrder: stops.map((_, i) => i),
        totalDistanceKm: parseFloat((avgDistKm * stops.length * 1.3).toFixed(2)),
        totalDurationMinutes: Math.round(avgDistKm * stops.length * 4),
        legs: [],
        polyline: null,
      };
    }

    const savings = calculateNetSavings(
      parseFloat(dealPriceSavings.toFixed(2)),
      routeResult.totalDistanceKm
    );

    const orderedStops = routeResult.optimizedStopOrder.length > 0
      ? routeResult.optimizedStopOrder.map((i) => stops[i])
      : stops;

    // ── Persist route to Firestore ────────────────────────────────────────────
    const routeRef = db.collection("routes").doc();
    await routeRef.set({
      routeId: routeRef.id,
      userId,
      groceryList: groceryList || [],
      stops: orderedStops,
      totalDistanceKm: routeResult.totalDistanceKm,
      totalDurationMinutes: routeResult.totalDurationMinutes,
      estimatedSavings: savings.netSavingRM,
      grossSavingRM: savings.grossSavingRM,
      travelCostRM: savings.travelCostRM,
      usedRealDeals: !manualStops,  // flag whether stops came from real Firestore deals
      acceptedByUser: false,
      createdAt: new Date().toISOString(),
    });

    res.json({
      success: true,
      routeId: routeRef.id,
      orderedStops,
      totalDistanceKm: routeResult.totalDistanceKm,
      totalDurationMinutes: routeResult.totalDurationMinutes,
      legs: routeResult.legs,
      savings,
      polyline: routeResult.polyline,
      distanceMatrix,
      usedRealDeals: !manualStops,
      dealCount: stops.length,
    });
  } catch (err) {
    console.error("POST /radar/route-optimize error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /radar/ai-trigger ───────────────────────────────────────────────────
// Called by Person 1's backend when Person 2's AI orchestrator triggers Smart Radar
// This is the INTEGRATION ENDPOINT that connects your module to the AI pipeline
//
// Person 1 calls this after reading orchestrator_result["smartRadar"] from Person 2
//
// Body (from Person 1, sourced from Person 2's integrationPayload.fcmPayload.data):
// {
//   userId: string,
//   originLat: number,
//   originLng: number,
//   radarCategory: string,        ← from Person 2: orchestrator_result.smartRadar.radarCategory
//   radarMessage: string,         ← from Person 2: the nudge message
//   triggerSmartRadar: boolean,   ← from Person 2: should always be true here
//   spendingCategory: string,     ← what the user overspent on (e.g. "food")
// }
router.post("/ai-trigger", async (req, res) => {
  try {
    const { userId, originLat, originLng, radarCategory, radarMessage, spendingCategory } = req.body;

    if (!userId || !originLat || !originLng) {
      return res.status(400).json({ success: false, error: "userId, originLat, originLng required" });
    }

    const category = radarCategory || spendingCategory || "food";

    // Find top verified deals in this category near user
    const dealsSnapshot = await db.collection("deals").limit(100).get();

    const nearbyDeals = dealsSnapshot.docs
      .map((d) => d.data())
      .filter((d) => {
        if (d.hidden || !d.location) return false;
        if (d.category !== category) return false;
        const dLat = Math.abs(d.location._latitude - parseFloat(originLat));
        const dLng = Math.abs(d.location._longitude - parseFloat(originLng));
        return Math.sqrt(dLat * dLat + dLng * dLng) * 111 <= 5;
      })
      .sort((a, b) => (b.trustScore || 0) - (a.trustScore || 0))
      .slice(0, 5);

    // Calculate potential savings from top deals
    const potentialSavings = nearbyDeals.reduce((sum, d) => sum + (d.price || 0) * 0.2, 0);

    res.json({
      success: true,
      triggered: true,
      category,
      radarMessage: radarMessage || `You tend to overspend on ${category}. Check these nearby deals.`,
      nearbyDeals: nearbyDeals.map((d) => ({
        dealId: d.dealId,
        title: d.title,
        storeName: d.storeName,
        price: d.price,
        trustScore: d.trustScore,
        verified: d.verified,
        lat: d.location._latitude,
        lng: d.location._longitude,
      })),
      potentialSavingsRM: parseFloat(potentialSavings.toFixed(2)),
      dealCount: nearbyDeals.length,
      // Flutter app reads this to auto-open Smart Radar screen
      deepLink: {
        screen: "smart_radar",
        category,
        autoFilter: true,
      },
    });
  } catch (err) {
    console.error("POST /radar/ai-trigger error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /radar/route-accepted ───────────────────────────────────────────────
router.post("/route-accepted", async (req, res) => {
  try {
    const { userId, routeId, actualSavingsRM } = req.body;

    if (!userId || !routeId) {
      return res.status(400).json({ success: false, error: "userId and routeId required" });
    }

    await db.collection("routes").doc(routeId).update({ acceptedByUser: true });

    const route = (await db.collection("routes").doc(routeId).get()).data();
    const savingsAmount = actualSavingsRM ?? route?.estimatedSavings ?? 0;

    const proofId = await recordSavingsProof(db, userId, {
      type: "route_used",
      amountSaved: parseFloat(savingsAmount),
      category: "grocery",
      routeId,
    });

    res.json({ success: true, proofId, amountSaved: savingsAmount });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── GET /radar/savings-summary ───────────────────────────────────────────────
router.get("/savings-summary", async (req, res) => {
  try {
    const { userId, month } = req.query;

    if (!userId) return res.status(400).json({ success: false, error: "userId required" });

    const now = new Date();
    const targetMonth = month || `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

    const snapshot = await db
      .collection("savings_proof")
      .where("userId", "==", userId)
      .where("month", "==", targetMonth)
      .get();

    const records = snapshot.docs.map((d) => d.data());
    const summary = aggregateMonthlySavings(records);

    res.json({ success: true, month: targetMonth, ...summary });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;