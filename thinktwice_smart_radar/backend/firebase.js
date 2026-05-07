const admin = require("firebase-admin");
 
// For local dev: set GOOGLE_APPLICATION_CREDENTIALS env var to your service account JSON path
// For deployment: Firebase auto-detects credentials
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET, // e.g. "thinktwice.appspot.com"
  });
}
 
const db = admin.firestore();
const bucket = admin.storage().bucket();
 
module.exports = { admin, db, bucket };