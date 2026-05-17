require('dotenv').config();

const express = require('express');
const cors = require('cors');

const webhookRoutes = require('./routes/webhook');
const transactionRoutes = require('./routes/transactions');
const nudgeRoutes = require('./routes/nudge');
const autosaveRoutes = require('./routes/autosave');
const userRoutes = require('./routes/users');
const dashboardRoutes = require('./routes/dashboard');
const gamificationRoutes = require('./routes/gamification');

const app = express();

app.use(cors({
  origin: '*',
}));

app.use(express.json({
  limit: '2mb',
}));

app.use(express.urlencoded({
  extended: true,
}));

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'ThinkTwice backend is running',
    mode: 'pre-confirmation AI intervention',
  });
});

app.get('/health', (req, res) => {
  res.json({
    success: true,
    status: 'ok',
    service: 'thinktwice-backend',
    timestamp: new Date().toISOString(),
  });
});

app.use('/webhook', webhookRoutes);
app.use('/transactions', transactionRoutes);
app.use('/nudge', nudgeRoutes);
app.use('/autosave', autosaveRoutes);
app.use('/users', userRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/gamification', gamificationRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    path: req.originalUrl,
  });
});

app.use((error, req, res, next) => {
  console.error('Unhandled backend error:', error);

  res.status(500).json({
    success: false,
    error: 'Internal server error',
  });
});

module.exports = app;