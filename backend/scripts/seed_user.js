require('dotenv').config();

const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

async function seedDemoUser() {
  const db = admin.firestore();

  await db.collection('users').doc('demo_user').set(
    {
      userId: 'demo_user',
      displayName: 'Chee Ling',
      email: 'demo@thinktwice.ai',

      dailyBudget: 25,
      savingsGoal: 200,
      weeklyFoodBudget: 80,
      weeklySpentFood: 68,
      dailySafeLimit: 25,
      preferredSavingsAmount: 8,

      currentBalance: 1500.5,
      savingsPocket: 0,
      moneySavedThisWeek: 0,

      totalPoints: 0,
      resilienceScore: 50,
      moneyHabitScore: 50,
      smartDecisionScore: 50,

      streak: 0,
      riskAvoidanceStreak: 0,
      smartSpendingStreak: 0,
      longestStreak: 0,

      monthlyFoodSpend: 68,

      claimedQuests: [],
      unlockedAvatars: ['default'],
      avatarId: 'default',

      lat: 3.1185,
      lng: 101.6779,

      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastStreakUpdate: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  console.log('✅ Demo user seeded: demo_user');
  process.exit(0);
}

seedDemoUser().catch((error) => {
  console.error('❌ Seed failed:', error);
  process.exit(1);
});