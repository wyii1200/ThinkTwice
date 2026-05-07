// utils/savePlaces.js
const { db } = require("../firebase");

async function savePlacesToFirestore(places, category) {
  const batch = db.batch();

  // Limit to top 5 places (or whatever number you prefer)
  const limitedPlaces = places.slice(0, 5);

  limitedPlaces.forEach((place) => {
    const placeRef = db.collection("places").doc(place.placeId);

    batch.set(placeRef, {
      placeId: place.placeId,
      name: place.name,
      address: place.address,
      lat: place.lat,
      lng: place.lng,
      category,
      source: "google_places",
      updatedAt: new Date().toISOString(),
    }, { merge: true });
  });

  await batch.commit();
  console.log(`Saved ${limitedPlaces.length} places to Firestore`);
}


module.exports = { savePlacesToFirestore };
