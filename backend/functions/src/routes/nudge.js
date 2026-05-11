const express = require('express');
const router = express.Router();
const { logNudge, getUserProfile } = require('../services/firestore');

// POST /nudge/response
// Called by frontend when user acts on a nudge (accepted, ignored, opened radar)
router.post('/response', async (req, res) => {
  try {
    const { userId, nudgeId, action } = req.body;
    // action: 'accepted' | 'ignored' | 'opened_radar'

    if (!userId || !nudgeId || !action) {
      return res.status(400).json({ error: 'Missing userId, nudgeId, or action' });
    }

    // Update nudge log with user's response (for learning loop)
    const admin = require('firebase-admin');
    const db = admin.firestore();
    await db.collection('nudgeLogs').doc(nudgeId).update({
      status: action,
      respondedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Nudge ${nudgeId} response: ${action} by ${userId}`);
    res.json({ success: true });

  } catch (error) {
    console.error('Nudge response error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /nudge/history/:userId
router.get('/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const admin = require('firebase-admin');
    const db = admin.firestore();
    const snapshot = await db
      .collection('nudgeLogs')
      .where('userId', '==', userId)
      .orderBy('timestamp', 'desc')
      .limit(20)
      .get();
    const nudges = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json({ success: true, nudges });
  } catch (error) {
    console.error('Nudge history error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;