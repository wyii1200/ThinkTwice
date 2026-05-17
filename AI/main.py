from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from models.schemas import UserProfile

from agents.spending_risk_agent import calculate_risk
from agents.nudge_agent import generate_nudge
from agents.autosave_agent import suggest_savings
from agents.behaviour_analysis import analyse_behaviour
from agents.scoring_agent import calculate_scores
from agents.financial_orchestrator_agent import orchestrate_intervention
from agents.learning_loop_agent import learning_feedback
from agents.explainability_agent import generate_explanation
from agents.spending_velocity_agent import analyse_spending_velocity
from agents.intervention_intelligence_agent import evaluate_intervention_intelligence
from agents.decision_layer_agent import build_decision_layer
from agents.llm_coaching_agent import generate_llm_coaching_message


env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=env_path)

app = FastAPI(
    title="ThinkTwice AI Service",
    description="Pre-confirmation AI behavioural intervention service for ThinkTwice.",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _safe_get(data, key, default=None):
    if isinstance(data, dict):
        return data.get(key, default)
    return default


def _normalize_risk_level(risk_level):
    if not risk_level:
        return "low"
    return str(risk_level).lower()


def _build_transaction_intent(user):
    latest_transaction = None

    if hasattr(user, "transactions") and user.transactions:
        latest_transaction = user.transactions[-1]

    merchant = _safe_get(latest_transaction, "merchant", None)
    amount = _safe_get(latest_transaction, "amount", None)
    category = _safe_get(latest_transaction, "category", None)
    time = _safe_get(latest_transaction, "time", None)
    location = _safe_get(latest_transaction, "location", None)

    return {
        "merchant": merchant or "Bubble Tea",
        "amount": amount or 18,
        "category": category or "food",
        "time": time or "10:45 PM",
        "location": location or "Mid Valley",
        "status": "before_confirmation",
    }


def _risk_label(risk_level):
    if risk_level == "high":
        return "🔥 Impulse Purchase Detected"
    if risk_level == "medium":
        return "⚠️ Budget Warning"
    return "✅ Safe Spending"


def _risk_color(risk_level):
    return {
        "high": "red",
        "medium": "orange",
        "low": "green",
    }.get(risk_level, "grey")


def _human_summary(risk_level):
    if risk_level == "high":
        return "There’s a high chance this purchase may affect your weekly budget."
    if risk_level == "medium":
        return "This purchase may slightly affect your budget, so ThinkTwice is checking it first."
    return "This purchase looks manageable based on your current spending pattern."


def _money_habit_score_impact(risk_level, trigger_smart_radar):
    if risk_level == "high" and trigger_smart_radar:
        return "+3"
    if risk_level == "medium":
        return "+1"
    return "+1"


def _build_ai_timeline(trigger_smart_radar):
    timeline = [
        "Payment intent detected",
        "Spending behaviour analysed",
        "Overspending risk predicted",
        "Intervention options generated",
    ]

    if trigger_smart_radar:
        timeline.append("Smart Radar activated")
    else:
        timeline.append("Safe spending feedback prepared")

    return timeline


@app.get("/")
def home():
    return {
        "message": "ThinkTwice AI Service is running",
        "mode": "pre-confirmation intervention",
        "availableEndpoints": ["/analyze-risk"],
    }


@app.post("/analyze-risk")
def analyze_risk(user: UserProfile):
    transaction_intent = _build_transaction_intent(user)

    behaviour_result = analyse_behaviour(user)
    risk_result = calculate_risk(user)
    velocity_result = analyse_spending_velocity(user)

    risk_level = _normalize_risk_level(risk_result.get("riskLevel", "low"))

    score_result = calculate_scores(user, risk_level)
    savings_result = suggest_savings(risk_level)
    savings_amount = savings_result.get("suggestedAmount", 8)

    nudge_result = generate_nudge(
        risk_level,
        savings_amount,
        behaviour_result.get("primaryCategory", transaction_intent["category"]),
    )

    intelligence_result = evaluate_intervention_intelligence(
        risk_result,
        behaviour_result,
        velocity_result,
    )

    orchestrator_result = orchestrate_intervention(
        risk_result,
        score_result,
        behaviour_result,
        savings_amount,
    )

    learning_result = learning_feedback(
        risk_level,
        orchestrator_result.get("finalAction", "SAFE_SPENDING_REWARD"),
        getattr(user, "user_action", None),
    )

    decision_layer_result = build_decision_layer(
        risk_result,
        orchestrator_result,
        learning_result,
    )

    explanation_result = generate_explanation(
        risk_result,
        behaviour_result,
        orchestrator_result,
        velocity_result,
    )

    trigger_smart_radar = orchestrator_result.get(
        "smartRadar",
        {},
    ).get("triggerSmartRadar", risk_level == "high")

    intervention_confidence = intelligence_result.get("interventionConfidence", 92)

    combined_score = (
        risk_result.get("riskScore", 0) * 0.6
        + velocity_result.get("velocityScore", 0) * 0.4
    )

    behaviour_severity_score = round(min(combined_score, 100), 2)

    llm_base_response = {
        "riskAnalysis": risk_result,
        "behaviourAnalysis": behaviour_result,
        "spendingVelocityAnalysis": velocity_result,
        "scoreAnalysis": score_result,
        "intervention": orchestrator_result,
    }

    llm_result = generate_llm_coaching_message(llm_base_response)

    prediction_text = velocity_result.get(
        "overspendingPrediction",
        {},
    ).get(
        "prediction",
        "Your spending currently looks manageable.",
    )

    human_explanation = behaviour_result.get(
        "userFriendlyInsight",
        _human_summary(risk_level),
    )

    recommended_action = orchestrator_result.get(
        "humanRecommendedAction",
        llm_result.get(
            "recommendedButtonText",
            "Want to save money or find a smarter option nearby?",
        ),
    )

    ai_timeline_simple = _build_ai_timeline(trigger_smart_radar)

    demo_decision = {
        "transactionIntent": transaction_intent,
        "riskLevel": risk_level.upper(),
        "riskLabel": _risk_label(risk_level),
        "humanExplanation": human_explanation,
        "futureImpact": prediction_text,
        "recommendedAction": recommended_action,
        "interventionOptions": [
            "Continue Anyway",
            f"Save RM{savings_amount} Instead",
            "Find Cheaper Nearby",
        ],
        "triggerSmartRadar": trigger_smart_radar,
        "estimatedSavings": f"RM{savings_amount}",
        "orchestratorDecision": orchestrator_result.get(
            "finalAction",
            "SMART_RADAR_AND_SAVE_NUDGE" if trigger_smart_radar else "SAFE_SPENDING_REWARD",
        ),
        "moneyHabitScoreImpact": _money_habit_score_impact(
            risk_level,
            trigger_smart_radar,
        ),
        "confidence": intervention_confidence,
        "aiTimelineSimple": ai_timeline_simple,
        "reasons": risk_result.get("reasons", []),
    }

    response = {
        "userId": user.user_id,
        "aiService": "ThinkTwice Agentic Financial Intelligence",
        "mode": "PRE_CONFIRMATION_INTERVENTION",

        "transactionIntent": transaction_intent,

        "riskAnalysis": {
            **risk_result,
            "riskLevel": risk_level,
            "riskLabel": _risk_label(risk_level),
        },

        "behaviourAnalysis": behaviour_result,
        "spendingVelocityAnalysis": velocity_result,
        "scoreAnalysis": score_result,

        "intervention": {
            **orchestrator_result,
            **nudge_result,
            "suggestedSavingsAmount": savings_amount,
            "savingsInsights": savings_result,
            **intelligence_result,
            "llmEnhancedNudge": llm_result.get("coachingMessage", ""),
            "dashboardInsight": llm_result.get("dashboardInsight", ""),
            "recommendedButtonText": llm_result.get(
                "recommendedButtonText",
                "Choose a smarter option",
            ),
        },

        "learningLoop": learning_result,

        "decisionLayer": decision_layer_result,
        "explanation": explanation_result,

        "llmCoaching": llm_result,

        "interventionConfidence": intervention_confidence,
        "behaviourSeverityScore": behaviour_severity_score,

        "aiVisibility": {
            "title": "ThinkTwice AI Analysis",
            "riskLabel": _risk_label(risk_level),
            "riskColor": _risk_color(risk_level),
            "summary": _human_summary(risk_level),
            "bulletReasons": risk_result.get("reasons", []),
            "predictionText": prediction_text,
            "recommendedActionText": recommended_action,
            "confidenceText": f"{intervention_confidence}%",
            "severityScoreText": f"{behaviour_severity_score}/100",
            "riskTags": intelligence_result.get("riskTags", []),
            "recommendationPriority": intelligence_result.get(
                "recommendationPriority",
                "normal",
            ),
            "isAiMonitoringLive": True,
            "aiStatus": "Checking if this purchase may affect your budget...",
        },

        "explainability": {
            "question": "Why am I seeing this?",
            "reasons": risk_result.get("reasons", []),
            "behaviourInsights": [
                behaviour_result.get(
                    "behaviourPattern",
                    "Spending behaviour was analysed.",
                ),
                velocity_result.get(
                    "spendingTrend",
                    "Spending behaviour remains stable.",
                ),
                "ThinkTwice checks risky purchases before you confirm payment.",
            ],
            "transparencyNote": (
                "ThinkTwice only recommends actions. "
                "Financial actions always require user approval."
            ),
            "summary": explanation_result.get("explainabilitySummary", {}),
        },

        "aiTimeline": [
            {"step": index + 1, "event": event}
            for index, event in enumerate(ai_timeline_simple)
        ],

        "demoDecision": demo_decision,
    }

    response["integrationPayload"] = {
        "userId": user.user_id,
        "transactionIntent": transaction_intent,
        "finalAction": demo_decision["orchestratorDecision"],
        "smartRadar": {
            **orchestrator_result.get("smartRadar", {}),
            "triggerSmartRadar": trigger_smart_radar,
            "radarCategory": orchestrator_result.get(
                "smartRadar",
                {},
            ).get("radarCategory", transaction_intent["category"]),
            "estimatedSavings": f"RM{savings_amount}",
            "radarMessage": (
                f"AI found cheaper nearby choices that could help you save RM{savings_amount}."
                if trigger_smart_radar
                else "No Smart Radar needed for this safe purchase."
            ),
        },
        "notification": {
            **orchestrator_result.get("notification", {}),
            "sendPushNotification": risk_level in ["high", "medium"],
            "notificationTitle": demo_decision["riskLabel"],
            "notificationBody": llm_result.get(
                "coachingMessage",
                demo_decision["futureImpact"],
            ),
            "notificationType": "PRE_CONFIRMATION_NUDGE",
        },
        "safetyCheck": orchestrator_result.get(
            "safetyCheck",
            {
                "requiresUserConsent": True,
                "consentStatus": "required_before_action",
                "canExecuteAction": False,
            },
        ),
        "fcmPayload": {
            "shouldSend": risk_level in ["high", "medium"],
            "title": demo_decision["riskLabel"],
            "body": llm_result.get(
                "coachingMessage",
                demo_decision["futureImpact"],
            ),
            "data": {
                "finalAction": demo_decision["orchestratorDecision"],
                "triggerSmartRadar": str(trigger_smart_radar).lower(),
                "radarCategory": transaction_intent["category"],
                "notificationType": "PRE_CONFIRMATION_NUDGE",
            },
        },
    }

    response["firestorePayload"] = {
        "collectionPath": f"users/{user.user_id}/ai/latest_ai_analysis",
        "data": {
            "userId": user.user_id,
            "transactionIntent": transaction_intent,
            "riskLevel": risk_level,
            "riskLabel": demo_decision["riskLabel"],
            "riskScore": risk_result.get("riskScore", 0),
            "spendingRatio": risk_result.get("spendingRatio", 0),
            "reasons": risk_result.get("reasons", []),
            "prediction": prediction_text,
            "recommendedAction": recommended_action,
            "finalAction": demo_decision["orchestratorDecision"],
            "interventionConfidence": intervention_confidence,
            "behaviourSeverityScore": behaviour_severity_score,
            "triggerSmartRadar": trigger_smart_radar,
            "radarCategory": transaction_intent["category"],
            "estimatedSavings": f"RM{savings_amount}",
            "moneyHabitScoreImpact": demo_decision["moneyHabitScoreImpact"],
            "resilienceScore": score_result.get("resilienceScore", 50),
            "smartDecisionScore": score_result.get("smartDecisionScore", 50),
            "behaviourGrade": score_result.get("behaviourGrade", "moderate"),
            "streakStatus": score_result.get("streakStatus", "at_risk"),
            "learningStatus": learning_result.get("learningStatus", ""),
            "nextBestIntervention": learning_result.get(
                "nextBestIntervention",
                "",
            ),
            "updatedAt": "SERVER_TIMESTAMP",
        },
    }

    response["aiHistory"] = [
        {
            "date": "2026-05-17",
            "riskLevel": risk_level,
            "finalAction": demo_decision["orchestratorDecision"],
            "confidence": intervention_confidence,
            "severityScore": behaviour_severity_score,
        }
    ]

    response["frontendPayload"] = {
        "riskLevel": risk_level,
        "riskLabel": demo_decision["riskLabel"],

        "mainReason": demo_decision["humanExplanation"],

        "secondaryReason": demo_decision["futureImpact"],

        "recommendedAction": demo_decision["recommendedAction"],

        "estimatedSavings": demo_decision["estimatedSavings"],

        "triggerSmartRadar": demo_decision["triggerSmartRadar"],

        "moneyHabitScore": score_result.get(
            "moneyHabitScore",
            score_result.get("resilienceScore", 62)
        ),

        "smartDecisionScore": score_result.get(
            "smartDecisionScore",
            68
        ),

        "moneyHabitScoreImpact":
        demo_decision["moneyHabitScoreImpact"],

        "confidence":
        demo_decision["confidence"],

        "interventionOptions":
        demo_decision["interventionOptions"],

        "demoFlowStage": {
            "currentStage": "AI_INTERVENTION",

            "nextStage": (
                "SMART_RADAR_SELECTION"
                if demo_decision["triggerSmartRadar"]
                else "PAYMENT_CONFIRMATION"
            ),

            "uiAnimation": (
                "pulse_warning"
                if risk_level == "high"
                else "soft_success"
            )
        }
    }

    return response