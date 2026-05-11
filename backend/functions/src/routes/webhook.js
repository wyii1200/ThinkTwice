const express = require('express');
const router = express.Router();

const { saveTransaction, getTransactionsByUser, getUserProfile, logNudge, deductBalance } = require('../services/firestore');
const { analyzeTransaction } = require('../services/aiOrchestrator');
const { sendFCM } = require('../services/fcm');

// POST /webhook/transaction
router.post('/transaction', async (req, res) => {
  try {
    const { userId, amount, category, merchant, description, userAction, lat, lng } = req.body;

    if (!userId || !amount || !category) {
      return res.status(400).json({ error: 'Missing required fields: userId, amount, category' });
    }

    // 1. Save transaction to Firestore and deduct from balance
    const transactionId = await saveTransaction({ userId, amount, category, merchant, description });
    const newBalance = await deductBalance(userId, amount);
    console.log(`Transaction saved: ${transactionId} | New balance: ${newBalance}`);

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
      userAction: userAction || null,
    });

    console.log(`AI result for ${userId}:`, aiResult);

    // 4. Trigger Smart Radar independently of FCM
    if (aiResult.triggerSmartRadar && aiResult.radarCategory) {
      try {
        const axios = require('axios');
        const userLat = lat || userProfile?.lat || 3.1390;
        const userLng = lng || userProfile?.lng || 101.6869;
        await axios.post('https://thinktwice-zu5d.onrender.com/radar/nearby', {
          lat: userLat,
          lng: userLng,
          category: aiResult.radarCategory,
          radius: 2000,
        });
        console.log(`Smart Radar triggered for category: ${aiResult.radarCategory}`);
      } catch (radarErr) {
        console.warn('Smart Radar trigger failed:', radarErr.message);
      }
    }

    // 5. Log nudge for learning loop (always, regardless of FCM)
    if (aiResult.riskLevel !== 'low') {
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

    // 6. Send push notification if applicable
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
    }

    res.json({
      success: true,
      transactionId,
      newBalance,
      aiResult,
    });

  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;