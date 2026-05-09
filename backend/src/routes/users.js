const express = require('express');
const router = express.Router();
const { updateUserProfile, getUserProfile } = require('../services/firestore');

// POST /users/setup
router.post('/setup', async (req, res) => {
  try {
    const { userId, dailyBudget, savingsGoal, fcmToken, lat, lng, displayName } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    await updateUserProfile(userId, {
      userId,
      displayName: displayName || 'Friend',
      dailyBudget: dailyBudget || 50,
      savingsGoal: savingsGoal || 500,
      fcmToken: fcmToken || null,
      resilienceScore: 50,
      savingsPocket: 0,
      streak: 0,
      smartDecisionScore: 0,
      currentBalance: 1500.50,
      lat: lat || null,
      lng: lng || null,
      createdAt: new Date().toISOString(),
    });

    res.json({ success: true, userId });
  } catch (error) {
    console.error('User setup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /users/:userId/fcm-token
router.put('/:userId/fcm-token', async (req, res) => {
  try {
    const { userId } = req.params;
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({ error: 'Missing fcmToken' });
    }

    await updateUserProfile(userId, { fcmToken });
    res.json({ success: true });
  } catch (error) {
    console.error('FCM token update error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /users/:userId/location
router.put('/:userId/location', async (req, res) => {
  try {
    const { userId } = req.params;
    const { lat, lng } = req.body;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'Missing lat or lng' });
    }

    await updateUserProfile(userId, { lat, lng });
    res.json({ success: true });
  } catch (error) {
    console.error('Location update error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /users/:userId
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const profile = await getUserProfile(userId);

    if (!profile) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, profile });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;