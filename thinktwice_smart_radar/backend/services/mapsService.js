const axios = require("axios");

const BASE = "https://maps.googleapis.com/maps/api";
// Read at call time, not at module load — ensures dotenv is already initialised
const getKey = () => {
  const key = process.env.GOOGLE_MAPS_API_KEY;
  if (!key) throw new Error("GOOGLE_MAPS_API_KEY is not set in .env");
  return key;
};

// Find nearby stores/deals by category and user location
async function getNearbyPlaces(lat, lng, category = "grocery_or_supermarket", radiusMeters = 2000) {
  const typeMap = {
    food: "restaurant",
    grocery: "grocery_or_supermarket",
    transport: "transit_station",
  };

  const placeType = typeMap[category] || "store";

  const url = `${BASE}/place/nearbysearch/json`;
  const params = {
    location: `${lat},${lng}`,
    radius: radiusMeters,
    type: placeType,
    key: getKey(),
  };

  const res = await axios.get(url, { params });

  if (res.data.status !== "OK" && res.data.status !== "ZERO_RESULTS") {
    throw new Error(`Places API error: ${res.data.status}`);
  }

  return (res.data.results || []).slice(0, 10).map((place) => ({
    placeId: place.place_id,
    name: place.name,
    address: place.vicinity,
    lat: place.geometry.location.lat,
    lng: place.geometry.location.lng,
    rating: place.rating || null,
    isOpen: place.opening_hours?.open_now ?? null,
  }));
}

// Optimize multi-stop grocery route using Directions API
// stops = [{ lat, lng, storeName, items[] }, ...]
// ALWAYS uses coordinates — never address strings (Google NOT_FOUND fix)
async function getOptimizedRoute(originLat, originLng, stops) {
  if (!stops || stops.length === 0) {
    throw new Error("At least one stop is required");
  }

  // ── Validate all inputs are real numbers ───────────────────────────────────
  const oLat = parseFloat(originLat);
  const oLng = parseFloat(originLng);

  if (isNaN(oLat) || isNaN(oLng)) {
    throw new Error(`Invalid origin coordinates: ${originLat}, ${originLng}`);
  }

  // Validate each stop has usable coordinates
  const validatedStops = stops.map((s, i) => {
    const lat = parseFloat(s.lat ?? s.latitude);
    const lng = parseFloat(s.lng ?? s.longitude);

    if (isNaN(lat) || isNaN(lng)) {
      throw new Error(
        `Stop ${i} ("${s.storeName || "unknown"}") has invalid coordinates: lat=${s.lat}, lng=${s.lng}`
      );
    }

    return { ...s, lat, lng };
  });

  // ── Always use lat,lng format — never address strings ─────────────────────
  // Address strings like "FamilyMart" or "Nearby Store" cause NOT_FOUND
  const toCoord = (stop) => `${stop.lat},${stop.lng}`;

  const origin = `${oLat},${oLng}`;
  const destination = toCoord(validatedStops[validatedStops.length - 1]);
  const middleStops = validatedStops.slice(0, -1);

  const waypointStr = middleStops.length > 0
    ? `optimize:true|${middleStops.map(toCoord).join("|")}`
    : undefined;

  // ── Log exactly what we're sending (helps debug future issues) ─────────────
  console.log("Directions API request:", {
    origin,
    destination,
    waypoints: waypointStr,
    stopCount: validatedStops.length,
  });

  const url = `${BASE}/directions/json`;
  const params = {
    origin,
    destination,
    ...(waypointStr && { waypoints: waypointStr }),
    mode: "driving",
    key: getKey(),
  };

  const res = await axios.get(url, { params });

  if (res.data.status !== "OK") {
    // Log the full error detail from Google for easier debugging
    console.error("Directions API error:", res.data.status, res.data.error_message || "");
    throw new Error(`Directions API error: ${res.data.status}${res.data.error_message ? " — " + res.data.error_message : ""}`);
  }

  const route = res.data.routes[0];
  const legs = route.legs;

  const totalDistanceMeters = legs.reduce((sum, leg) => sum + leg.distance.value, 0);
  const totalDurationSeconds = legs.reduce((sum, leg) => sum + leg.duration.value, 0);

  return {
    optimizedStopOrder: route.waypoint_order || [],
    totalDistanceKm: parseFloat((totalDistanceMeters / 1000).toFixed(2)),
    totalDurationMinutes: Math.round(totalDurationSeconds / 60),
    legs: legs.map((leg) => ({
      from: leg.start_address,
      to: leg.end_address,
      distanceKm: parseFloat((leg.distance.value / 1000).toFixed(2)),
      durationMinutes: Math.round(leg.duration.value / 60),
    })),
    polyline: route.overview_polyline?.points || null,
  };
}

// Estimate travel cost between user and a set of stops
// Pass stops as objects with lat/lng, not address strings
async function getDistanceMatrix(originLat, originLng, stops) {
  // Accept either array of stop objects {lat,lng} or legacy array of strings
  const destinations = stops.map((s) =>
    typeof s === "string" ? s : `${parseFloat(s.lat)},${parseFloat(s.lng)}`
  ).join("|");

  const url = `${BASE}/distancematrix/json`;
  const params = {
    origins: `${parseFloat(originLat)},${parseFloat(originLng)}`,
    destinations,
    mode: "driving",
    key: getKey(),
  };

  const res = await axios.get(url, { params });

  if (res.data.status !== "OK") {
    throw new Error(`Distance Matrix API error: ${res.data.status}`);
  }

  const elements = res.data.rows[0].elements;
  const destNames = res.data.destination_addresses;

  return elements.map((el, i) => ({
    destination: destNames[i],
    distanceKm: el.status === "OK" ? parseFloat((el.distance.value / 1000).toFixed(2)) : null,
    durationMinutes: el.status === "OK" ? Math.round(el.duration.value / 60) : null,
    status: el.status,
  }));
}

module.exports = { getNearbyPlaces, getOptimizedRoute, getDistanceMatrix };