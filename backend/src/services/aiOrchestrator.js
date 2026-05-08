const axios = require('axios');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

async function analyzeTransaction(payload) {
  // payload = { userId, amount, category, merchant, userHistory, userProfile }
  try {
    const response = await axios.post(`${AI_SERVICE_URL}/analyze`, payload, {
      timeout: 10000,
    });
    return response.data;
    // expected response shape from cheeling's service:
    // {
    //   riskLevel: 'low' | 'medium' | 'high',
    //   reason: string,
    //   nudgeText: string,
    //   suggestedAction: 'save' | 'radar' | null,
    //   saveAmount: number,
    //   resilienceImpact: number,
    //   streakRisk: boolean
    // }
  } catch (error) {
    console.error('AI service error:', error.message);
    // fallback so the pipeline doesn't break if AI is down
    return {
      riskLevel: 'low',
      reason: 'AI service unavailable',
      nudgeText: null,
      suggestedAction: null,
      saveAmount: 0,
      resilienceImpact: 0,
      streakRisk: false,
    };
  }
}

module.exports = { analyzeTransaction };