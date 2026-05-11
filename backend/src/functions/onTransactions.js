// Firebase Cloud Functions — deploy with: firebase deploy --only functions
const functions = require('firebase-functions');
const admin     = require('firebase-admin');
const axios     = require('axios');

if (!admin.apps.length) admin.initializeApp();

const BACKEND_URL = process.env.BACKEND_URL || functions.config().backend?.url || 'https://us-central1-thinktwice-kamihack.cloudfunctions.net/api';

// ─── 1. On transaction created ────────────────────────────────────────────────
// Triggers whenever a new doc is written to /transactions/{transactionId}
exports.onTransactionCreated = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const { transactionId } = context.params;

    console.log('New transaction detected:', transactionId, transaction);

    // Retry up to 3 times if backend is temporarily down
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        await axios.post(`${BACKEND_URL}/webhook/transaction`, {
          ...transaction,
          transactionId,
        }, { timeout: 10000 });

        console.log(`Transaction ${transactionId} processed on attempt ${attempt}`);
        return; // success — exit
      } catch (error) {
        console.error(`Attempt ${attempt} failed:`, error.message);
        if (attempt < 3) await sleep(attempt * 1000); // wait 1s, then 2s
      }
    }

    console.error(`Transaction ${transactionId} failed after 3 attempts`);
  });

// ─── 2. Monthly food spend reset ─────────────────────────────────────────────
// Runs at midnight on the 1st of every month (Malaysia time UTC+8)
// Resets monthlyFoodSpend so the Food Budget Challenge starts fresh each month
exports.resetMonthlyFoodSpend = functions.pubsub
  .schedule('0 16 1 * *')        // 00:00 MYT = 16:00 UTC previous day (1st)
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async () => {
    const db = admin.firestore();
    const usersSnap = await db.collection('users').get();

    const batch = db.batch();
    usersSnap.docs.forEach(doc => {
      batch.update(doc.ref, { monthlyFoodSpend: 0 });
    });

    await batch.commit();
    console.log(`Monthly food spend reset for ${usersSnap.size} users`);
  });

// ─── 3. Daily streak check ────────────────────────────────────────────────────
// Runs at 23:59 every night — resets streak if user had no transactions today
// Prevents streaks from persisting on inactive days
exports.dailyStreakCheck = functions.pubsub
  .schedule('59 15 * * *')       // 23:59 MYT = 15:59 UTC
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async () => {
    const db  = admin.firestore();
    const now = new Date();

    // Start of today (MYT)
    const startOfDay = new Date(now);
    startOfDay.setHours(0, 0, 0, 0);

    const usersSnap = await db.collection('users').get();

    for (const userDoc of usersSnap.docs) {
      const userId = userDoc.id;

      // Check if user had any transaction today
      const todayTxSnap = await db.collection('transactions')
        .where('userId', '==', userId)
        .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(startOfDay))
        .limit(1)
        .get();

      if (todayTxSnap.empty) {
        // No activity today — reset risk avoidance streak
        try {
          await axios.post(`${BACKEND_URL}/gamification/update-streak`, {
            userId,
            streakType: 'riskAvoidance',
            action: 'reset',
          }, { timeout: 5000 });
          console.log(`Streak reset for inactive user: ${userId}`);
        } catch (err) {
          console.warn(`Could not reset streak for ${userId}:`, err.message);
        }
      }
    }
  });

// ─── Helper ───────────────────────────────────────────────────────────────────
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}