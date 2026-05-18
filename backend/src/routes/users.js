const express = require('express');
const router = express.Router();

const {
  updateUserProfile,
  getUserProfile,
} = require('../services/firestore');

// POST /users/setup
router.post('/setup', async (req, res) => {
  try {
    const {
      userId,
      dailyBudget,
      savingsGoal,
      fcmToken,
      lat,
      lng,
      displayName,
      breed,
      expression,
      accessory,
      effect,
      categoryPercents,
      yesAnswers,
      adaptabilityScore,
      savingsRate,
      flexibleSpend,
    } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'Missing userId',
      });
    }

    const now = new Date().toISOString();

    await updateUserProfile(userId, {
      userId,
      displayName: displayName || 'Friend',

      dailyBudget: Number(dailyBudget || 25),
      savingsGoal: Number(savingsGoal || 200),

      weeklyFoodBudget: categoryPercents && categoryPercents['Food & drinks']
        ? Number(((flexibleSpend || (dailyBudget * 30)) * (categoryPercents['Food & drinks'] / 100) / 4.3).toFixed(2))
        : 80,
      weeklySpentFood: 68,
      dailySafeLimit: Number(dailyBudget || 25),
      preferredSavingsAmount: Number(flexibleSpend && savingsRate ? ((flexibleSpend * savingsRate) / 30).toFixed(2) : 8),

      categoryPercents: categoryPercents || { 'Food & drinks': 30, 'Transport': 15, 'Bills': 20, 'Entertainment': 10, 'Shopping': 25 },
      yesAnswers: yesAnswers || [],
      adaptabilityScore: Number(adaptabilityScore || 72),
      savingsRate: Number(savingsRate || 0.2),
      flexibleSpend: Number(flexibleSpend || 1000),

      fcmToken: fcmToken || null,

      currentBalance: 1500.5,
      savingsPocket: 0,
      moneySavedThisWeek: 0,

      resilienceScore: Number(adaptabilityScore || 72),
      moneyHabitScore: Number(adaptabilityScore || 72),
      smartDecisionScore: Number(adaptabilityScore || 72),

      streak: 0,
      smartSpendingStreak: 0,
      totalPoints: 0,

      lat: lat || null,
      lng: lng || null,

      breed: breed || 'siamese',
      expression: expression || 'proud',
      accessory: accessory || 'none',
      effect: effect || 'none',
      avatarId: 'default',
      unlockedAvatars: ['default'],

      createdAt: now,
      updatedAt: now,
    });

    res.json({
      success: true,
      userId,
      message: 'ThinkTwice demo user setup completed.',
    });
  } catch (error) {
    console.error('User setup error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// PATCH /users/:userId
router.patch('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const updates = { ...req.body };

    delete updates.userId;

    await updateUserProfile(userId, {
      ...updates,
      updatedAt: new Date().toISOString(),
    });

    res.json({
      success: true,
      message: 'User profile updated.',
    });
  } catch (error) {
    console.error('User update error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// PUT /users/:userId/fcm-token
router.put('/:userId/fcm-token', async (req, res) => {
  try {
    const { userId } = req.params;
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({
        success: false,
        error: 'Missing fcmToken',
      });
    }

    await updateUserProfile(userId, {
      fcmToken,
      updatedAt: new Date().toISOString(),
    });

    res.json({
      success: true,
      message: 'FCM token updated.',
    });
  } catch (error) {
    console.error('FCM token update error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// PUT /users/:userId/location
router.put('/:userId/location', async (req, res) => {
  try {
    const { userId } = req.params;
    const { lat, lng } = req.body;

    if (lat == null || lng == null) {
      return res.status(400).json({
        success: false,
        error: 'Missing lat or lng',
      });
    }

    await updateUserProfile(userId, {
      lat: Number(lat),
      lng: Number(lng),
      updatedAt: new Date().toISOString(),
    });

    res.json({
      success: true,
      message: 'Location updated.',
    });
  } catch (error) {
    console.error('Location update error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// POST /users/demo/reset
router.post('/demo/reset', async (req, res) => {
  try {
    const { userId = 'demo_user' } = req.body || {};
    const now = new Date().toISOString();

    await updateUserProfile(userId, {
      userId,
      displayName: 'Chee Ling',
      dailyBudget: 25,
      savingsGoal: 200,
      weeklyFoodBudget: 80,
      weeklySpentFood: 68,
      dailySafeLimit: 25,
      preferredSavingsAmount: 8,

      currentBalance: 1500.5,
      savingsPocket: 0,
      moneySavedThisWeek: 0,

      resilienceScore: 50,
      moneyHabitScore: 50,
      smartDecisionScore: 50,
      streak: 0,
      smartSpendingStreak: 0,
      totalPoints: 0,

      lat: 3.1185,
      lng: 101.6779,

      avatarId: 'default',
      unlockedAvatars: ['default'],

      updatedAt: now,
    });

    res.json({
      success: true,
      userId,
      message: 'Demo user reset successfully.',
    });
  } catch (error) {
    console.error('Demo reset error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// GET /users/:userId
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const profile = await getUserProfile(userId);

    if (!profile) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    res.json({
      success: true,
      profile,
    });
  } catch (error) {
    console.error('Get user error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

module.exports = router;