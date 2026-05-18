// Firebase scheduled functions only.
// Do NOT trigger AI from transaction creation.
// ThinkTwice final flow analyses payment intent BEFORE confirmation.

const functions = require('firebase-functions');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

// Monthly food spend reset
exports.resetMonthlyFoodSpend = functions.pubsub
  .schedule('0 16 1 * *')
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async () => {
    const db = admin.firestore();
    const usersSnap = await db.collection('users').get();

    const batch = db.batch();

    usersSnap.docs.forEach((doc) => {
      batch.set(
        doc.ref,
        {
          monthlyFoodSpend: 0,
          weeklySpentFood: 0,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    await batch.commit();

    console.log(`Monthly/weekly food spend reset for ${usersSnap.size} users`);
  });

// Daily streak check
exports.dailyStreakCheck = functions.pubsub
  .schedule('59 15 * * *')
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async () => {
    const db = admin.firestore();

    const now = new Date();
    const startOfDay = new Date(now);
    startOfDay.setHours(0, 0, 0, 0);

    const usersSnap = await db.collection('users').get();

    const batch = db.batch();

    for (const userDoc of usersSnap.docs) {
      const userId = userDoc.id;

      const todayTxSnap = await db
        .collection('transactions')
        .where('userId', '==', userId)
        .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(startOfDay))
        .limit(1)
        .get();

      if (todayTxSnap.empty) {
        batch.set(
          userDoc.ref,
          {
            riskAvoidanceStreak: 0,
            smartSpendingStreak: 0,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      }
    }

    await batch.commit();

    console.log('Daily streak check completed.');
  });