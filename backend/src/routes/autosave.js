const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

const {
  updateResilienceScore,
  updateSavingsPocket,
} = require('../services/firestore');

const {
  transferToSavings,
} = require('../services/gxbank');

const {
  sendFCM,
} = require('../services/fcm');

// POST /autosave/approve
// User taps: Save RM8 Instead
router.post('/approve', async (req, res) => {
  try {
    const {
      userId,
      amount = 8,
      nudgeId,
      source = 'thinktwice_pre_confirmation',
    } = req.body;

    if (!userId || !amount) {
      return res.status(400).json({
        success: false,
        error: 'Missing userId or amount',
      });
    }

    const saveAmount = Number(amount);

    const transfer = await transferToSavings(userId, saveAmount);

    await updateSavingsPocket(userId, saveAmount);
    await updateResilienceScore(userId, 5);

    if (nudgeId) {
      await updateNudgeLog(nudgeId, {
        status: 'accepted',
        userAction: 'saved_money',
        source,
        amountSaved: saveAmount,
      });
    }

    await safeSendFCM(
      userId,
      'Nice save 👏',
      `RM${saveAmount} saved. Your Money Habit Score improved.`,
      {
        type: 'save_confirmed',
        amount: String(saveAmount),
        moneyHabitScoreImpact: '+5',
      }
    );

    return res.json({
      success: true,
      action: 'saved_money',
      amountSaved: saveAmount,
      moneyHabitScoreDelta: 5,
      resilienceDelta: 5,
      dashboardMessage: `Nice save 👏 RM${saveAmount} saved today.`,
      emotionalMicrocopy: 'Small savings become big habits.',
      transfer,
    });
  } catch (error) {
    console.error('Autosave approve error:', error);

    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// POST /autosave/reject
// User taps: Continue Anyway
router.post('/reject', async (req, res) => {
  try {
    const {
      userId,
      nudgeId,
      reason = 'continued_anyway',
    } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'Missing userId',
      });
    }

    await updateResilienceScore(userId, -2);

    if (nudgeId) {
      await updateNudgeLog(nudgeId, {
        status: 'ignored',
        userAction: reason,
      });
    }

    return res.json({
      success: true,
      action: reason,
      moneyHabitScoreDelta: -2,
      resilienceDelta: -2,
      dashboardMessage: 'ThinkTwice will learn from this decision.',
      emotionalMicrocopy: 'You stay in control. We’ll guide you again next time.',
    });
  } catch (error) {
    console.error('Autosave reject error:', error);

    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// POST /autosave/radar-choice
// User chooses Smart Radar / cheaper nearby option
router.post('/radar-choice', async (req, res) => {
  try {
    const {
      userId,
      nudgeId,
      estimatedSavings = 8,
      selectedMerchant = 'Cheaper nearby option',
    } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'Missing userId',
      });
    }

    const savings = Number(estimatedSavings || 8);

    await updateResilienceScore(userId, 3);

    if (nudgeId) {
      await updateNudgeLog(nudgeId, {
        status: 'accepted',
        userAction: 'opened_smart_radar',
        selectedMerchant,
        estimatedSavings: savings,
      });
    }

    await safeSendFCM(
      userId,
      'Good choice tonight 👏',
      `You could save RM${savings} by choosing a smarter nearby option.`,
      {
        type: 'smart_radar_choice',
        estimatedSavings: String(savings),
        moneyHabitScoreImpact: '+3',
      }
    );

    return res.json({
      success: true,
      action: 'opened_smart_radar',
      selectedMerchant,
      estimatedSavings: savings,
      moneyHabitScoreDelta: 3,
      resilienceDelta: 3,
      dashboardMessage: `Good choice 👏 You could save RM${savings} today.`,
      emotionalMicrocopy: 'Your future self will thank you.',
    });
  } catch (error) {
    console.error('Radar choice error:', error);

    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

async function updateNudgeLog(nudgeId, data) {
  const db = admin.firestore();

  await db.collection('nudgeLogs').doc(nudgeId).set(
    {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
}

async function safeSendFCM(userId, title, body, data) {
  try {
    return await sendFCM(userId, title, body, data);
  } catch (error) {
    console.warn('FCM skipped:', error.message);
    return null;
  }
}

module.exports = router;