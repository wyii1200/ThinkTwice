const express = require('express');
const router = express.Router();

const { saveTransaction, getTransactionsByUser, getUserProfile, logNudge } = require('../services/firestore');
const { analyzeTransaction } = require('../services/aiOrchestrator');
const { sendFCM } = require('../services/fcm');

// POST /webhook/transaction
router.post('/transaction', async (req, res) => {
  try {
    const { userId, amount, category, merchant, description } = req.body;

    if (!userId || !amount || !category) {
      return res.status(400).json({ error: 'Missing required fields: userId, amount, category' });
    }

    // 1. Save transaction to Firestore
    const transactionId = await saveTransaction({ userId, amount, category, merchant, description });
    console.log(`Transaction saved: ${transactionId}`);

    // 2. Get user profile + recent history for AI context
    const userProfile = await getUserProfile(userId);
    const userHistory = await getTransactionsByUser(userId, 10);

    // 3. Call AI orchestrator
    const aiResult = await analyzeTransaction({
      userId,
      amount,
      category,
      merchant,
      userHistory,
      userProfile,
    });

    console.log(`AI result for ${userId}:`, aiResult);

    // 4. Send push notification using FCM payload from AI
    if (aiResult.riskLevel !== 'low' && aiResult.fcmPayload?.shouldSend) {
      try {
        await sendFCM(
          userId,
          aiResult.fcmPayload.title || 'ThinkTwice 💡',
          aiResult.fcmPayload.body || aiResult.nudgeText,
          {
            riskLevel: aiResult.riskLevel,
            finalAction: aiResult.suggestedAction || '',
            triggerSmartRadar: String(aiResult.triggerSmartRadar),
            radarCategory: aiResult.radarCategory || '',
            saveAmount: String(aiResult.saveAmount || 0),
            transactionId,
            notificationType: aiResult.fcmPayload.data?.notificationType || '',
          }
        );
      } catch (fcmErr) {
        console.warn('FCM skipped (no token yet):', fcmErr.message);
      }

      // 5. Log nudge for learning loop
      await logNudge(userId, {
        transactionId,
        nudgeText: aiResult.nudgeText,
        riskLevel: aiResult.riskLevel,
        suggestedAction: aiResult.suggestedAction,
        saveAmount: aiResult.saveAmount,
        triggerSmartRadar: aiResult.triggerSmartRadar,
        radarCategory: aiResult.radarCategory,
        status: 'sent',
      });
    }

    res.json({
      success: true,
      transactionId,
      aiResult,
    });

  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;