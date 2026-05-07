const axios = require("axios");
 
const MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;
const BASE = "https://maps.googleapis.com/maps/api";
 
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
    key: MAPS_API_KEY,
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
// stops = [{ address or lat/lng }, ...]
async function getOptimizedRoute(originLat, originLng, stops) {
  if (!stops || stops.length === 0) {
    throw new Error("At least one stop is required");
  }
 
  const origin = `${originLat},${originLng}`;
  const destination = stops[stops.length - 1].address || `${stops[stops.length - 1].lat},${stops[stops.length - 1].lng}`;
 
  const waypoints = stops
    .slice(0, -1)
    .map((s) => s.address || `${s.lat},${s.lng}`)
    .join("|");
 
  const url = `${BASE}/directions/json`;
  const params = {
    origin,
    destination,
    waypoints: waypoints ? `optimize:true|${waypoints}` : undefined,
    mode: "driving",
    key: MAPS_API_KEY,
  };
 
  const res = await axios.get(url, { params });
 
  if (res.data.status !== "OK") {
    throw new Error(`Directions API error: ${res.data.status}`);
  }
 
  const route = res.data.routes[0];
  const legs = route.legs;
 
  const totalDistanceMeters = legs.reduce((sum, leg) => sum + leg.distance.value, 0);
  const totalDurationSeconds = legs.reduce((sum, leg) => sum + leg.duration.value, 0);
 
  const optimizedOrder = route.waypoint_order || [];
 
  return {
    optimizedStopOrder: optimizedOrder,
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
 
// Estimate travel cost between user and a set of stores
async function getDistanceMatrix(originLat, originLng, destinationAddresses) {
  const url = `${BASE}/distancematrix/json`;
  const params = {
    origins: `${originLat},${originLng}`,
    destinations: destinationAddresses.join("|"),
    mode: "driving",
    key: MAPS_API_KEY,
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