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
  return doc.exists ? { userId: doc.id, ...doc.data() } : null;
}

async function updateUserProfile(userId, updates) {
  await db.collection('users').doc(userId).set(updates, { merge: true });
}

async function updateResilienceScore(userId, delta) {
  const ref = db.collection('users').doc(userId);
  const doc = await ref.get();
  const current = doc.exists ? (doc.data().resilienceScore || 50) : 50;
  const next = Math.max(0, Math.min(100, current + delta));
  await ref.set({
    resilienceScore: next,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  return next;
}

async function updateSavingsPocket(userId, amount) {
  const ref = db.collection('users').doc(userId);
  const doc = await ref.get();
  const current = doc.exists ? (doc.data().savingsPocket || 0) : 0;
  await ref.set({
    savingsPocket: current + amount,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
}

async function logNudge(userId, nudgeData) {
  const ref = await db.collection('nudgeLogs').add({
    userId,
    ...nudgeData,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
  return ref.id;
}

async function getNudgeLogs(userId, limit = 5) {
  const snapshot = await db
    .collection('nudgeLogs')
    .where('userId', '==', userId)
    .orderBy('createdAt', 'desc')
    .limit(limit)
    .get();
  return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

async function deductBalance(userId, amount) {
  const ref = db.collection('users').doc(userId);
  const doc = await ref.get();
  const current = doc.exists ? (doc.data().currentBalance || 0) : 0;
  const next = Math.max(0, current - amount);
  await ref.set({
    currentBalance: next,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  return next;
}

async function saveLatestAIAnalysis(collectionPath, data) {
  let docPath = collectionPath;

  const parts = collectionPath.split('/');

  if (parts.length % 2 !== 0) {
    docPath = `users/${data.userId}/ai/latest_ai_analysis`;
  }

  await db.doc(docPath).set(
    {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  return docPath;
}

module.exports = {
  saveTransaction,
  getTransactionsByUser,
  getUserProfile,
  updateUserProfile,
  updateResilienceScore,
  updateSavingsPocket,
  deductBalance,
  logNudge,
  getNudgeLogs,
  saveLatestAIAnalysis,
};