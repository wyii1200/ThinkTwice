const express = require('express');
const router = express.Router();

const admin = require('firebase-admin');

// POST /nudge/response
// Called when user acts on a ThinkTwice intervention
router.post('/response', async (req, res) => {
  try {
    const {
      userId,
      nudgeId,
      action,
      selectedMerchant,
      estimatedSavings,
    } = req.body;

    if (!userId || !nudgeId || !action) {
      return res.status(400).json({
        success: false,
        error: 'Missing userId, nudgeId, or action',
      });
    }

    const normalizedAction = normalizeNudgeAction(action);

    const db = admin.firestore();

    await db.collection('nudgeLogs').doc(nudgeId).set(
      {
        status: normalizedAction.status,
        userAction: normalizedAction.userAction,
        learningSignal: normalizedAction.learningSignal,
        selectedMerchant: selectedMerchant || null,
        estimatedSavings: estimatedSavings || null,
        respondedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return res.json({
      success: true,
      nudgeId,
      action: normalizedAction.userAction,
      learningSignal: normalizedAction.learningSignal,
      dashboardMessage: normalizedAction.dashboardMessage,
    });
  } catch (error) {
    console.error('Nudge response error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// GET /nudge/history/:userId
router.get('/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const db = admin.firestore();

    const snapshot = await db
      .collection('nudgeLogs')
      .where('userId', '==', userId)
      .orderBy('timestamp', 'desc')
      .limit(20)
      .get();

    const nudges = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      success: true,
      nudges,
    });
  } catch (error) {
    console.error('Nudge history error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

function normalizeNudgeAction(action) {
  const value = String(action).toLowerCase();

  if (
    value === 'accepted' ||
    value === 'save_rm8' ||
    value === 'saved_money'
  ) {
    return {
      status: 'accepted',
      userAction: 'saved_money',
      learningSignal: 'positive',
      dashboardMessage: 'Nice save 👏 ThinkTwice learned this nudge helped.',
    };
  }

  if (
    value === 'opened_radar' ||
    value === 'opened_smart_radar' ||
    value === 'find_cheaper_nearby'
  ) {
    return {
      status: 'accepted',
      userAction: 'opened_smart_radar',
      learningSignal: 'positive',
      dashboardMessage:
        'Smart Radar helped the user compare cheaper nearby options.',
    };
  }

  if (
    value === 'continued_anyway' ||
    value === 'ignored' ||
    value === 'dismissed_notification'
  ) {
    return {
      status: 'ignored',
      userAction: 'continued_anyway',
      learningSignal: 'negative',
      dashboardMessage:
        'ThinkTwice will use softer guidance next time.',
    };
  }

  return {
    status: value,
    userAction: value,
    learningSignal: 'neutral',
    dashboardMessage: 'ThinkTwice recorded this response.',
  };
}

module.exports = router;