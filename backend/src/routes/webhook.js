const express = require('express');
const router = express.Router();
const axios = require('axios');

const {
  saveTransaction,
  getTransactionsByUser,
  getUserProfile,
  logNudge,
  deductBalance,
} = require('../services/firestore');

const {
  analyzeTransaction,
} = require('../services/aiOrchestrator');

const {
  sendFCM,
} = require('../services/fcm');

// POST /webhook/transaction
// Pre-confirmation payment intent analysis
router.post('/transaction', async (req, res) => {
  try {
    const {
      userId,
      amount,
      category,
      merchant,
      description,
      location,
      userAction,
      lat,
      lng,
      demoScenario,
      autoConfirm = false,
    } = req.body;

    if (!userId || !amount || !category) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: userId, amount, category',
      });
    }

    const userProfile = await getUserProfile(userId);
    const userHistory = await getTransactionsByUser(userId, 10);

    const aiResult = await analyzeTransaction({
      userId,
      amount,
      category,
      merchant,
      location,
      userHistory,
      userProfile,
      userAction: userAction || null,
      demoScenario: demoScenario || 'bubble_tea_high_risk',
    });

    let smartRadarPreview = null;

    if (aiResult.triggerSmartRadar && aiResult.radarCategory) {
      try {
        const userLat = lat || userProfile?.lat || 3.1390;
        const userLng = lng || userProfile?.lng || 101.6869;

        const radarResponse = await axios.post(
          'https://thinktwice-zu5d.onrender.com/radar/nearby',
          {
            lat: userLat,
            lng: userLng,
            category: aiResult.radarCategory,
            radius: 2000,
          },
          { timeout: 8000 }
        );

        smartRadarPreview = radarResponse.data || null;
      } catch (radarErr) {
        console.warn('Smart Radar preload failed:', radarErr.message);
      }
    }

    let nudgeId = null;

    if (aiResult.riskLevel !== 'low') {
      nudgeId = await logNudge(userId, {
        transactionAmount: amount,
        merchant: merchant || null,
        category,
        description: description || null,
        nudgeText: aiResult.nudgeText,
        riskLevel: aiResult.riskLevel,
        riskLabel: aiResult.riskLabel,
        suggestedAction: aiResult.suggestedAction,
        saveAmount: aiResult.saveAmount,
        triggerSmartRadar: aiResult.triggerSmartRadar,
        radarCategory: aiResult.radarCategory,
        status: 'pre_confirmation',
      });
    }

    if (aiResult.riskLevel !== 'low' && aiResult.fcmPayload?.shouldSend) {
      await sendFCM(
        userId,
        aiResult.fcmPayload.title || aiResult.riskLabel || 'ThinkTwice AI',
        aiResult.fcmPayload.body || aiResult.nudgeText || '',
        {
          riskLevel: aiResult.riskLevel,
          riskLabel: aiResult.riskLabel || '',
          finalAction: aiResult.suggestedAction || '',
          triggerSmartRadar: String(aiResult.triggerSmartRadar),
          radarCategory: aiResult.radarCategory || '',
          saveAmount: String(aiResult.saveAmount || 0),
          nudgeId: nudgeId || '',
          notificationType:
            aiResult.fcmPayload.data?.notificationType ||
            'PRE_CONFIRMATION_NUDGE',
        }
      );
    }

    let transactionId = null;
    let newBalance = null;

    if (autoConfirm === true) {
      transactionId = await saveTransaction({
        userId,
        amount,
        category,
        merchant,
        description,
        location,
        status: 'completed',
      });

      newBalance = await deductBalance(userId, amount);
    }

    return res.json({
      success: true,
      mode: 'PRE_CONFIRMATION_INTERVENTION',
      transactionStatus: autoConfirm
        ? 'completed'
        : 'awaiting_user_decision',
      transactionId,
      newBalance,
      nudgeId,
      aiResult,
      smartRadarPreview,
      nextStep: {
        recommendedAction: aiResult.recommendedAction,
        availableOptions:
          aiResult.demoDecision?.interventionOptions || [
            'Continue Anyway',
            'Save RM8 Instead',
            'Find Cheaper Nearby',
          ],
      },
    });
  } catch (error) {
    console.error('Webhook error:', error);

    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

// POST /webhook/transaction/confirm
router.post('/transaction/confirm', async (req, res) => {
  try {
    const {
      userId,
      amount,
      category,
      merchant,
      description,
      location,
    } = req.body;

    if (!userId || !amount || !category) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields',
      });
    }

    const transactionId = await saveTransaction({
      userId,
      amount,
      category,
      merchant,
      description,
      location,
      status: 'completed',
    });

    const newBalance = await deductBalance(userId, amount);

    return res.json({
      success: true,
      message: 'Transaction confirmed successfully.',
      transactionId,
      newBalance,
    });
  } catch (error) {
    console.error('Confirm transaction error:', error);

    return res.status(500).json({
      success: false,
      error: 'Failed to confirm transaction',
    });
  }
});

module.exports = router;