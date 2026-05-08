const express = require("express");
const router = express.Router();
const { db } = require("../firebase");
const { getNearbyPlaces, getOptimizedRoute, getDistanceMatrix } = require("../services/mapsService");
const { calculateNetSavings, aggregateMonthlySavings, recordSavingsProof } = require("../services/savingsCalc");

// ─── GET /radar/nearby ────────────────────────────────────────────────────────
// Returns nearby stores from Google Places + community deals in same area
// Query params: lat, lng, category, radius (meters, default 2000)
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

    res.json({
      success: true,
      nearbyPlaces: places,
      communityDeals,
    });
  } catch (err) {
    console.error("GET /radar/nearby error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /radar/route-optimize ───────────────────────────────────────────────
// Person 2's Smart Radar Agent calls this endpoint
// Body: {
//   userId: string,
//   originLat: number,
//   originLng: number,
//   groceryList: string[],          // ["rice", "eggs", "bread"]
//   stops: [{ storeName, address, items[], lat?, lng? }]
// }
// Returns optimized route + estimated savings
router.post("/route-optimize", async (req, res) => {
  try {
    const { userId, originLat, originLng, groceryList, stops } = req.body;

    if (!userId || !originLat || !originLng || !stops || stops.length === 0) {
      return res.status(400).json({
        success: false,
        error: "userId, originLat, originLng, and stops[] are required",
      });
    }

    // Get optimized route from Google Directions API
    const routeResult = await getOptimizedRoute(parseFloat(originLat), parseFloat(originLng), stops);

    // Get travel distances for cost estimate
    const addresses = stops.map((s) => s.address || `${s.lat},${s.lng}`);
    const distanceMatrix = await getDistanceMatrix(parseFloat(originLat), parseFloat(originLng), addresses);

    // Estimate savings based on grocery list size and number of stops
    // Logic: more items = more saving potential from price comparison across stores
    const itemCount = (groceryList || []).length || stops.reduce((n, s) => n + (s.items?.length || 1), 0);
    const savingPerItem = 1.5; // RM per item saved by shopping at cheapest store
    const grossSaving = Math.max(stops.length * 2, itemCount * savingPerItem);
    const savings = calculateNetSavings(grossSaving, routeResult.totalDistanceKm);

    // Build ordered stops based on Directions API optimization
    const orderedStops = routeResult.optimizedStopOrder.length > 0
      ? routeResult.optimizedStopOrder.map((i) => stops[i])
      : stops;

    // Persist route to Firestore
    const routeRef = db.collection("routes").doc();
    const routeData = {
      routeId: routeRef.id,
      userId,
      groceryList: groceryList || [],
      stops: orderedStops,
      totalDistanceKm: routeResult.totalDistanceKm,
      totalDurationMinutes: routeResult.totalDurationMinutes,
      estimatedSavings: savings.netSavingRM,
      grossSavingRM: savings.grossSavingRM,
      travelCostRM: savings.travelCostRM,
      acceptedByUser: false,
      createdAt: new Date().toISOString(),
    };

    await routeRef.set(routeData);

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
    });
  } catch (err) {
    console.error("POST /radar/route-optimize error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── POST /radar/route-accepted ───────────────────────────────────────────────
// Called when user accepts and follows the optimized route
// Body: { userId, routeId, actualSavingsRM }
router.post("/route-accepted", async (req, res) => {
  try {
    const { userId, routeId, actualSavingsRM } = req.body;

    if (!userId || !routeId) {
      return res.status(400).json({ success: false, error: "userId and routeId required" });
    }

    // Mark route as accepted
    await db.collection("routes").doc(routeId).update({ acceptedByUser: true });

    // Record savings proof
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
// Returns monthly savings summary for Person 3's dashboard display
// Query params: userId, month (e.g. "2025-06", defaults to current month)
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