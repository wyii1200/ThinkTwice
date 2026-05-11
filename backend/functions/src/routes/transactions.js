const express = require('express');
const router = express.Router();
const { getTransactionsByUser } = require('../services/firestore');

// GET /transactions/:userId
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 20;
    const transactions = await getTransactionsByUser(userId, limit);
    res.json({ success: true, transactions });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;