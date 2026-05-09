const express = require('express');
const router = express.Router();
const { getUserProfile } = require('../services/firestore');

// ─── GET /gamification/:userId ────────────────────────────────────────────────
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const profile = await getUserProfile(userId);

    const [userDoc, leaderboardSnap] = await Promise.all([
      db.collection('users').doc(userId).get(),
      db.collection('users').orderBy('totalPoints', 'desc').limit(10).get(),
    ]);

    if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });
    const user = userDoc.data();

    const leaderboard = leaderboardSnap.docs.map((doc, index) => ({
      rank:          index + 1,
      userId:        doc.id,
      displayName:   doc.data().displayName || 'Player',
      totalPoints:   doc.data().totalPoints || 0,
      streak:        doc.data().streak || 0,
      avatarId:      doc.data().avatarId || 'default',
      isCurrentUser: doc.id === userId,
    }));

    const nudgeSnap = await db.collection('nudgeLogs')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();

    const recentPointsEvents = nudgeSnap.docs
      .map(doc => {
        const d = doc.data();
        if (d.status === 'accepted') return { label: 'Saved from nudge', points: 10,  type: 'save',   createdAt: d.createdAt };
        if (d.status === 'ignored')  return { label: 'Nudge ignored',    points: -2,  type: 'ignore', createdAt: d.createdAt };
        return null;
      })
      .filter(Boolean)
      .slice(0, 5);

    const level     = calculateLevel(user.totalPoints || 0);
    const badges    = evaluateBadges(user);
    const quests    = buildQuests(user);
    const streakInfo = buildStreakInfo(user);

    res.json({
      success: true,
      gamification: {
        // Core scores
        streak:              user.streak              || 0,
        totalPoints:         user.totalPoints         || 0,
        resilienceScore:     user.resilienceScore     || 50,
        smartDecisionScore:  user.smartDecisionScore  || 50,
        savingsPocket:       user.savingsPocket       || 0,

        // Level system
        level:               level.current,
        levelLabel:          level.label,
        levelProgress:       level.progress,       // 0.0 – 1.0
        pointsToNextLevel:   level.pointsToNext,

        // Avatar
        avatarId:            user.avatarId || 'default',
        unlockedAvatars:     user.unlockedAvatars || ['default'],

        // Streaks breakdown
        streaks:             streakInfo,

        // Social
        leaderboard,

        // Progression
        badges,
        quests,
        recentPointsEvents,
      },
    });

  } catch (error) {
    console.error('Gamification error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── POST /gamification/award-points ─────────────────────────────────────────
// Called by Person 4's Smart Radar when a deal is verified or a route is used
// Body: { userId, points, reason }
router.post('/award-points', async (req, res) => {
  try {
    const { userId, points, reason } = req.body;
    if (!userId || points == null) {
      return res.status(400).json({ error: 'Missing userId or points' });
    }

    const db = admin.firestore();
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

    const user = userDoc.data();
    const newTotal = (user.totalPoints || 0) + points;
    const newLevel = calculateLevel(newTotal);
    const oldLevel = calculateLevel(user.totalPoints || 0);
    const leveledUp = newLevel.current > oldLevel.current;

    // Update user points + check avatar unlock
    const updates = {
      totalPoints: admin.firestore.FieldValue.increment(points),
      resilienceScore: admin.firestore.FieldValue.increment(
        points > 0 ? Math.ceil(points * 0.1) : Math.floor(points * 0.1)
      ),
    };

    // Unlock avatar on level up
    if (leveledUp && newLevel.avatarUnlock) {
      updates.unlockedAvatars = admin.firestore.FieldValue.arrayUnion(newLevel.avatarUnlock);
    }

    await userRef.update(updates);

    // Log the points event
    await db.collection('pointsLog').add({
      userId,
      points,
      reason: reason || 'manual',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      pointsAwarded: points,
      newTotal,
      leveledUp,
      newLevel: newLevel.current,
      avatarUnlocked: leveledUp ? newLevel.avatarUnlock : null,
    });
  } catch (error) {
    console.error('Award points error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── POST /gamification/claim-quest ──────────────────────────────────────────
router.post('/claim-quest', async (req, res) => {
  try {
    const { userId, questId } = req.body;
    if (!userId || !questId) return res.status(400).json({ error: 'Missing userId or questId' });

    const db = admin.firestore();
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

    const user = userDoc.data();
    const quest = buildQuests(user).find(q => q.id === questId);

    if (!quest)             return res.status(404).json({ error: 'Quest not found' });
    if (!quest.isCompleted) return res.status(400).json({ error: 'Quest not completed yet' });
    if ((user.claimedQuests || []).includes(questId)) {
      return res.status(409).json({ error: 'Already claimed' });
    }

    const updates = {
      claimedQuests: admin.firestore.FieldValue.arrayUnion(questId),
    };

    if (quest.rewardPoints > 0) {
      updates.totalPoints = admin.firestore.FieldValue.increment(quest.rewardPoints);
    }

    // Avatar reward
    if (quest.rewardAvatarId) {
      updates.unlockedAvatars = admin.firestore.FieldValue.arrayUnion(quest.rewardAvatarId);
    }

    await userRef.update(updates);

    await db.collection('pointsLog').add({
      userId,
      points: quest.rewardPoints,
      reason: `quest_claimed:${questId}`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      pointsAwarded:   quest.rewardPoints,
      avatarUnlocked:  quest.rewardAvatarId || null,
    });
  } catch (error) {
    console.error('Claim quest error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── POST /gamification/update-streak ────────────────────────────────────────
// Called by Person 1's transaction pipeline daily to update streaks
// Body: { userId, streakType, action: 'increment' | 'reset' }
router.post('/update-streak', async (req, res) => {
  try {
    const { userId, streakType = 'main', action = 'increment' } = req.body;
    if (!userId) return res.status(400).json({ error: 'userId required' });

    const db = admin.firestore();
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

    const user = userDoc.data();
    const updates = {};

    if (action === 'increment') {
      // Main streak
      if (streakType === 'main' || streakType === 'riskAvoidance') {
        const current = (user.streak || 0) + 1;
        updates.streak = current;
        updates.riskAvoidanceStreak = current;
        // Streak milestone bonus points
        if (current === 3)  updates.totalPoints = admin.firestore.FieldValue.increment(20);
        if (current === 7)  updates.totalPoints = admin.firestore.FieldValue.increment(50);
        if (current === 14) updates.totalPoints = admin.firestore.FieldValue.increment(100);
        if (current === 30) updates.totalPoints = admin.firestore.FieldValue.increment(200);
      }
      if (streakType === 'smartSpending') {
        updates.smartSpendingStreak = (user.smartSpendingStreak || 0) + 1;
      }
    } else {
      // Reset
      if (streakType === 'main' || streakType === 'riskAvoidance') {
        updates.streak = 0;
        updates.riskAvoidanceStreak = 0;
      }
      if (streakType === 'smartSpending') {
        updates.smartSpendingStreak = 0;
      }
    }

    updates.lastStreakUpdate = admin.firestore.FieldValue.serverTimestamp();
    await userRef.update(updates);

    res.json({ success: true, updates });
  } catch (error) {
    console.error('Update streak error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── POST /gamification/select-avatar ────────────────────────────────────────
// Body: { userId, avatarId }
router.post('/select-avatar', async (req, res) => {
  try {
    const { userId, avatarId } = req.body;
    if (!userId || !avatarId) return res.status(400).json({ error: 'userId and avatarId required' });

    const db = admin.firestore();
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

    const user = userDoc.data();
    const unlocked = user.unlockedAvatars || ['default'];

    if (!unlocked.includes(avatarId)) {
      return res.status(403).json({ error: 'Avatar not unlocked yet' });
    }

    await userRef.update({ avatarId });
    res.json({ success: true, avatarId });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── Helper functions ─────────────────────────────────────────────────────────

// Level system: every 200 points = 1 level, max level 10
function calculateLevel(totalPoints) {
  const pointsPerLevel = 200;
  const maxLevel = 10;

  const current     = Math.min(Math.floor(totalPoints / pointsPerLevel) + 1, maxLevel);
  const pointsIntoLevel = totalPoints % pointsPerLevel;
  const progress    = pointsIntoLevel / pointsPerLevel;
  const pointsToNext = current < maxLevel ? pointsPerLevel - pointsIntoLevel : 0;

  const labels = [
    '', 'Beginner', 'Saver', 'Smart Spender', 'Budget Pro',
    'Resilient', 'Streak Master', 'Deal Hunter', 'Finance Ninja', 'Money Sage', 'ThinkTwice Legend',
  ];

  // Avatar unlocked at each level
  const avatarUnlocks = {
    2: 'avatar_cat',
    4: 'avatar_fox',
    6: 'avatar_owl',
    8: 'avatar_lion',
    10: 'avatar_dragon',
  };

  return {
    current,
    label:        labels[current] || `Level ${current}`,
    progress,
    pointsToNext,
    avatarUnlock: avatarUnlocks[current] || null,
  };
}

// Streak info breakdown matching the UI (Risk avoidance + Smart spending)
function buildStreakInfo(user) {
  return {
    main:              user.streak               || 0,
    riskAvoidance:     user.riskAvoidanceStreak  || user.streak || 0,
    smartSpending:     user.smartSpendingStreak  || 0,
    longestStreak:     user.longestStreak        || user.streak || 0,
  };
}

// Badges — matches the badge icons in the UI
function evaluateBadges(user) {
  const streak          = user.streak          || 0;
  const totalPoints     = user.totalPoints     || 0;
  const savingsPocket   = user.savingsPocket   || 0;
  const resilienceScore = user.resilienceScore || 50;
  const smartDecision   = user.smartDecisionScore || 50;
  const claimed         = user.claimedQuests   || [];

  return [
    {
      id:          'first_save',
      title:       'First Save',
      description: 'Made your first saving',
      icon:        'star',
      earned:      savingsPocket > 0,
    },
    {
      id:          'streak_3',
      title:       '3-Day Streak',
      description: 'Maintained a 3-day saving streak',
      icon:        'fire',
      earned:      streak >= 3,
    },
    {
      id:          'streak_7',
      title:       'Week Warrior',
      description: 'Maintained a 7-day saving streak',
      icon:        'fire',
      earned:      streak >= 7,
    },
    {
      id:          'streak_14',
      title:       'Fortnight Fighter',
      description: '14-day saving streak',
      icon:        'fire',
      earned:      streak >= 14,
    },
    {
      id:          'resilience_70',
      title:       'Resilient',
      description: 'Resilience score above 70',
      icon:        'shield',
      earned:      resilienceScore >= 70,
    },
    {
      id:          'smart_decision_80',
      title:       'Smart Decider',
      description: 'Smart decision score above 80',
      icon:        'target',
      earned:      smartDecision >= 80,
    },
    {
      id:          'points_500',
      title:       'Point Collector',
      description: 'Earned 500 total points',
      icon:        'diamond',
      earned:      totalPoints >= 500,
    },
    {
      id:          'saver_100',
      title:       'Century Saver',
      description: 'Saved RM100 in pocket',
      icon:        'trophy',
      earned:      savingsPocket >= 100,
    },
    {
      id:          'streak_shield',
      title:       'Streak Shield',
      description: 'Earned by completing the 200 points quest',
      icon:        'shield',
      earned:      claimed.includes('quest_points_200'),
    },
  ];
}

// Quests — matches the challenge cards in the UI
function buildQuests(user) {
  const streak        = user.streak        || 0;
  const savingsPocket = user.savingsPocket || 0;
  const totalPoints   = user.totalPoints   || 0;
  const claimed       = user.claimedQuests || [];
  const riskStreak    = user.riskAvoidanceStreak || streak;
  const budgetSpent   = user.monthlyFoodSpend || 0; // set by Person 1's transaction pipeline

  return [
    // ── Challenge cards (matches UI exactly) ─────────────────────────────────
    {
      id:            'quest_no_overspend_3',
      title:         '3-Day No Overspending',
      description:   'Avoid overspending for 3 consecutive days',
      progress:      Math.min(riskStreak / 3, 1),
      progressLabel: `${Math.min(riskStreak, 3)} / 3 days`,
      rewardLabel:   '+150 pts',
      rewardPoints:  150,
      rewardAvatarId: null,
      isCompleted:   riskStreak >= 3,
      isClaimed:     claimed.includes('quest_no_overspend_3'),
      category:      'challenge',
    },
    {
      id:            'quest_streak_7',
      title:         '7-Day Savings Streak',
      description:   'Save consistently for 7 days',
      progress:      Math.min(streak / 7, 1),
      progressLabel: `${Math.min(streak, 7)} / 7 days`,
      rewardLabel:   '+50 pts',
      rewardPoints:  50,
      rewardAvatarId: null,
      isCompleted:   streak >= 7,
      isClaimed:     claimed.includes('quest_streak_7'),
      category:      'challenge',
    },
    {
      id:            'quest_food_budget',
      title:         'Food Budget Challenge',
      description:   'Keep food spending under RM200 this month',
      progress:      Math.min(budgetSpent / 200, 1),
      progressLabel: `RM${budgetSpent.toFixed(0)} / RM200`,
      rewardLabel:   'Cat hat',               // avatar reward
      rewardPoints:  0,
      rewardAvatarId: 'avatar_cat_hat',
      isCompleted:   budgetSpent <= 200 && budgetSpent > 0,
      isClaimed:     claimed.includes('quest_food_budget'),
      category:      'challenge',
    },

    // ── Standard quests ───────────────────────────────────────────────────────
    {
      id:            'quest_streak_3',
      title:         '3-Day Smart Streak',
      description:   'Maintain a 3-day saving streak',
      progress:      Math.min(streak / 3, 1),
      progressLabel: `${Math.min(streak, 3)} / 3 days`,
      rewardLabel:   '+50 pts',
      rewardPoints:  50,
      rewardAvatarId: null,
      isCompleted:   streak >= 3,
      isClaimed:     claimed.includes('quest_streak_3'),
      category:      'quest',
    },
    {
      id:            'quest_save_50',
      title:         'Save RM50',
      description:   'Put RM50 into your savings pocket',
      progress:      Math.min(savingsPocket / 50, 1),
      progressLabel: `RM${savingsPocket.toFixed(0)} / RM50`,
      rewardLabel:   '+80 pts',
      rewardPoints:  80,
      rewardAvatarId: null,
      isCompleted:   savingsPocket >= 50,
      isClaimed:     claimed.includes('quest_save_50'),
      category:      'quest',
    },
    {
      id:            'quest_points_200',
      title:         'Earn 200 Points',
      description:   'Accumulate 200 total points',
      progress:      Math.min(totalPoints / 200, 1),
      progressLabel: `${totalPoints} / 200 pts`,
      rewardLabel:   'Streak Shield badge',
      rewardPoints:  0,
      rewardAvatarId: null,
      isCompleted:   totalPoints >= 200,
      isClaimed:     claimed.includes('quest_points_200'),
      category:      'quest',
    },
  ];
}

module.exports = router;