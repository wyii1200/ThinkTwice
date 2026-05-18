const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const app = require('./src/app');

exports.api = onRequest({ region: 'us-central1', timeoutSeconds: 60, memory: '512MiB' }, app);