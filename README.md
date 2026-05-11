# ThinkTwice

## AI-Powered Financial Resilience System

**Transaction → AI Analysis → Smart Intervention → Financial Growth. Intelligent. Real-time. Adaptive.**

![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue?logo=flutter) ![Firebase](https://img.shields.io/badge/Firebase-Realtime%20DB-orange?logo=firebase) ![Firestore](https://img.shields.io/badge/Firestore-Auth-yellow?logo=firebase) ![VertexAI](https://img.shields.io/badge/VertexAI-Gemini%202.5-purple?logo=google) ![Python](https://img.shields.io/badge/Python-3.10+-green?logo=python) ![Cloud Run](https://img.shields.io/badge/Cloud%20Run-Deployed-red?logo=googlecloud)

---

## 🎯 What is ThinkTwice?

ThinkTwice is a multi-agent AI system that detects risky spending behaviour in real-time and provides intelligent financial interventions. Instead of just sending alerts, it analyzes behavioural patterns, predicts overspending, and offers personalized solutions—saving money and building financial resilience.

**For users:** Get Smart Radar recommendations, auto-save suggestions, and AI coaching without the judgment.

**For banks:** Reduce financial risk, increase customer engagement, and build loyalty through intelligent nudges.

---

## ✨ Core Features

### 🧠 Real-time Behaviour Intelligence
- Multi-agent AI pipeline analyzes transactions instantly
- Detects impulse spending, late-night patterns, and velocity anomalies
- Predicts overspending up to 7 days in advance

### 🗺️ Smart Radar (Geolocation)
- Finds cheaper alternatives to current purchase
- Real-time location-based recommendations
- Estimated savings calculated instantly

### 💰 Intelligent Interventions
- Smart Auto-Save: Automatically set aside money
- Deal-Based Nudges: Personalized discounts & alternatives
- AI Coaching: Educational insights about spending patterns

### � Wallet Guardian Avatar
- AI-powered companion that learns your financial personality
- Provides personalized advice in conversational tone
- Celebrates wins and provides encouragement
- Adapts responses based on your behaviour patterns
- Non-judgmental support for financial wellness

### �📊 Dashboard & Resilience Tracking
- Real-time savings metrics
- Resilience score & streak tracking
- Financial goal progress visualization
- Spending analytics & pattern insights

### 🤖 Adaptive Learning Loop
- Learns from user responses
- Optimizes future recommendations
- Tracks intervention effectiveness
- Improves accuracy over time

### 🎮 Gamification & Engagement
- Resilience Score system (build financial strength)
- Savings Streaks (maintain consistent good habits)
- Achievements & Badges (milestone rewards)
- Leaderboards & Social Challenges (friendly competition)
- Daily Missions (guided financial wellness tasks)
- Progress Visualization (celebrate wins)

---

## 🔄 System Flow: Detect → Nudge → Act → Reward → Repeat

```
🔍 DETECT
   ↓
   GXBank Transaction Webhook
   ↓
   Spending Risk Analysis (budget/pattern violations)
   ↓
   Behaviour Analysis (spending habits)
   ↓
   Spending Velocity Analysis (rapid transactions)
   ↓
   Overspending Prediction (7-day forecast)

💬 NUDGE
   ↓
   Intervention Intelligence (select best action)
   ↓
   Financial Orchestrator Decision (prioritize response)
   ↓
   Smart Radar / Nudge / Auto-Save Recommendation
   ↓
   Wallet Guardian Messaging (personalized delivery)

✅ ACT
   ↓
   Push Notification & Dashboard Update
   ↓
   User Response (saves, uses smart radar, accepts deal)

🏆 REWARD
   ↓
   Savings Tracked (+RM saved)
   ↓
   Resilience Score Increased
   ↓
   Streak Maintained / Badges Unlocked
   ↓
   Dashboard Celebration & Progress Update

🔄 REPEAT
   ↓
   Learning Loop (capture user behaviour)
   ↓
   Optimize Future Recommendations
   ↓
   Financial Resilience Improvement
   ↓
   Back to DETECT (next transaction)
```

---

## 🛠️ Tech Stack

**Frontend:**
- ![Flutter](https://img.shields.io/badge/Flutter-UI-blue?logo=flutter) Flutter 3.16+ (Web, Android, iOS, Windows, macOS, Linux)

**Backend:**
- ![Firebase](https://img.shields.io/badge/Firebase-Realtime%20DB-orange?logo=firebase) Firebase Realtime Database
- ![Firestore](https://img.shields.io/badge/Firestore-Document%20Store-yellow?logo=firebase) Firestore (Data & Rules)
- ![Cloud Run](https://img.shields.io/badge/Cloud%20Run-Serverless-red?logo=googlecloud) Cloud Run (API Deployment)
- ![Node.js](https://img.shields.io/badge/Node.js-Backend-green?logo=node.js) Node.js + Express

**AI & ML:**
- ![VertexAI](https://img.shields.io/badge/VertexAI-Gemini%202.5-purple?logo=google) VertexAI Gemini 2.5 Flash (LLM)
- ![Python](https://img.shields.io/badge/Python-3.10+-green?logo=python) Python (Multi-Agent Pipeline)
- ![Firebase Auth](https://img.shields.io/badge/Firebase%20Auth-Security-orange?logo=firebase) Firebase Auth

**Integrations:**
- 🏦 GXBank Webhook Integration
- 📍 Geolocation API (Smart Radar)
- 🔔 Firebase Cloud Messaging (Push Notifications)

---

## 🚀 Try It Now

Open the deployed frontend:

- Frontend: <https://thinktwice-kamihack.web.app/>

Live service endpoints:

- `BACKEND_URL`: <https://us-central1-thinktwice-kamihack.cloudfunctions.net/api>
- `RADAR_URL`: <https://thinktwice-zu5d.onrender.com/>
- `AI_URL`: <https://thinktwice-guq9.onrender.com/>

Recommended quick test flow:

1. Sign in on the deployed frontend.
2. Complete onboarding if prompted.
3. Trigger a sample transaction or AI analysis from the dashboard.
4. Open Smart Radar to verify nearby deals, route suggestions, and savings tracking.

---

## 📁 Project Structure

```
ThinkTwice/
├── flutter_app/          # Mobile & Web Frontend
├── backend/              # Node.js API & Firebase Backend
├── AI/                   # Python Multi-Agent System
│   ├── agents/          # Individual AI agents
│   ├── config/          # Constants & settings
│   ├── models/          # Data schemas
│   └── docs/            # AI documentation
└── thinktwice_smart_radar/  # Geolocation service
```

---

## 🎓 AI Agents

ThinkTwice uses a multi-agent architecture:

1. **Spending Risk Agent** — Detects budget violations and anomalies
2. **Behaviour Analysis Agent** — Identifies spending patterns & habits
3. **Spending Velocity Agent** — Flags rapid transaction patterns
4. **Decision Layer Agent** — Evaluates intervention options
5. **Intervention Intelligence Agent** — Selects best intervention type
6. **Financial Orchestrator Agent** — Coordinates final response
7. **Smart Radar Agent** — Recommends cheaper alternatives
8. **Nudge Agent** — Crafts persuasive messaging
9. **Explainability Agent** — Provides reasoning to users
10. **Learning Loop Agent** — Captures feedback & optimizes
11. **Safety & Consent Agent** — Manages user preferences
12. **Auto-Save Agent** — Manages automatic savings
13. **LLM Coaching Agent** — Provides financial guidance

---

## 📝 License

For UTM x Hackathon 2026 use only. All Rights Reserved.

---




