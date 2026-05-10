require('dotenv').config();
const express = require('express');
const cors    = require('cors');

const webhookRoutes      = require('./routes/webhook');
const transactionRoutes  = require('./routes/transactions');
const nudgeRoutes        = require('./routes/nudge');
const autosaveRoutes     = require('./routes/autosave');
const userRoutes         = require('./routes/users');
const dashboardRoutes    = require('./routes/dashboard');
const gamificationRoutes = require('./routes/gamification');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/webhook',      webhookRoutes);
app.use('/transactions', transactionRoutes);
app.use('/nudge',        nudgeRoutes);
app.use('/autosave',     autosaveRoutes);
app.use('/users',        userRoutes);
app.use('/dashboard',    dashboardRoutes);
app.use('/gamification', gamificationRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok' }));

module.exports = app;