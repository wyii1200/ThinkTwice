// ─── Firestore User Document Schema ──────────────────────────────────────────
// Collection: /users/{userId}
// Person 1 must ensure these fields exist when creating a user

const USER_SCHEMA = {
  // Identity
  userId:              "string",
  displayName:         "string",
  email:               "string",

  // Points & Level
  totalPoints:         0,         // incremented by award-points endpoint
  resilienceScore:     50,        // 0–100, incremented with points
  smartDecisionScore:  50,        // 0–100, updated by AI agent

  // Streaks
  streak:              0,         // main daily saving streak
  riskAvoidanceStreak: 0,         // days without overspending
  smartSpendingStreak: 0,         // days of smart decisions
  longestStreak:       0,         // historical best

  // Savings
  savingsPocket:       0,         // RM amount saved in GXBank pocket

  // Spending (set by Person 1's transaction pipeline)
  monthlyFoodSpend:    0,         // RM spent on food this month — used by Food Budget quest

  // Gamification state
  claimedQuests:       [],        // array of claimed questIds
  unlockedAvatars:     ["default"],
  avatarId:            "default", // currently selected avatar

  // Timestamps
  createdAt:           "timestamp",
  lastStreakUpdate:    "timestamp",
};

// ─── Seed a test user (run once in Node REPL or as a script) ─────────────────
// Usage: node seed_user.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
}

async function seedTestUser() {
  const db = admin.firestore();

  await db.collection("users").doc("test_user_001").set({
    userId:              "test_user_001",
    displayName:         "Wei Yi",
    email:               "weiyi@test.com",
    totalPoints:         1200,
    resilienceScore:     72,
    smartDecisionScore:  65,
    streak:              7,
    riskAvoidanceStreak: 7,
    smartSpendingStreak: 5,
    longestStreak:       7,
    savingsPocket:       80,
    monthlyFoodSpend:    80,
    claimedQuests:       [],
    unlockedAvatars:     ["default", "avatar_cat"],
    avatarId:            "default",
    createdAt:           admin.firestore.FieldValue.serverTimestamp(),
    lastStreakUpdate:     admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log("✅ Test user seeded");
  process.exit(0);
}

seedTestUser().catch(console.error);