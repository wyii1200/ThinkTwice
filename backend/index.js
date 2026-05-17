const functions = require('firebase-functions');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const app = require('./src/app');

exports.api = functions.https.onRequest(app);