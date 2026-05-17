const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  const config = {
    credential: admin.credential.cert(serviceAccount),
  };

  if (process.env.FIREBASE_STORAGE_BUCKET) {
    // In firebase.js, temporarily hardcode to test:
    config.storageBucket = process.env.FIREBASE_STORAGE_BUCKET || 'thinktwice-kamihack.firebasestorage.app';
  }

  admin.initializeApp(config);
}

const db = admin.firestore();

const bucket = process.env.FIREBASE_STORAGE_BUCKET
  ? admin.storage().bucket()
  : null;

module.exports = { admin, db, bucket };