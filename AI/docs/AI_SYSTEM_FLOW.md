# ThinkTwice AI System Flow

# AI Service Purpose

ThinkTwice AI is a multi-agent financial behaviour intelligence system designed to:
- detect risky spending behaviour
- predict overspending patterns
- trigger behavioural interventions
- reinforce positive financial habits
- support long-term financial resilience

The AI system acts as the behavioural intelligence layer inside ThinkTwice.

---

# High-Level AI Flow

Transaction Data
↓
Risk Analysis
↓
Behaviour Analysis
↓
Spending Velocity Analysis
↓
Overspending Prediction
↓
Intervention Intelligence
↓
Financial Orchestrator Decision
↓
Smart Radar / Nudge / Auto-Save Recommendation
↓
Frontend Notification & Dashboard Update
↓
User Action Feedback
↓
Learning Loop
↓
Future Behaviour Improvement

---

# Detailed AI Pipeline

## 1. Transaction Ingestion

Input:
- GXBank transaction webhook
- user spending history
- budget profile
- savings goal
- frontend user actions

Example Transaction:

```json
{
  "amount": 12,
  "category": "food",
  "time": "10:45 PM",
  "location": "Mid Valley"
}
```

---

# 2. Spending Risk Agent

Purpose:
Detect risky financial behaviour.

Analysis:
- budget overspending
- abnormal spending patterns
- high transaction frequency
- category overspending
- late-night spending

Outputs:
- risk level
- risk score
- risk reasons

Example:

```json
{
  "riskLevel": "high",
  "riskScore": 215
}
```

---

# 3. Behaviour Analysis Agent

Purpose:
Analyse behavioural patterns.

Detects:
- late-night habits
- risky categories
- spending frequency
- repeated behaviour patterns

Outputs:
- primary category
- late-night behaviour
- transaction count

---

# 4. Spending Velocity Agent

Purpose:
Predict future overspending risk.

Analysis:
- daily burn rate
- spending acceleration
- rapid spending spikes

Outputs:
- spending velocity
- overspending prediction
- predicted future risk

Example:

```json
{
  "spendingVelocity": "very_fast",
  "prediction": "User may exceed weekly budget within 2 days."
}
```

---

# 5. Scoring Agent

Purpose:
Calculate behavioural financial scores.

Updates:
- resilience score
- smart decision score
- financial discipline metrics

Purpose:
Gamification + behavioural reinforcement.

---

# 6. Nudge Agent

Purpose:
Generate personalised financial intervention messages.

Examples:
- spending warnings
- encouragement nudges
- savings suggestions

Example:

```json
{
  "nudge": "Your food spending is risky today. Save RM8 now to protect your savings streak?"
}
```

---

# 7. Auto-Save Agent

Purpose:
Recommend safe micro-saving amounts.

Example:
- High risk → RM8
- Medium risk → RM5

Important:
No money is moved automatically.

---

# 8. Safety & Consent Agent

Purpose:
Responsible AI governance.

Ensures:
- all financial actions require user approval
- no automatic money movement occurs

Outputs:
- requiresUserConsent
- consentStatus
- canExecuteAction

---

# 9. Intervention Intelligence Agent

Purpose:
Calculate:
- intervention confidence
- severity intelligence
- escalation priority

Outputs:
- severityLevel
- interventionConfidence

---

# 10. Financial Orchestrator Agent

Purpose:
Central AI orchestration engine.

Coordinates:
- all AI agents
- intervention strategy
- Smart Radar triggering
- FCM payload generation
- frontend/backend integration payloads

Possible Actions:
- continue_tracking
- send_warning_nudge
- auto_save
- smart_radar_and_auto_save

---

# 11. Smart Radar Integration

Purpose:
Trigger smarter spending alternatives.

Outputs:
- radar category
- radar message
- Smart Radar opening behaviour

Example:

```json
{
  "triggerSmartRadar": true,
  "radarCategory": "food"
}
```

---

# 12. Frontend Notification Flow

Purpose:
Send real-time behavioural nudges.

Generated:
- Firebase Cloud Messaging payload
- dashboard updates
- intervention notifications

---

# 13. Learning Loop Agent

Purpose:
Continuously improve future recommendations.

Learns From:
- accepted nudges
- ignored interventions
- Smart Radar usage
- savings behaviour
- frontend user actions

Outputs:
- behaviour reinforcement
- future intervention recommendations
- adaptive AI learning

---

# 14. Explainability Agent

Purpose:
Generate explainable AI reasoning.

Used For:
- user transparency
- trust-building
- frontend explanations
- hackathon storytelling

Example:

```json
{
  "aiExplanation": [
    "Late-night spending behaviour increases impulsive spending risk."
  ]
}
```

---

# 15. Decision Layer Agent

Purpose:
Build behavioural lifecycle storytelling.

Stages:
- before spending
- during intervention
- after user action

Used For:
- presentation storytelling
- behavioural economics framing
- explainable intervention lifecycle

---

# Integration Architecture

GXBank Webhook
↓
Backend Transaction Pipeline
↓
ThinkTwice AI Service (FastAPI)
↓
AI Orchestrator Response
↓
Backend Integration Payload
↓
Frontend Dashboard + FCM
↓
Smart Savings Radar
↓
User Feedback Loop
↓
AI Learning Pipeline

---

# Core Behaviour Loop

Detect
↓
Predict
↓
Decide
↓
Nudge
↓
Act
↓
Reward
↓
Learn
↓
Repeat

---

# Final Positioning

ThinkTwice AI is not just a risk detector.

It is a continuous behavioural financial intervention system that:
- predicts overspending
- guides smarter financial decisions
- reinforces positive habits
- learns from user behaviour over time
- integrates AI, gamification, and behavioural economics into one closed-loop financial resilience ecosystem