// Firebase Cloud Function — deploy with: firebase deploy --only functions
// This triggers automatically whenever a new transaction is written to Firestore

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

if (!admin.apps.length) admin.initializeApp();

exports.onTransactionCreated = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const { transactionId } = context.params;

    console.log('New transaction detected:', transactionId, transaction);

    try {
      // Trigger your backend pipeline via HTTP
      // (or duplicate the webhook logic directly here for production)
      await axios.post(`${process.env.BACKEND_URL}/webhook/transaction`, {
        ...transaction,
        transactionId,
      });
    } catch (error) {
      console.error('Cloud Function pipeline error:', error.message);
    }
  });