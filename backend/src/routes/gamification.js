const express = require('express');
const router = express.Router();
const { getUserProfile } = require('../services/firestore');

// GET /gamification/:userId
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const profile = await getUserProfile(userId);

    if (!profile) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      gamification: {
        resilienceScore: profile.resilienceScore || 50,
        smartDecisionScore: profile.smartDecisionScore || 50,
        streak: profile.streak || 0,
        totalPoints: profile.totalPoints || 0,
        savingsPocket: profile.savingsPocket || 0,
      },
    });

  } catch (error) {
    console.error('Gamification error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;