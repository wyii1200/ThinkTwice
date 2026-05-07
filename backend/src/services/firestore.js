const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID,
  });
}

const db = admin.firestore();

async function saveTransaction(data) {
  const ref = await db.collection('transactions').add({
    ...data,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
  return ref.id;
}

async function getTransactionsByUser(userId, limit = 20) {
  const snapshot = await db
    .collection('transactions')
    .where('userId', '==', userId)
    .orderBy('timestamp', 'desc')
    .limit(limit)
    .get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

async function getUserProfile(userId) {
  const doc = await db.collection('users').doc(userId).get();
  return doc.exists ? doc.data() : null;
}

async function updateUserProfile(userId, updates) {
  await db.collection('users').doc(userId).set(updates, { merge: true });
}

async function updateResilienceScore(userId, delta) {
  const ref = db.collection('users').doc(userId);
  await ref.update({
    resilienceScore: admin.firestore.FieldValue.increment(delta),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function updateSavingsPocket(userId, amount) {
  const ref = db.collection('users').doc(userId);
  await ref.update({
    savingsPocket: admin.firestore.FieldValue.increment(amount),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function logNudge(userId, nudgeData) {
  await db.collection('nudgeLogs').add({
    userId,
    ...nudgeData,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

module.exports = {
  saveTransaction,
  getTransactionsByUser,
  getUserProfile,
  updateUserProfile,
  updateResilienceScore,
  updateSavingsPocket,
  logNudge,
};