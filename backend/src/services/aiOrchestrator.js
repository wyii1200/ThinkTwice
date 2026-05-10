const axios = require('axios');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';
const { saveLatestAIAnalysis } = require('./firestore');

async function analyzeTransaction(payload) {
  const { userId, amount, category, merchant, userHistory, userProfile, userAction } = payload;

  const aiRequest = {
    user_id: userId,
    daily_budget: userProfile?.dailyBudget || 50,
    current_daily_spending: calculateDailySpending(userHistory, amount),
    savings_goal: userProfile?.savingsGoal || 500,
    user_action: userAction || null,
    transactions: buildTransactionHistory(userHistory, {
      amount,
      category,
      merchant,
    }),
  };

  try {
    const response = await axios.post(
      `${AI_SERVICE_URL}/analyze-risk`,
      aiRequest,
      { timeout: 10000 }
    );

    const data = response.data;
    const integration = data.integrationPayload;
    const intervention = data.intervention;

    if (
      data.firestorePayload &&
      data.firestorePayload.collectionPath &&
      data.firestorePayload.data
  ) {
    await saveLatestAIAnalysis(
      data.firestorePayload.collectionPath,
      data.firestorePayload.data
  );
}

    return {
  riskLevel: data.riskAnalysis?.riskLevel || 'low',
  reason: data.riskAnalysis?.reasons?.join(', ') || '',
  nudgeText: intervention?.nudge || null,
  suggestedAction: integration?.finalAction || null,
  saveAmount: intervention?.suggestedSavingsAmount || 0,
  resilienceImpact: data.scoreAnalysis?.resilienceScore || 50,
  streakRisk: data.riskAnalysis?.riskLevel === 'high',
  triggerSmartRadar: integration?.smartRadar?.triggerSmartRadar || false,
  radarCategory: integration?.smartRadar?.radarCategory || null,
  radarMessage: integration?.smartRadar?.radarMessage || null,
  fcmPayload: integration?.fcmPayload || null,
  aiExplanation: data.aiExplanation || [],
  severityLevel: intervention?.severityLevel || 'low',

  fullAiResult: data,
  aiVisibility: data.aiVisibility,
  explainability: data.explainability,
  aiTimeline: data.aiTimeline,
  firestorePayload: data.firestorePayload,
};

  } catch (error) {
    console.error('AI service error:', error.message);
    return {
      riskLevel: 'low',
      reason: 'AI service unavailable',
      nudgeText: null,
      suggestedAction: null,
      saveAmount: 0,
      resilienceImpact: 0,
      streakRisk: false,
      triggerSmartRadar: false,
      radarCategory: null,
      radarMessage: null,
      fcmPayload: null,
      aiExplanation: [],
      severityLevel: 'low',
    };
  }
}

function calculateDailySpending(userHistory, currentAmount) {
  if (!userHistory || userHistory.length === 0) return currentAmount;

  const today = new Date().toDateString();
  const todayTotal = userHistory
    .filter(t => {
      if (!t.timestamp) return false;
      const txDate = t.timestamp.toDate
        ? t.timestamp.toDate()
        : new Date(t.timestamp);
      return txDate.toDateString() === today;
    })
    .reduce((sum, t) => sum + (t.amount || 0), 0);

  return todayTotal + currentAmount;
}

function buildTransactionHistory(userHistory, currentTransaction) {
  const current = {
    transaction_id: `txn_${Date.now()}`,
    amount: currentTransaction.amount,
    category: currentTransaction.category || 'other',
    time: new Date().toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
    }),
    location: currentTransaction.merchant || null,
  };

  const history = (userHistory || []).slice(0, 9).map(t => ({
    transaction_id: t.id || `txn_${Math.random()}`,
    amount: t.amount,
    category: t.category || 'other',
    time: t.timestamp
      ? (t.timestamp.toDate
          ? t.timestamp.toDate()
          : new Date(t.timestamp)
        ).toLocaleTimeString('en-US', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: true,
        })
      : '12:00 PM',
    location: t.merchant || null,
  }));

  return [current, ...history];
}

module.exports = { analyzeTransaction };