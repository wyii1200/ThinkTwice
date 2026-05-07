# ThinkTwice Demo Scenarios

# Purpose

This document contains recommended hackathon demo scenarios for ThinkTwice.

Goals:
- demonstrate AI behavioural intelligence
- show real-time intervention flow
- showcase Smart Radar integration
- explain behavioural reinforcement loop
- demonstrate frontend/backend/AI integration

---

# Demo Scenario 1 — High Risk Late-Night Overspending

## Scenario

A university student buys food repeatedly late at night.

Transaction Example:
- RM12 coffee
- RM18 supper
- RM20 snacks

Location:
- Mid Valley

Time:
- 10:45 PM

---

# AI Detection

The AI detects:
- daily budget exceeded
- high food spending
- high transaction frequency
- repeated late-night spending behaviour
- very fast spending velocity

---

# AI Prediction

AI predicts:

```text
User may exceed weekly budget within 2 days.
```

Severity:
- critical

Intervention confidence:
- 100%

---

# AI Intervention

Financial Orchestrator Agent selects:

```text
smart_radar_and_auto_save
```

Generated Nudge:

```text
Your food spending is risky today.
Save RM8 now to protect your savings streak?
```

---

# Smart Radar Trigger

Smart Radar opens automatically.

AI suggests:
- cheaper nearby food alternatives
- optimized spending choices
- estimated savings opportunities

Example:

```text
Find RM6 dinner alternatives nearby.
Estimated savings: RM14
```

---

# Frontend Behaviour

Frontend shows:
- push notification
- dashboard warning
- resilience score impact
- streak risk warning

---

# User Action

User:
- opens Smart Radar
- accepts recommendation

Frontend sends feedback:

```json
{
  "actionType": "opened_smart_radar"
}
```

---

# Learning Loop Result

AI learns:
- user responds positively to Smart Radar
- future Smart Radar interventions should increase

Learning result:

```text
Continue proactive nudges.
```

---

# Final Dashboard Update

Dashboard updates:
- resilience score
- smart decision score
- savings amount
- streak continuation
- leaderboard impact

Example:

```text
+RM14 overspending avoided
+5 resilience score
```

---

# Demo Scenario 2 — Medium Risk Spending Behaviour

## Scenario

User is close to daily budget limit.

AI detects:
- moderate overspending risk
- increasing spending velocity

---

# AI Action

Financial Orchestrator Agent selects:

```text
send_warning_nudge
```

Generated notification:

```text
You are close to exceeding today's budget for shopping.
```

---

# User Action

User ignores warning.

---

# Learning Result

AI learns:
- user ignored intervention
- future intervention intensity should increase

Result:

```text
Increase intervention intensity.
```

---

# Demo Scenario 3 — Healthy Financial Behaviour

## Scenario

User maintains healthy spending behaviour.

AI detects:
- low spending velocity
- stable savings behaviour
- low financial risk

---

# AI Action

Financial Orchestrator Agent selects:

```text
continue_tracking
```

Generated encouragement:

```text
Good job! Your spending is still under control today.
```

---

# Reward System

System updates:
- resilience score
- streak maintenance
- smart decision score

Example:

```text
+3 resilience score
7-day smart spending streak maintained
```

---

# Recommended Live Demo Flow

## Demo Order

1. User transaction occurs
2. Backend webhook triggered
3. AI analysis begins
4. Risk detection displayed
5. Intervention selected
6. Push notification shown
7. Smart Radar triggered
8. User action simulated
9. Dashboard updates
10. Learning loop updates future behaviour

---

# Recommended Presentation Talking Points

## Key Message

ThinkTwice does not wait for monthly reports.

It:
- detects overspending early
- intervenes instantly
- recommends smarter actions
- reinforces positive behaviour
- continuously learns from user responses

---

# Behavioural Economics Concepts

ThinkTwice applies:
- loss aversion
- soft financial friction
- social accountability
- reward reinforcement
- habit loop design

---

# AI Architecture Highlights

ThinkTwice uses:
- multi-agent AI orchestration
- explainable AI
- responsible AI consent layer
- adaptive learning loop
- Smart Radar integration
- real-time behavioural intervention

---

# Final Positioning

ThinkTwice transforms:
Awareness → Action

Instead of only showing spending data,
ThinkTwice actively helps Malaysian youth:
- avoid overspending
- build resilience
- improve saving consistency
- develop healthier financial habits over time