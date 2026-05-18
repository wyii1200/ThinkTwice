// Mock GXBank service.
// Replace these functions with real GXBank APIs when available.

async function getBalance(userId) {
  return {
    success: true,
    userId,
    balance: 1240.5,
    currency: 'MYR',
    source: 'gxbank_mock',
  };
}

async function getSavingsPocket(userId) {
  return {
    success: true,
    userId,
    savingsPocket: 85,
    moneySavedThisWeek: 18,
    currency: 'MYR',
    source: 'gxbank_mock',
  };
}

async function transferToSavings(userId, amount) {
  const saveAmount = Number(amount || 0);

  console.log(
    `[GXBank Mock] User-approved transfer: RM${saveAmount} to savings for ${userId}`
  );

  return {
    success: true,
    userId,
    amountTransferred: saveAmount,
    currency: 'MYR',
    transactionId: `gx-mock-save-${Date.now()}`,
    status: 'completed',
    requiresUserConsent: true,
    consentStatus: 'user_approved',
    message: `RM${saveAmount} saved successfully.`,
    source: 'gxbank_mock',
  };
}

module.exports = {
  getBalance,
  getSavingsPocket,
  transferToSavings,
};