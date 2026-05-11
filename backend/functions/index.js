console.log('Starting up, __dirname:', __dirname);
console.log('Files:', require('fs').readdirSync(__dirname));

try {
  console.log('src files:', require('fs').readdirSync(__dirname + '/src'));
  console.log('routes files:', require('fs').readdirSync(__dirname + '/src/routes'));
} catch(e) {
  console.error('DIRECTORY ERROR:', e.message);
  process.exit(1);
}

const functions = require('firebase-functions');
const admin     = require('firebase-admin');
const express   = require('express');
const cors      = require('cors');

if (!admin.apps.length) admin.initializeApp();

const app = express();
app.use(cors());
app.use(express.json());

try { app.use('/webhook',      require('./src/routes/webhook'));      } catch(e) { console.error('webhook failed:', e.message); }
try { app.use('/transactions', require('./src/routes/transactions')); } catch(e) { console.error('transactions failed:', e.message); }
try { app.use('/nudge',        require('./src/routes/nudge'));        } catch(e) { console.error('nudge failed:', e.message); }
try { app.use('/autosave',     require('./src/routes/autosave'));     } catch(e) { console.error('autosave failed:', e.message); }
try { app.use('/users',        require('./src/routes/users'));        } catch(e) { console.error('users failed:', e.message); }
try { app.use('/dashboard',    require('./src/routes/dashboard'));    } catch(e) { console.error('dashboard failed:', e.message); }
try { app.use('/gamification', require('./src/routes/gamification')); } catch(e) { console.error('gamification failed:', e.message); }

app.get('/health', (req, res) => res.json({ status: 'ok' }));

exports.api = functions.https.onRequest(app);