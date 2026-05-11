// Firebase Cloud Functions v2 entry point
// This wraps the Express app for deployment to Firebase/Cloud Run
const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

// Initialize Firebase Admin (only once)
if (!admin.apps.length) admin.initializeApp();

// ─── Build the Express app ────────────────────────────────────────────────────
const webhookRoutes      = require('../routes/webhook');
const transactionRoutes  = require('../routes/transactions');
const nudgeRoutes        = require('../routes/nudge');
const autosaveRoutes     = require('../routes/autosave');
const userRoutes         = require('../routes/users');
const dashboardRoutes    = require('../routes/dashboard');
const gamificationRoutes = require('../routes/gamification');

const app = express();

app.use(cors({ origin: true }));
app.use(express.json());

app.use('/webhook',      webhookRoutes);
app.use('/transactions', transactionRoutes);
app.use('/nudge',        nudgeRoutes);
app.use('/autosave',     autosaveRoutes);
app.use('/users',        userRoutes);
app.use('/dashboard',    dashboardRoutes);
app.use('/gamification', gamificationRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// ─── Export as Cloud Function ─────────────────────────────────────────────────
// This is what Firebase deploys — the `api` name matches the function name
// in the Cloud Console and the URL path.
exports.api = onRequest({
  region: 'us-central1',
  memory: '256MiB',
  timeoutSeconds: 60,
  maxInstances: 10,
  cors: true,
}, app);
