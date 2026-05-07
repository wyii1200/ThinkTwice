require('dotenv').config();
const express = require('express');
const cors = require('cors');

const webhookRoutes = require('./routes/webhook');
const transactionRoutes = require('./routes/transactions');
const nudgeRoutes = require('./routes/nudge');
const autosaveRoutes = require('./routes/autosave');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/webhook', webhookRoutes);
app.use('/transactions', transactionRoutes);
app.use('/nudge', nudgeRoutes);
app.use('/autosave', autosaveRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`ThinkTwice backend running on port ${PORT}`));