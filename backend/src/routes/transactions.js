const express = require('express');
const router = express.Router();

const {
  getTransactionsByUser,
} = require('../services/firestore');

const {
  analyzeTransaction,
} = require('../services/aiOrchestrator');

// POST /transactions/analyze
router.post('/analyze', async (req, res) => {
  try {
    const {
      userId = 'demo_user',
      amount = 18,
      category = 'food',
      merchant = 'Bubble Tea',
      location = 'Mid Valley',
      userHistory = [],
      userProfile = {},
      userAction = null,
      demoScenario = 'bubble_tea_high_risk',
    } = req.body || {};

    const aiResult = await analyzeTransaction({
      userId,
      amount,
      category,
      merchant,
      location,
      userHistory,
      userProfile,
      userAction,
      demoScenario,
    });

    return res.json({
      success: true,
      message: 'Transaction analysed before payment confirmation.',
      transactionStatus: 'before_confirmation',
      aiResult,
    });
  } catch (error) {
    console.error('Analyze transaction error:', error);

    return res.status(500).json({
      success: false,
      error: 'Failed to analyse transaction',
    });
  }
});

// POST /transactions/demo/:scenario
router.post('/demo/:scenario', async (req, res) => {
  try {
    const { scenario } = req.params;

    const demoPayload = buildDemoScenarioPayload(
      scenario,
      req.body || {}
    );

    const aiResult = await analyzeTransaction(demoPayload);

    return res.json({
      success: true,
      scenario,
      message: 'Demo transaction analysed successfully.',
      transactionStatus: 'before_confirmation',
      aiResult,
    });
  } catch (error) {
    console.error('Demo transaction error:', error);

    return res.status(500).json({
      success: false,
      error: 'Failed to run demo scenario',
    });
  }
});

// GET /transactions/:userId
// Keep this AFTER /analyze and /demo/:scenario
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit, 10) || 20;

    const transactions = await getTransactionsByUser(userId, limit);

    return res.json({
      success: true,
      transactions,
    });
  } catch (error) {
    console.error('Get transactions error:', error);

    return res.status(500).json({
      success: false,
      error: 'Internal server error',
    });
  }
});

function buildDemoScenarioPayload(scenario, body) {
  const userId = body.userId || 'demo_user';

  const baseProfile = {
    dailyBudget: 25,
    savingsGoal: 200,
    weeklyFoodBudget: 80,
    weeklySpentFood: 68,
    dailySafeLimit: 25,
    preferredSavingsAmount: 8,
    ...(body.userProfile || {}),
  };

  if (scenario === 'mrt_safe_spending') {
    return {
      userId,
      amount: 6,
      category: 'transport',
      merchant: 'MRT',
      location: 'UM Station',
      userHistory: body.userHistory || [],
      userProfile: {
        ...baseProfile,
        dailyBudget: 30,
        weeklySpentFood: 30,
      },
      userAction: body.userAction || null,
      demoScenario: scenario,
    };
  }

  if (scenario === 'shoes_impulse_shopping') {
    return {
      userId,
      amount: 120,
      category: 'shopping',
      merchant: 'Sneaker Store',
      location: 'Sunway Pyramid',
      userHistory: body.userHistory || [],
      userProfile: {
        ...baseProfile,
        dailyBudget: 50,
        weeklySpentFood: 55,
      },
      userAction: body.userAction || null,
      demoScenario: scenario,
    };
  }

  return {
    userId,
    amount: 18,
    category: 'food',
    merchant: 'Bubble Tea',
    location: 'Mid Valley',
    userHistory: body.userHistory || [],
    userProfile: baseProfile,
    userAction: body.userAction || null,
    demoScenario: 'bubble_tea_high_risk',
  };
}

module.exports = router;