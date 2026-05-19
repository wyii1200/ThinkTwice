const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

function serverTimestamp() {
  return admin.firestore.FieldValue.serverTimestamp();
}

async function saveTransaction(data) {
  const cleanedData = {};
  for (const key in data) {
    if (data[key] !== undefined) {
      cleanedData[key] = data[key];
    }
  }

  const ref = await db.collection('transactions').add({
    ...cleanedData,
    amount: Number(cleanedData.amount || 0),
    status: cleanedData.status || 'completed',
    timestamp: serverTimestamp(),
    createdAt: serverTimestamp(),
  });

  return ref.id;
}

async function getTransactionsByUser(userId, limit = 20) {
  const snapshot = await db
    .collection('transactions')
    .where('userId', '==', userId)
    .get();

  return snapshot.docs
    .map((doc) => ({ id: doc.id, ...doc.data() }))
    .sort((a, b) => {
      const tA = a.timestamp?.toMillis ? a.timestamp.toMillis() : 0;
      const tB = b.timestamp?.toMillis ? b.timestamp.toMillis() : 0;
      return tB - tA;
    })
    .slice(0, limit);
}

async function getUserProfile(userId) {
  const doc = await db.collection('users').doc(userId).get();

  if (!doc.exists) {
    return null;
  }

  return {
    userId: doc.id,
    ...doc.data(),
  };
}

async function updateUserProfile(userId, updates) {
  await db.collection('users').doc(userId).set(
    {
      ...updates,
      updatedAt: serverTimestamp(),
    },
    { merge: true }
  );
}

async function updateResilienceScore(userId, delta) {
  const ref = db.collection('users').doc(userId);
  const doc = await ref.get();

  const data = doc.exists ? doc.data() : {};

  const currentMoneyHabitScore =
    data.moneyHabitScore ??
    data.resilienceScore ??
    50;

  const nextMoneyHabitScore = Math.max(
    0,
    Math.min(100, currentMoneyHabitScore + Number(delta || 0))
  );

  await ref.set(
    {
      resilienceScore: nextMoneyHabitScore,
      moneyHabitScore: nextMoneyHabitScore,
      updatedAt: serverTimestamp(),
    },
    { merge: true }
  );

  return nextMoneyHabitScore;
}

async function updateSavingsPocket(userId, amount) {
  const ref = db.collection('users').doc(userId);
  const doc = await ref.get();

  const data = doc.exists ? doc.data() : {};

  const currentSavingsPocket = Number(data.savingsPocket || 0);
  const currentMoneySavedThisWeek = Number(data.moneySavedThisWeek || 0);
  const saveAmount = Number(amount || 0);

  const nextSavingsPocket = currentSavingsPocket + saveAmount;
  const nextMoneySavedThisWeek = currentMoneySavedThisWeek + saveAmount;

  await ref.set(
    {
      savingsPocket: nextSavingsPocket,
      moneySavedThisWeek: nextMoneySavedThisWeek,
      updatedAt: serverTimestamp(),
    },
    { merge: true }
  );

  return {
    savingsPocket: nextSavingsPocket,
    moneySavedThisWeek: nextMoneySavedThisWeek,
  };
}

async function logNudge(userId, nudgeData) {
  const ref = await db.collection('nudgeLogs').add({
    userId,
    ...nudgeData,
    createdAt: serverTimestamp(),
    timestamp: serverTimestamp(),
  });

  return ref.id;
}

async function getNudgeLogs(userId, limit = 5) {
  const snapshot = await db
    .collection('nudgeLogs')
    .where('userId', '==', userId)
    .get();

  return snapshot.docs
    .map((doc) => ({ id: doc.id, ...doc.data() }))
    .sort((a, b) => {
      const tA = a.createdAt?.toMillis ? a.createdAt.toMillis() : 0;
      const tB = b.createdAt?.toMillis ? b.createdAt.toMillis() : 0;
      return tB - tA;
    })
    .slice(0, limit);
}

async function deductBalance(userId, amount) {
  const ref = db.collection('users').doc(userId);
  const doc = await ref.get();

  const data = doc.exists ? doc.data() : {};
  const currentBalance = Number(data.currentBalance || 0);
  const nextBalance = Math.max(0, currentBalance - Number(amount || 0));

  await ref.set(
    {
      currentBalance: nextBalance,
      updatedAt: serverTimestamp(),
    },
    { merge: true }
  );

  return nextBalance;
}

async function saveLatestAIAnalysis(collectionPath, data) {
  let docPath = collectionPath;

  const parts = String(collectionPath || '').split('/');

  if (!collectionPath || parts.length % 2 !== 0) {
    docPath = `users/${data.userId || 'demo_user'}/ai/latest_ai_analysis`;
  }

  await db.doc(docPath).set(
    {
      ...data,
      updatedAt: serverTimestamp(),
    },
    { merge: true }
  );

  return docPath;
}

async function getLatestAIAnalysis(userId) {
  const doc = await db
    .doc(`users/${userId}/ai/latest_ai_analysis`)
    .get();

  return doc.exists ? doc.data() : null;
}

async function getDashboardSummary(userId) {
  const profile = await getUserProfile(userId);
  const latestAI = await getLatestAIAnalysis(userId);
  const nudges = await getNudgeLogs(userId, 5);
  const transactions = await getTransactionsByUser(userId, 10);

  const moneyHabitScore =
    profile?.moneyHabitScore ??
    profile?.resilienceScore ??
    latestAI?.resilienceScore ??
    50;

  return {
    userId,
    moneyHabitScore,
    resilienceScore: moneyHabitScore,
    moneySavedThisWeek: profile?.moneySavedThisWeek || profile?.savingsPocket || 0,
    smartSpendingStreak:
      profile?.smartSpendingStreak ||
      latestAI?.streakStatus ||
      'at_risk',
    latestAI,
    recentNudges: nudges,
    recentTransactions: transactions,
    dashboardMessage:
      latestAI?.recommendedAction ||
      'ThinkTwice is monitoring your spending habits.',
  };
}

module.exports = {
  db,
  admin,
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
  getLatestAIAnalysis,
  getDashboardSummary,
};