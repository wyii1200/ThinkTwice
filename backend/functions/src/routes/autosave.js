const express = require('express');
const router = express.Router();
const { updateResilienceScore, updateSavingsPocket } = require('../services/firestore');
const { transferToSavings } = require('../services/gxbank');
const { sendFCM } = require('../services/fcm');

// POST /autosave/approve
router.post('/approve', async (req, res) => {
  try {
    const { userId, amount, nudgeId } = req.body;

    if (!userId || !amount) {
      return res.status(400).json({ error: 'Missing userId or amount' });
    }

    // 1. Transfer to savings (GXBank mock)
    const transfer = await transferToSavings(userId, amount);

    // 2. Update Firestore savings pocket
    await updateSavingsPocket(userId, amount);

    // 3. Update resilience score (+5 for completing a save)
    await updateResilienceScore(userId, 5);

    // 4. Update nudge log status if nudgeId provided
    if (nudgeId) {
      const admin = require('firebase-admin');
      const db = admin.firestore();
      await db.collection('nudgeLogs').doc(nudgeId).set({
        status: 'accepted',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }

    // 5. Send confirmation notification (skip if no FCM token, won't crash)
    try {
      await sendFCM(
        userId,
        'Nice work! 🎯',
        `RM${amount} saved. Your resilience score went up!`,
        { type: 'save_confirmed', amount: String(amount) }
      );
    } catch (fcmErr) {
      console.warn('FCM skipped (no token yet):', fcmErr.message);
    }

    res.json({
      success: true,
      amountSaved: amount,
      resilienceDelta: 5,
      transfer,
    });

  } catch (error) {
    console.error('Autosave approve error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /autosave/reject
router.post('/reject', async (req, res) => {
  try {
    const { userId, nudgeId } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    // Update resilience score (-2 for ignoring)
    await updateResilienceScore(userId, -2);

    if (nudgeId) {
      const admin = require('firebase-admin');
      const db = admin.firestore();
      await db.collection('nudgeLogs').doc(nudgeId).set({
        status: 'ignored',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }

    res.json({ success: true, resilienceDelta: -2 });

  } catch (error) {
    console.error('Autosave reject error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;