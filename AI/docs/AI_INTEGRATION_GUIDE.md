# ThinkTwice AI Integration Guide

## AI Service Overview

ThinkTwice AI is a FastAPI-based multi-agent financial behaviour intelligence service.

Purpose:
- detect risky spending behaviour
- predict overspending
- trigger behavioural interventions
- support Smart Savings Radar
- generate FCM-ready notifications
- learn from frontend user interactions

---

# API Endpoint

## POST `/analyze-risk`

Main AI analysis endpoint.

---

# Request Structure

Example:

```json
{
  "user_id": "user_001",
  "daily_budget": 50,
  "current_daily_spending": 80,
  "savings_goal": 500,
  "user_action": {
    "actionType": "opened_smart_radar",
    "timestamp": "2026-05-07T22:45:00",
    "interactionSource": "push_notification"
  },
  "transactions": [
    {
      "transaction_id": "txn_001",
      "amount": 12,
      "category": "food",
      "time": "10:45 PM",
      "location": "Mid Valley"
    }
  ]
}
```

---

# Main Response Sections

| Section | Purpose | Used By |
|---|---|---|
| riskAnalysis | financial risk analysis | frontend dashboard |
| behaviourAnalysis | behavioural pattern analysis | AI + frontend |
| spendingVelocityAnalysis | overspending prediction | AI + dashboard |
| scoreAnalysis | resilience + smart decision scores | gamification |
| intervention | final intervention result | backend + frontend |
| learningLoop | behaviour learning feedback | AI |
| decisionLayer | behavioural lifecycle storytelling | presentation |
| aiExplanation | explainable AI reasoning | frontend |
| integrationPayload | backend integration contract | backend |

---

# Smart Radar Integration

## integrationPayload.smartRadar

Example:

```json
{
  "triggerSmartRadar": true,
  "radarCategory": "food",
  "radarMessage": "You usually overspend on food during risky hours. Find cheaper nearby alternatives?",
  "openMode": "category_filter"
}
```

## Frontend Behaviour

If:

```json
"triggerSmartRadar": true
```

Frontend should:
- open Smart Radar page
- pre-filter using `radarCategory`
- display `radarMessage`

---

# FCM Notification Integration

## integrationPayload.fcmPayload

Example:

```json
{
  "shouldSend": true,
  "title": "Smart Savings Alert",
  "body": "AI detected risky food spending. Save RM8 or find cheaper options nearby.",
  "data": {
    "finalAction": "smart_radar_and_auto_save",
    "triggerSmartRadar": "true",
    "radarCategory": "food",
    "notificationType": "smart_radar"
  }
}
```

## Backend Behaviour

Backend should:
- send push notification through Firebase Cloud Messaging
- attach data payload
- forward Smart Radar metadata

---

# Frontend Feedback Loop

Frontend can send user interaction feedback back into AI.

Example:

```json
"user_action": {
  "actionType": "opened_smart_radar",
  "timestamp": "2026-05-07T22:45:00",
  "interactionSource": "push_notification"
}
```

---

# Supported User Action Types

| Action Type | Meaning |
|---|---|
| accepted | user accepted intervention |
| ignored | user ignored intervention |
| opened_smart_radar | user opened Smart Radar |
| saved_money | user performed saving action |
| dismissed_notification | user dismissed notification |

---

# AI Agents

ThinkTwice uses a multi-agent AI architecture.

Agents:
- Spending Risk Agent
- Behaviour Analysis Agent
- Spending Velocity Agent
- Nudge Agent
- Auto-Save Agent
- Scoring Agent
- Safety & Consent Agent
- Explainability Agent
- Learning Loop Agent
- Intervention Intelligence Agent
- Financial Orchestrator Agent

---

# Core Behaviour Loop

Detect → Predict → Decide → Nudge → Act → Reward → Learn → Repeat

---

# Responsible AI Design

ThinkTwice never moves money automatically without user approval.

All financial actions pass through:
- Safety & Consent Agent

Example:

```json
"safetyCheck": {
  "requiresUserConsent": true,
  "consentStatus": "pending_user_approval"
}
```

---

# Technology Stack

- Python FastAPI
- Firebase
- Firestore
- Firebase Cloud Messaging
- Gemini API / Vertex AI Gemini
- Firebase Genkit
- pandas
- scikit-learn
- numpy