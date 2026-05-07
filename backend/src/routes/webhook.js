const express = require('express');
const router = express.Router();

const { saveTransaction, getTransactionsByUser, getUserProfile } = require('../services/firestore');
const { analyzeTransaction } = require('../services/aiOrchestrator');
const { sendFCM } = require('../services/fcm');
const { logNudge } = require('../services/firestore');

// POST /webhook/transaction
// Called by GXBank (or your mock) when a transaction happens
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
    const [userProfile, userHistory] = await Promise.all([
      getUserProfile(userId),
      getTransactionsByUser(userId, 10),
    ]);

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

    // 4. Send push notification if risk is medium or high
    if (aiResult.riskLevel !== 'low' && aiResult.nudgeText) {
      await sendFCM(
        userId,
        'ThinkTwice 💡',
        aiResult.nudgeText,
        {
          riskLevel: aiResult.riskLevel,
          suggestedAction: aiResult.suggestedAction || '',
          saveAmount: String(aiResult.saveAmount || 0),
          transactionId,
        }
      );

      // 5. Log nudge for learning loop
      await logNudge(userId, {
        transactionId,
        nudgeText: aiResult.nudgeText,
        riskLevel: aiResult.riskLevel,
        suggestedAction: aiResult.suggestedAction,
        saveAmount: aiResult.saveAmount,
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