const express = require('express');
const router = express.Router();

const {
  getUserProfile,
  getTransactionsByUser,
  getNudgeLogs,
  getLatestAIAnalysis,
} = require('../services/firestore');

router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const [
      profile,
      transactions,
      nudgeLogs,
      latestAI,
    ] = await Promise.all([
      getUserProfile(userId),
      getTransactionsByUser(userId, 10),
      getNudgeLogs(userId, 5),
      getLatestAIAnalysis(userId),
    ]);

    if (!profile) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
      });
    }

    const todaySpend = calculateTodaySpend(transactions);
    const categoryTotals = buildCategoryTotals(transactions);
    const weekTrend = buildWeekTrend(transactions);
    const latestNudge = nudgeLogs?.[0] || null;

    const moneyHabitScore =
      profile.moneyHabitScore ??
      profile.resilienceScore ??
      latestAI?.moneyHabitScore ??
      50;

    const moneySavedThisWeek =
      profile.moneySavedThisWeek ??
      profile.savingsPocket ??
      0;

    return res.json({
      success: true,
      dashboard: {
        displayName: profile.displayName || 'Friend',

        // New final demo labels
        moneyHabitScore,
        moneyHabitLabel:
          latestAI?.riskLevel === 'high'
            ? 'Needs Attention'
            : 'Good Money Habits',
        moneySavedThisWeek,
        smartSpendingStreak:
          profile.smartSpendingStreak ||
          profile.streakStatus ||
          latestAI?.streakStatus ||
          'Building',

        // Old keys kept for compatibility
        resilienceScore: moneyHabitScore,
        smartDecisionScore:
          profile.smartDecisionScore ||
          latestAI?.smartDecisionScore ||
          50,
        streak: profile.streak || 0,
        totalPoints: profile.totalPoints || 0,

        dailyBudget: profile.dailyBudget || 50,
        savingsGoal: profile.savingsGoal || 500,
        savingsPocket: profile.savingsPocket || 0,
        currentBalance: profile.currentBalance || 0,

        todaySpend,
        categoryTotals,
        weekTrend,

        latestAI: latestAI
          ? {
              riskLevel: latestAI.riskLevel,
              riskLabel: latestAI.riskLabel,
              prediction: latestAI.prediction,
              recommendedAction: latestAI.recommendedAction,
              finalAction: latestAI.finalAction,
              triggerSmartRadar: latestAI.triggerSmartRadar || false,
              radarCategory: latestAI.radarCategory || null,
              estimatedSavings: latestAI.estimatedSavings || null,
              confidence:
                latestAI.interventionConfidence || null,
              behaviourSeverityScore:
                latestAI.behaviourSeverityScore || null,
              moneyHabitScoreImpact:
                latestAI.moneyHabitScoreImpact || null,
              reasons: latestAI.reasons || [],
            }
          : null,

        latestNudge: latestNudge
          ? {
              id: latestNudge.id,
              nudgeText: latestNudge.nudgeText,
              riskLevel: latestNudge.riskLevel,
              riskLabel: latestNudge.riskLabel || null,
              status: latestNudge.status,
              suggestedAction: latestNudge.suggestedAction || null,
              saveAmount: latestNudge.saveAmount || 0,
              triggerSmartRadar:
                latestNudge.triggerSmartRadar || false,
              radarCategory: latestNudge.radarCategory || null,
            }
          : null,

        recentTransactions: transactions.slice(0, 5).map((transaction) => ({
          id: transaction.id || '',
          merchant: transaction.merchant || 'Unknown',
          amount: transaction.amount || 0,
          category: transaction.category || 'Other',
          status: transaction.status || 'completed',
          timestamp: toIsoString(transaction.timestamp),
        })),

        dashboardMessage:
          latestAI?.recommendedAction ||
          'ThinkTwice is helping you build better money habits.',

        emotionalMicrocopy:
          latestAI?.triggerSmartRadar
            ? 'Small savings become big habits.'
            : 'Good choices today build stronger habits.',
      },
    });
  } catch (error) {
    console.error('Dashboard error:', error);

    res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

function calculateTodaySpend(transactions) {
  const today = new Date().toDateString();

  return transactions
    .filter((transaction) => {
      const date = toDate(transaction.timestamp);
      return date && date.toDateString() === today;
    })
    .reduce((sum, transaction) => {
      return sum + Number(transaction.amount || 0);
    }, 0);
}

function buildCategoryTotals(transactions) {
  const categoryTotals = {};

  transactions.forEach((transaction) => {
    const category = transaction.category || 'Other';

    categoryTotals[category] =
      (categoryTotals[category] || 0) +
      Number(transaction.amount || 0);
  });

  return categoryTotals;
}

function buildWeekTrend(transactions) {
  const days = Array(7).fill(0);
  const now = new Date();

  transactions.forEach((transaction) => {
    const date = toDate(transaction.timestamp);
    if (!date) return;

    const daysAgo = Math.floor(
      (now - date) / (1000 * 60 * 60 * 24)
    );

    if (daysAgo >= 0 && daysAgo < 7) {
      days[6 - daysAgo] += Number(transaction.amount || 0);
    }
  });

  return days;
}

function toDate(value) {
  if (!value) return null;

  if (value.toDate) {
    return value.toDate();
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return date;
}

function toIsoString(value) {
  const date = toDate(value);
  return date ? date.toISOString() : null;
}

module.exports = router;