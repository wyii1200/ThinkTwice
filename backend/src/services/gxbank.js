// Mock GXBank API — replace with real API calls when available

async function getBalance(userId) {
  return {
    userId,
    balance: 1240.50,
    currency: 'MYR',
  };
}

async function getSavingsPocket(userId) {
  return {
    userId,
    savingsPocket: 85.00,
    currency: 'MYR',
  };
}

async function transferToSavings(userId, amount) {
  // In production: call real GXBank API
  console.log(`[GXBank Mock] Transferring RM${amount} to savings for ${userId}`);
  return {
    success: true,
    userId,
    amountTransferred: amount,
    currency: 'MYR',
    transactionId: `mock-${Date.now()}`,
  };
}

module.exports = {
  getBalance,
  getSavingsPocket,
  transferToSavings,
};