const app = require('./app');

// Local development only — Firebase ignores app.listen
if (process.env.NODE_ENV !== 'production') {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => console.log(`ThinkTwice backend running on port ${PORT}`));
}

module.exports = app;