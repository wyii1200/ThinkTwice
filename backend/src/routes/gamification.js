const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

const {
  getUserProfile,
} = require('../services/firestore');

const db = admin.firestore();

router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const [userDoc, leaderboardSnap] = await Promise.all([
      db.collection('users').doc(userId).get(),
      db.collection('users').orderBy('totalPoints', 'desc').limit(10).get(),
    ]);

    if (!userDoc.exists) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const user = userDoc.data();

    const leaderboard = leaderboardSnap.docs.map((doc, index) => ({
      rank: index + 1,
      userId: doc.id,
      displayName: doc.data().displayName || 'Player',
      totalPoints: doc.data().totalPoints || 0,
      smartSpendingStreak: doc.data().smartSpendingStreak || doc.data().streak || 0,
      avatarId: doc.data().avatarId || 'default',
      isCurrentUser: doc.id === userId,
      breed: doc.data().breed || 'siamese',
      accessory: doc.data().accessory || 'none',
      effect: doc.data().effect || 'none',
    }));

    const pointsSnap = await db.collection('pointsLog')
      .where('userId', '==', userId)
      .get();

    const recentPointsEvents = pointsSnap.docs
      .map((doc) => {
        const d = doc.data();
        let icon = 'star_rounded';
        let label = d.reason || 'Earned points';
        
        if (label.includes('quest_claimed')) {
          icon = 'emoji_events_rounded';
          label = 'Quest completed';
        } else if (label.includes('redeem_items')) {
          icon = 'shopping_bag_outlined';
          label = 'Redeemed shop items';
        } else if (label.toLowerCase().includes('deal') || label.toLowerCase().includes('verified')) {
          icon = 'map_rounded';
        } else if (label.toLowerCase().includes('save') || label.toLowerCase().includes('streak')) {
          icon = 'savings_outlined';
        }

        return {
          label: label,
          points: d.points,
          icon: icon,
          createdAt: d.createdAt,
        };
      })
      .filter(Boolean)
      .sort((a, b) => {
        const timeA = a.createdAt?.toMillis ? a.createdAt.toMillis() : 0;
        const timeB = b.createdAt?.toMillis ? b.createdAt.toMillis() : 0;
        return timeB - timeA;
      })
      .slice(0, 5);

    const level = calculateLevel(user.totalPoints || 0);
    const badges = evaluateBadges(user);
    const quests = buildQuests(user);
    const streakInfo = buildStreakInfo(user);

    const moneyHabitScore = user.moneyHabitScore || user.resilienceScore || 50;

    return res.json({
      success: true,
      gamification: {
        moneyHabitScore,
        moneySavedThisWeek: user.moneySavedThisWeek || user.savingsPocket || 0,
        smartSpendingStreak: user.smartSpendingStreak || user.streak || 0,

        resilienceScore: moneyHabitScore,
        smartDecisionScore: user.smartDecisionScore || 50,
        savingsPocket: user.savingsPocket || 0,

        totalPoints: user.totalPoints || 0,
        level: level.current,
        levelLabel: level.label,
        levelProgress: level.progress,
        pointsToNextLevel: level.pointsToNext,

        avatarId: user.avatarId || 'default',
        unlockedAvatars: user.unlockedAvatars || ['default'],

        streaks: streakInfo,
        leaderboard,
        badges,
        quests,
        recentPointsEvents,

        emotionalMicrocopy: 'Small savings become big habits.',

        moneyHabitMessage:
          moneyHabitScore >= 75
          ? 'Your spending habits look healthy this week.'
          : moneyHabitScore >= 50
          ? 'You are improving your money habits.'
          : 'ThinkTwice is helping you reduce risky spending.',
      },
    });
  } catch (error) {
    console.error('Gamification error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

router.post('/award-points', async (req, res) => {
  try {
    const { userId, points, reason } = req.body;

    if (!userId || points == null) {
      return res.status(400).json({
        success: false,
        error: 'Missing userId or points',
      });
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const user = userDoc.data();
    const safePoints = Number(points || 0);
    const newTotal = (user.totalPoints || 0) + safePoints;
    const newLevel = calculateLevel(newTotal);
    const oldLevel = calculateLevel(user.totalPoints || 0);
    const leveledUp = newLevel.current > oldLevel.current;

    const scoreDelta = safePoints > 0
      ? Math.ceil(safePoints * 0.1)
      : Math.floor(safePoints * 0.1);

    const currentScore = user.moneyHabitScore ?? user.resilienceScore ?? 50;
    const nextScore = Math.max(0, Math.min(100, currentScore + scoreDelta));

    const updates = {
      totalPoints: admin.firestore.FieldValue.increment(safePoints),
      resilienceScore: nextScore,
      moneyHabitScore: nextScore,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (leveledUp && newLevel.avatarUnlock) {
      updates.unlockedAvatars = admin.firestore.FieldValue.arrayUnion(newLevel.avatarUnlock);
    }

    await userRef.set(updates, { merge: true });

    await db.collection('pointsLog').add({
      userId,
      points: safePoints,
      reason: reason || 'manual',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      pointsAwarded: safePoints,
      newTotal,
      leveledUp,
      newLevel: newLevel.current,
      avatarUnlocked: leveledUp ? newLevel.avatarUnlock : null,
      dashboardMessage: safePoints > 0
        ? 'Nice save 👏 Your Money Habit Score improved.'
        : 'ThinkTwice will keep guiding your next decision.',
    });
  } catch (error) {
    console.error('Award points error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

router.post('/claim-quest', async (req, res) => {
  try {
    const { userId, questId } = req.body;

    if (!userId || !questId) {
      return res.status(400).json({
        success: false,
        error: 'Missing userId or questId',
      });
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const user = userDoc.data();
    const quest = buildQuests(user).find((q) => q.id === questId);

    if (!quest) {
      return res.status(404).json({ success: false, error: 'Quest not found' });
    }

    if (!quest.isCompleted) {
      return res.status(400).json({
        success: false,
        error: 'Quest not completed yet',
      });
    }

    if ((user.claimedQuests || []).includes(questId)) {
      return res.status(409).json({
        success: false,
        error: 'Already claimed',
      });
    }

    const updates = {
      claimedQuests: admin.firestore.FieldValue.arrayUnion(questId),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (quest.rewardPoints > 0) {
      updates.totalPoints = admin.firestore.FieldValue.increment(quest.rewardPoints);
    }

    if (quest.rewardAvatarId) {
      updates.unlockedAvatars = admin.firestore.FieldValue.arrayUnion(quest.rewardAvatarId);
    }

    await userRef.set(updates, { merge: true });

    await db.collection('pointsLog').add({
      userId,
      points: quest.rewardPoints,
      reason: `quest_claimed:${questId}`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      success: true,
      pointsAwarded: quest.rewardPoints,
      avatarUnlocked: quest.rewardAvatarId || null,
      dashboardMessage: 'Quest claimed. Nice progress 👏',
    });
  } catch (error) {
    console.error('Claim quest error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

router.post('/update-streak', async (req, res) => {
  try {
    const { userId, streakType = 'main', action = 'increment' } = req.body;

    if (!userId) {
      return res.status(400).json({ success: false, error: 'userId required' });
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const user = userDoc.data();
    const updates = {};

    if (action === 'increment') {
      if (streakType === 'main' || streakType === 'riskAvoidance') {
        const current = (user.streak || 0) + 1;
        updates.streak = current;
        updates.riskAvoidanceStreak = current;

        if (current === 3) updates.totalPoints = admin.firestore.FieldValue.increment(20);
        if (current === 7) updates.totalPoints = admin.firestore.FieldValue.increment(50);
        if (current === 14) updates.totalPoints = admin.firestore.FieldValue.increment(100);
        if (current === 30) updates.totalPoints = admin.firestore.FieldValue.increment(200);
      }

      if (streakType === 'smartSpending') {
        updates.smartSpendingStreak = (user.smartSpendingStreak || 0) + 1;
      }
    } else {
      if (streakType === 'main' || streakType === 'riskAvoidance') {
        updates.streak = 0;
        updates.riskAvoidanceStreak = 0;
      }

      if (streakType === 'smartSpending') {
        updates.smartSpendingStreak = 0;
      }
    }

    updates.lastStreakUpdate = admin.firestore.FieldValue.serverTimestamp();
    updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();

    await userRef.set(updates, { merge: true });

    res.json({
      success: true,
      updates,
    });
  } catch (error) {
    console.error('Update streak error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

router.post('/select-avatar', async (req, res) => {
  try {
    const { userId, avatarId } = req.body;

    if (!userId || !avatarId) {
      return res.status(400).json({
        success: false,
        error: 'userId and avatarId required',
      });
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }

    const user = userDoc.data();
    const unlocked = user.unlockedAvatars || ['default'];

    if (!unlocked.includes(avatarId)) {
      return res.status(403).json({
        success: false,
        error: 'Avatar not unlocked yet',
      });
    }

    await userRef.set({
      avatarId,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    res.json({
      success: true,
      avatarId,
    });
  } catch (error) {
    console.error('Select avatar error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

function calculateLevel(totalPoints) {
  const pointsPerLevel = 200;
  const maxLevel = 10;

  const current = Math.min(Math.floor(totalPoints / pointsPerLevel) + 1, maxLevel);
  const pointsIntoLevel = totalPoints % pointsPerLevel;
  const progress = pointsIntoLevel / pointsPerLevel;
  const pointsToNext = current < maxLevel ? pointsPerLevel - pointsIntoLevel : 0;

  const labels = [
    '',
    'Beginner',
    'Saver',
    'Smart Spender',
    'Budget Pro',
    'Resilient',
    'Streak Master',
    'Deal Hunter',
    'Finance Ninja',
    'Money Sage',
    'ThinkTwice Legend',
  ];

  const avatarUnlocks = {
    2: 'avatar_cat',
    4: 'avatar_fox',
    6: 'avatar_owl',
    8: 'avatar_lion',
    10: 'avatar_dragon',
  };

  return {
    current,
    label: labels[current] || `Level ${current}`,
    progress,
    pointsToNext,
    avatarUnlock: avatarUnlocks[current] || null,
  };
}

function buildStreakInfo(user) {
  return {
    main: user.streak || 0,
    riskAvoidance: user.riskAvoidanceStreak || user.streak || 0,
    smartSpending: user.smartSpendingStreak || 0,
    longestStreak: user.longestStreak || user.streak || 0,
  };
}

function evaluateBadges(user) {
  const streak = user.streak || 0;
  const totalPoints = user.totalPoints || 0;
  const savingsPocket = user.savingsPocket || 0;
  const moneyHabitScore = user.moneyHabitScore || user.resilienceScore || 50;
  const smartDecision = user.smartDecisionScore || 50;
  const claimed = user.claimedQuests || [];

  return [
    {
      id: 'first_save',
      title: 'First Save',
      description: 'Made your first smart save',
      icon: 'star',
      earned: savingsPocket > 0,
    },
    {
      id: 'streak_3',
      title: '3-Day Smart Streak',
      description: 'Built a 3-day smart spending streak',
      icon: 'fire',
      earned: streak >= 3,
    },
    {
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintained a 7-day smart spending streak',
      icon: 'fire',
      earned: streak >= 7,
    },
    {
      id: 'money_habit_70',
      title: 'Money Habit Builder',
      description: 'Money Habit Score above 70',
      icon: 'shield',
      earned: moneyHabitScore >= 70,
    },
    {
      id: 'smart_decision_80',
      title: 'Smart Decider',
      description: 'Smart Decision Score above 80',
      icon: 'target',
      earned: smartDecision >= 80,
    },
    {
      id: 'points_500',
      title: 'Point Collector',
      description: 'Earned 500 total points',
      icon: 'diamond',
      earned: totalPoints >= 500,
    },
    {
      id: 'saver_100',
      title: 'Century Saver',
      description: 'Saved RM100',
      icon: 'trophy',
      earned: savingsPocket >= 100,
    },
    {
      id: 'streak_shield',
      title: 'Streak Shield',
      description: 'Completed the 200 points quest',
      icon: 'shield',
      earned: claimed.includes('quest_points_200'),
    },
  ];
}

function buildQuests(user) {
  const streak = user.streak || 0;
  const savingsPocket = user.savingsPocket || 0;
  const totalPoints = user.totalPoints || 0;
  const claimed = user.claimedQuests || [];
  const riskStreak = user.riskAvoidanceStreak || streak;
  const budgetSpent = user.monthlyFoodSpend || 0;

  return [
    {
      id: 'quest_no_overspend_3',
      title: '3-Day No Overspending',
      description: 'Avoid overspending for 3 consecutive days',
      progress: Math.min(riskStreak / 3, 1),
      progressLabel: `${Math.min(riskStreak, 3)} / 3 days`,
      rewardLabel: '+150 pts',
      rewardPoints: 150,
      rewardAvatarId: null,
      isCompleted: riskStreak >= 3,
      isClaimed: claimed.includes('quest_no_overspend_3'),
      category: 'challenge',
    },
    {
      id: 'quest_streak_7',
      title: '7-Day Smart Spending Streak',
      description: 'Make healthier money decisions for 7 days',
      progress: Math.min(streak / 7, 1),
      progressLabel: `${Math.min(streak, 7)} / 7 days`,
      rewardLabel: '+50 pts',
      rewardPoints: 50,
      rewardAvatarId: null,
      isCompleted: streak >= 7,
      isClaimed: claimed.includes('quest_streak_7'),
      category: 'challenge',
    },
    {
      id: 'quest_food_budget',
      title: 'Food Budget Challenge',
      description: 'Keep food spending under RM200 this month',
      progress: Math.min(budgetSpent / 200, 1),
      progressLabel: `RM${Number(budgetSpent).toFixed(0)} / RM200`,
      rewardLabel: 'Cat hat',
      rewardPoints: 0,
      rewardAvatarId: 'avatar_cat_hat',
      isCompleted: budgetSpent <= 200 && budgetSpent > 0,
      isClaimed: claimed.includes('quest_food_budget'),
      category: 'challenge',
    },
    {
      id: 'quest_save_50',
      title: 'Save RM50',
      description: 'Put RM50 into your savings pocket',
      progress: Math.min(savingsPocket / 50, 1),
      progressLabel: `RM${Number(savingsPocket).toFixed(0)} / RM50`,
      rewardLabel: '+80 pts',
      rewardPoints: 80,
      rewardAvatarId: null,
      isCompleted: savingsPocket >= 50,
      isClaimed: claimed.includes('quest_save_50'),
      category: 'quest',
    },
    {
      id: 'quest_points_200',
      title: 'Earn 200 Points',
      description: 'Accumulate 200 total points',
      progress: Math.min(totalPoints / 200, 1),
      progressLabel: `${totalPoints} / 200 pts`,
      rewardLabel: 'Streak Shield badge',
      rewardPoints: 0,
      rewardAvatarId: null,
      isCompleted: totalPoints >= 200,
      isClaimed: claimed.includes('quest_points_200'),
      category: 'quest',
    },
  ];
}

module.exports = router;