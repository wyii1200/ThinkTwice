const express = require('express');
const router = express.Router();
const { getUserProfile, getTransactionsByUser, getNudgeLogs } = require('../services/firestore');

router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const [profile, transactions, nudgeLogs] = await Promise.all([
      getUserProfile(userId),
      getTransactionsByUser(userId, 10),
      getNudgeLogs(userId, 5),
    ]);

    if (!profile) return res.status(404).json({ error: 'User not found' });

    const today = new Date().toDateString();
    const todaySpend = transactions
      .filter(t => {
        const d = t.timestamp?.toDate ? t.timestamp.toDate() : new Date(t.timestamp);
        return d.toDateString() === today;
      })
      .reduce((sum, t) => sum + (t.amount || 0), 0);

    const categoryTotals = {};
    transactions.forEach(t => {
      const cat = t.category || 'Other';
      categoryTotals[cat] = (categoryTotals[cat] || 0) + (t.amount || 0);
    });

    const weekTrend = buildWeekTrend(transactions);
    const latestNudge = nudgeLogs?.[0] || null;

    res.json({
      success: true,
      dashboard: {
        resilienceScore:    profile.resilienceScore    || 50,
        smartDecisionScore: profile.smartDecisionScore || 50,
        streak:             profile.streak             || 0,
        totalPoints:        profile.totalPoints        || 0,
        dailyBudget:        profile.dailyBudget        || 50,
        savingsGoal:        profile.savingsGoal        || 500,
        savingsPocket:      profile.savingsPocket      || 0,
        currentBalance:     profile.currentBalance     || 0,
        displayName:        profile.displayName        || 'Friend',
        todaySpend,
        categoryTotals,
        weekTrend,
        recentTransactions: transactions.slice(0, 5).map(t => ({
          id:        t.id || '',
          merchant:  t.merchant || 'Unknown',
          amount:    t.amount || 0,
          category:  t.category || 'Other',
          timestamp: t.timestamp?.toDate
            ? t.timestamp.toDate().toISOString()
            : new Date(t.timestamp).toISOString(),
        })),
        latestNudge: latestNudge ? {
          nudgeText:        latestNudge.nudgeText,
          riskLevel:        latestNudge.riskLevel,
          status:           latestNudge.status,
          triggerSmartRadar: latestNudge.triggerSmartRadar || false,
          radarCategory:    latestNudge.radarCategory || null,
        } : null,
      },
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

function buildWeekTrend(transactions) {
  const days = Array(7).fill(0);
  const now = new Date();
  transactions.forEach(t => {
    const d = t.timestamp?.toDate ? t.timestamp.toDate() : new Date(t.timestamp);
    const daysAgo = Math.floor((now - d) / (1000 * 60 * 60 * 24));
    if (daysAgo >= 0 && daysAgo < 7) days[6 - daysAgo] += t.amount || 0;
  });
  return days;
}

module.exports = router;