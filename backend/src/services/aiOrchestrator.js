const axios = require('axios');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'https://thinktwice-zu5d.onrender.com';
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
        riskLabel:
        data.demoDecision?.riskLabel ||
        data.aiVisibility?.riskLabel ||
        '✅ Safe Spending',

      reason: data.riskAnalysis?.reasons?.join(', ') || '',

      humanExplanation:
        data.demoDecision?.humanExplanation ||
        data.aiVisibility?.summary ||
        'ThinkTwice checked this purchase before confirmation.',

      futureImpact:
        data.demoDecision?.futureImpact ||
        data.aiVisibility?.predictionText ||
        'Your spending currently looks manageable.',

      recommendedAction:
        data.demoDecision?.recommendedAction ||
        intervention?.humanRecommendedAction ||
        intervention?.recommendedButtonText ||
        null,

      interventionOptions:
        data.demoDecision?.interventionOptions || [
        'Continue Anyway',
        'Save RM8 Instead',
        'Find Cheaper Nearby',
      ],

      nudgeText: intervention?.nudge || null,

      suggestedAction:
        data.demoDecision?.orchestratorDecision ||
        integration?.finalAction ||
        null,

      saveAmount: intervention?.suggestedSavingsAmount || 0,
      estimatedSavings: data.demoDecision?.estimatedSavings || null,

      resilienceImpact: data.scoreAnalysis?.resilienceScore || 50,
      moneyHabitScoreImpact: data.demoDecision?.moneyHabitScoreImpact || '+1',

      streakRisk: data.riskAnalysis?.riskLevel === 'high',

      triggerSmartRadar:
        data.demoDecision?.triggerSmartRadar ||
        integration?.smartRadar?.triggerSmartRadar ||
        false,

      radarCategory: integration?.smartRadar?.radarCategory || null,
      radarMessage: integration?.smartRadar?.radarMessage || null,

      fcmPayload: integration?.fcmPayload || null,

      aiExplanation: data.aiExplanation || [],
      explainability: data.explainability,

      aiTimeline:
        data.demoDecision?.aiTimelineSimple ||
        data.aiTimeline ||
        [],

      aiVisibility: data.aiVisibility,
      demoDecision: data.demoDecision,

      severityLevel: intervention?.severityLevel || 'low',
        confidence:
          data.demoDecision?.confidence ||
          data.interventionConfidence ||
          90,

      firestorePayload: data.firestorePayload,
      fullAiResult: data,
    };

  } catch (error) {
    console.error('AI service error:', error.message);
    return {
  riskLevel: 'low',
  riskLabel: '✅ Safe Spending',
  reason: 'AI service unavailable',
  humanExplanation: 'ThinkTwice could not complete the AI check right now.',
  futureImpact: 'Your spending could not be analysed at this moment.',
  recommendedAction: 'Please try again later.',
  interventionOptions: [
    'Continue Anyway',
    'Try Again',
    'Review Budget',
  ],
  nudgeText: null,
  suggestedAction: null,
  saveAmount: 0,
  estimatedSavings: 'RM0',
  resilienceImpact: 50,
  moneyHabitScoreImpact: '+0',
  streakRisk: false,
  triggerSmartRadar: false,
  radarCategory: null,
  radarMessage: null,
  fcmPayload: null,
  aiExplanation: [],
  explainability: null,
  aiTimeline: [],
  aiVisibility: null,
  demoDecision: null,
  severityLevel: 'low',
  confidence: 0,
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
    merchant: currentTransaction.merchant || null,
    status: 'before_confirmation',
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