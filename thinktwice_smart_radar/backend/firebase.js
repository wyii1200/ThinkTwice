const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  const config = {
    credential: admin.credential.cert(serviceAccount),
  };

  if (process.env.FIREBASE_STORAGE_BUCKET) {
    config.storageBucket = process.env.FIREBASE_STORAGE_BUCKET;
  }

  admin.initializeApp(config);
}

const db = admin.firestore();

// Storage only available once FIREBASE_STORAGE_BUCKET is set
// (needed for deal image uploads — wait for Person 1 to share bucket name)
const bucket = process.env.FIREBASE_STORAGE_BUCKET
  ? admin.storage().bucket()
  : null;

module.exports = { admin, db, bucket };