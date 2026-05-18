const axios = require('axios');

const AI_SERVICE_URL =
  process.env.AI_SERVICE_URL || 'https://thinktwice-guq9.onrender.com';

const { saveLatestAIAnalysis } = require('./firestore');

async function analyzeTransaction(payload) {
  const {
    userId,
    amount,
    category,
    merchant,
    location,
    userHistory,
    userProfile,
    userAction,
    demoScenario,
  } = payload;

  const aiRequest = {
    user_id: userId || 'demo_user',
    daily_budget: userProfile?.dailyBudget || 25,
    current_daily_spending: calculateDailySpending(userHistory, amount),
    savings_goal: userProfile?.savingsGoal || 200,
    demo_scenario: demoScenario || 'bubble_tea_high_risk',
    user_action: userAction || null,
    transactions: buildTransactionHistory(userHistory, {
      amount,
      category,
      merchant,
      location,
    }),
    budget_profile: {
      weekly_food_budget: userProfile?.weeklyFoodBudget || 80,
      weekly_spent_food: userProfile?.weeklySpentFood || 68,
      daily_safe_limit: userProfile?.dailySafeLimit || 25,
      preferred_savings_amount: userProfile?.preferredSavingsAmount || 8,
    },
  };

  try {
    const response = await axios.post(
      `${AI_SERVICE_URL}/analyze-risk`,
      aiRequest,
      { timeout: 10000 }
    );

    const data = response.data || {};
    const integration = data.integrationPayload || {};
    const intervention = data.intervention || {};
    const demoDecision = data.demoDecision || {};
    const aiVisibility = data.aiVisibility || {};

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
      riskLevel: data.riskAnalysis?.riskLevel || demoDecision.riskLevel || 'low',
      riskLabel:
        data.riskAnalysis?.riskLabel ||
        demoDecision.riskLabel ||
        aiVisibility.riskLabel ||
        '✅ Safe Spending',

      reason: data.riskAnalysis?.reasons?.join(', ') || '',
      reasons: data.riskAnalysis?.reasons || demoDecision.reasons || [],

      nudgeText:
        intervention?.llmEnhancedNudge ||
        intervention?.nudge ||
        demoDecision?.humanExplanation ||
        null,

      suggestedAction:
        integration?.finalAction ||
        demoDecision?.orchestratorDecision ||
        null,

      recommendedAction:
        demoDecision?.recommendedAction ||
        aiVisibility?.recommendedActionText ||
        intervention?.recommendedButtonText ||
        null,

      saveAmount:
        intervention?.suggestedSavingsAmount ||
        parseSavingsAmount(demoDecision?.estimatedSavings) ||
        0,

      estimatedSavings:
        demoDecision?.estimatedSavings ||
        integration?.smartRadar?.estimatedSavings ||
        `RM${intervention?.suggestedSavingsAmount || 0}`,

      resilienceImpact:
        data.scoreAnalysis?.moneyHabitScore ||
        data.scoreAnalysis?.resilienceScore ||
        50,

      moneyHabitScore:
        data.scoreAnalysis?.moneyHabitScore ||
        data.scoreAnalysis?.resilienceScore ||
        50,

      smartDecisionScore:
        data.scoreAnalysis?.smartDecisionScore || 50,

      moneyHabitScoreImpact:
        demoDecision?.moneyHabitScoreImpact || '+1',

      streakRisk:
        (data.riskAnalysis?.riskLevel || '').toLowerCase() === 'high',

      triggerSmartRadar:
        integration?.smartRadar?.triggerSmartRadar ||
        demoDecision?.triggerSmartRadar ||
        false,

      radarCategory:
        integration?.smartRadar?.radarCategory ||
        data.transactionIntent?.category ||
        category ||
        null,

      radarMessage:
        integration?.smartRadar?.radarMessage ||
        integration?.smartRadar?.aiReasoning ||
        null,

      smartRadar: integration?.smartRadar || null,

      notification: integration?.notification || null,
      fcmPayload: integration?.fcmPayload || null,

      aiExplanation:
        data.explanation?.aiExplanation ||
        data.aiExplanation ||
        data.explainability?.reasons ||
        [],

      severityLevel: intervention?.severityLevel || 'low',
      interventionConfidence:
        data.interventionConfidence ||
        demoDecision?.confidence ||
        90,

      behaviourSeverityScore: data.behaviourSeverityScore || 0,

      aiVisibility: data.aiVisibility || null,
      explainability: data.explainability || null,
      aiTimeline: data.aiTimeline || [],
      decisionLayer: data.decisionLayer || null,
      demoDecision,
      transactionIntent: data.transactionIntent || demoDecision.transactionIntent,
      integrationPayload: integration,
      firestorePayload: data.firestorePayload || null,

      fullAiResult: data,
      fallbackUsed: false,
    };
    } catch (error) {
    console.error('AI service error:', error.message);

    const fallback = buildDemoFallback({
      userId,
      amount,
      category,
      merchant,
      location,
    });

    try {
      await saveLatestAIAnalysis(
        `users/${userId || 'demo_user'}/ai/latest_ai_analysis`,
        {
          userId: userId || 'demo_user',
          riskLevel: fallback.riskLevel,
          riskLabel: fallback.riskLabel,
          prediction: fallback.demoDecision.futureImpact,
          recommendedAction: fallback.recommendedAction,
          finalAction: fallback.suggestedAction,
          triggerSmartRadar: fallback.triggerSmartRadar,
          radarCategory: fallback.radarCategory,
          estimatedSavings: fallback.estimatedSavings,
          interventionConfidence: fallback.interventionConfidence,
          behaviourSeverityScore: fallback.behaviourSeverityScore,
          resilienceScore: fallback.moneyHabitScore,
          moneyHabitScore: fallback.moneyHabitScore,
          smartDecisionScore: fallback.smartDecisionScore,
          moneyHabitScoreImpact: fallback.moneyHabitScoreImpact,
          reasons: fallback.reasons,
        }
      );
    } catch (firestoreError) {
      console.warn(
        'Fallback AI analysis was not saved:',
        firestoreError.message
      );
    }

    return fallback;
  }
}

function calculateDailySpending(userHistory, currentAmount) {
  const safeCurrentAmount = Number(currentAmount || 0);

  if (!userHistory || userHistory.length === 0) {
    return safeCurrentAmount;
  }

  const today = new Date().toDateString();

  const todayTotal = userHistory
    .filter((transaction) => {
      if (!transaction.timestamp) return false;

      const txDate = transaction.timestamp.toDate
        ? transaction.timestamp.toDate()
        : new Date(transaction.timestamp);

      return txDate.toDateString() === today;
    })
    .reduce((sum, transaction) => {
      return sum + Number(transaction.amount || 0);
    }, 0);

  return todayTotal + safeCurrentAmount;
}

function buildTransactionHistory(userHistory, currentTransaction) {
  const history = (userHistory || []).slice(0, 9).map((transaction) => ({
    transaction_id: transaction.id || `txn_${Math.random()}`,
    amount: Number(transaction.amount || 0),
    category: transaction.category || 'other',
    merchant: transaction.merchant || transaction.description || null,
    time: transaction.timestamp
      ? convertTimestampToTime(transaction.timestamp)
      : '12:00 PM',
    location: transaction.location || transaction.merchant || null,
    status: transaction.status || 'completed',
  }));

  const current = {
    transaction_id: `txn_${Date.now()}`,
    amount: Number(currentTransaction.amount || 0),
    category: currentTransaction.category || 'food',
    merchant: currentTransaction.merchant || 'Bubble Tea',
    time: new Date().toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
    }),
    location:
      currentTransaction.location ||
      currentTransaction.merchant ||
      'Mid Valley',
    status: 'before_confirmation',
  };

  // Important:
  // Our AI reads the latest transaction as the LAST item.
  return [...history, current];
}

function convertTimestampToTime(timestamp) {
  const txDate = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);

  return txDate.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: true,
  });
}

function parseSavingsAmount(value) {
  if (!value) return 0;

  const matched = String(value).match(/\d+(\.\d+)?/);

  if (!matched) return 0;

  return Number(matched[0]);
}

function buildDemoFallback({ userId, amount, category, merchant, location }) {
  const safeAmount = Number(amount || 18);
  const safeCategory = category || 'food';
  const safeMerchant = merchant || 'Bubble Tea';
  const safeLocation = location || 'Mid Valley';

  const isSafeTransport =
    safeCategory === 'transport' && safeAmount <= 10;

  const riskLevel = isSafeTransport ? 'low' : 'high';
  const triggerSmartRadar = !isSafeTransport;
  const estimatedSavings = triggerSmartRadar ? 'RM8' : 'RM0';

  const riskLabel = isSafeTransport
    ? '✅ Safe Spending'
    : '🔥 Impulse Spending Detected';

  const humanExplanation = isSafeTransport
    ? 'This purchase looks manageable based on your current spending pattern.'
    : `You’ve been spending more on ${safeCategory} than usual tonight.`;

  const futureImpact = isSafeTransport
    ? 'Your spending currently looks manageable.'
    : 'At this rate, your weekly food budget may exceed within 2 days.';

  const recommendedAction = isSafeTransport
    ? 'You can continue safely.'
    : 'Want to save RM8 or find a cheaper option nearby?';

  const demoDecision = {
    transactionIntent: {
      merchant: safeMerchant,
      amount: safeAmount,
      category: safeCategory,
      location: safeLocation,
      status: 'before_confirmation',
    },
    riskLevel: riskLevel.toUpperCase(),
    riskLabel,
    humanExplanation,
    futureImpact,
    recommendedAction,
    interventionOptions: [
      'Continue Anyway',
      triggerSmartRadar ? 'Save RM8 Instead' : 'Continue',
      triggerSmartRadar ? 'Find Cheaper Nearby' : 'View Progress',
    ],
    triggerSmartRadar,
    estimatedSavings,
    orchestratorDecision: triggerSmartRadar
      ? 'smart_radar_and_save_nudge'
      : 'safe_spending_reward',
    moneyHabitScoreImpact: triggerSmartRadar ? '+3' : '+1',
    confidence: triggerSmartRadar ? 92 : 88,
    aiTimelineSimple: triggerSmartRadar
      ? [
          'Payment intent detected',
          'Spending behaviour analysed',
          'Overspending risk predicted',
          'Intervention options generated',
          'Smart Radar activated',
        ]
      : [
          'Payment intent detected',
          'Spending behaviour analysed',
          'Purchase marked safe',
          'Positive feedback prepared',
        ],
    reasons: triggerSmartRadar
      ? [
          'Food spending is higher than usual today.',
          'ThinkTwice is checking this purchase before payment confirmation.',
          'This purchase may be an impulse spending decision.',
        ]
      : [
          'This purchase fits your current spending pattern.',
        ],
  };

  return {
    riskLevel,
    riskLabel,
    reason: demoDecision.reasons.join(', '),
    reasons: demoDecision.reasons,
    nudgeText: humanExplanation,
    suggestedAction: demoDecision.orchestratorDecision,
    recommendedAction,
    saveAmount: triggerSmartRadar ? 8 : 0,
    estimatedSavings,
    resilienceImpact: triggerSmartRadar ? 58 : 78,
    moneyHabitScore: triggerSmartRadar ? 58 : 78,
    smartDecisionScore: triggerSmartRadar ? 60 : 82,
    moneyHabitScoreImpact: demoDecision.moneyHabitScoreImpact,
    streakRisk: triggerSmartRadar,
    triggerSmartRadar,
    radarCategory: safeCategory,
    radarMessage: triggerSmartRadar
      ? 'AI found cheaper nearby choices that could help you save RM8.'
      : null,
    smartRadar: {
      triggerSmartRadar,
      radarCategory: safeCategory,
      radarMessage: triggerSmartRadar
        ? 'AI found cheaper nearby choices that could help you save RM8.'
        : 'No Smart Radar needed for this safe purchase.',
      estimatedSavings,
      recommendedRoute: triggerSmartRadar ? '/smart-radar' : null,
      openMode: triggerSmartRadar ? 'auto_expand' : 'none',
    },
    notification: {
      sendPushNotification: triggerSmartRadar,
      notificationTitle: riskLabel,
      notificationBody: futureImpact,
      notificationType: 'PRE_CONFIRMATION_NUDGE',
    },
    fcmPayload: {
      shouldSend: triggerSmartRadar,
      title: riskLabel,
      body: futureImpact,
      data: {
        finalAction: demoDecision.orchestratorDecision,
        triggerSmartRadar: String(triggerSmartRadar),
        radarCategory: safeCategory,
        notificationType: 'PRE_CONFIRMATION_NUDGE',
      },
    },
    aiExplanation: demoDecision.reasons,
    severityLevel: triggerSmartRadar ? 'high' : 'low',
    interventionConfidence: demoDecision.confidence,
    behaviourSeverityScore: triggerSmartRadar ? 87 : 25,
    aiVisibility: {
      title: 'ThinkTwice AI Analysis',
      riskLabel,
      riskColor: triggerSmartRadar ? 'red' : 'green',
      summary: humanExplanation,
      bulletReasons: demoDecision.reasons,
      predictionText: futureImpact,
      recommendedActionText: recommendedAction,
      confidenceText: `${demoDecision.confidence}%`,
      severityScoreText: triggerSmartRadar ? '87/100' : '25/100',
      riskTags: triggerSmartRadar
        ? ['Food Overspending', 'Impulse Spending']
        : ['Safe Spending'],
      recommendationPriority: triggerSmartRadar ? 'urgent' : 'low',
      isAiMonitoringLive: true,
      aiStatus: 'Checking if this purchase may affect your budget...',
    },
    explainability: {
      question: 'Why am I seeing this?',
      reasons: demoDecision.reasons,
      transparencyNote:
        'ThinkTwice only recommends actions. Financial actions always require user approval.',
    },
    aiTimeline: demoDecision.aiTimelineSimple.map((event, index) => ({
      step: index + 1,
      event,
    })),
    demoDecision,
    transactionIntent: demoDecision.transactionIntent,
    integrationPayload: {
      userId: userId || 'demo_user',
      transactionIntent: demoDecision.transactionIntent,
      finalAction: demoDecision.orchestratorDecision,
      smartRadar: {
        triggerSmartRadar,
        radarCategory: safeCategory,
        radarMessage: triggerSmartRadar
          ? 'AI found cheaper nearby choices that could help you save RM8.'
          : 'No Smart Radar needed for this safe purchase.',
        estimatedSavings,
      },
    },
    firestorePayload: null,
    fullAiResult: null,
    fallbackUsed: true,
  };
}

module.exports = { analyzeTransaction };