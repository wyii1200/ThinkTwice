from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from models.schemas import UserProfile, AiDecisionResponse

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
from agents.safety_consent_agent import check_safety_and_consent

from test_cases.demo_responses import DEMO_RESPONSES


# =========================
# App setup
# =========================

env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=env_path)

DEMO_MODE = True

app = FastAPI(
    title="ThinkTwice AI Service",
    description="Pre-confirmation AI behavioural intervention service for ThinkTwice.",
    version="3.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =========================
# Helper functions
# =========================

def _safe_get(data, key, default=None):
    if isinstance(data, dict):
        return data.get(key, default)
    return getattr(data, key, default)


def _normalize_risk_level(risk_level):
    if not risk_level:
        return "low"

    risk_level = str(risk_level).lower()

    if risk_level in ["low", "medium", "high", "critical"]:
        return risk_level

    return "low"


def _build_transaction_intent(user):
    latest_transaction = None

    if hasattr(user, "transactions") and user.transactions:
        latest_transaction = user.transactions[-1]

    merchant = _safe_get(latest_transaction, "merchant", None)
    amount = _safe_get(latest_transaction, "amount", None)
    category = _safe_get(latest_transaction, "category", None)
    time = _safe_get(latest_transaction, "time", None)

    return {
        "merchant": merchant or "Bubble Tea",
        "amount": amount or 18,
        "category": category or "food",
        "time": time or "21:30",
    }


def _headline(risk_level):
    if risk_level == "critical":
        return "High-impact purchase warning"
    if risk_level == "high":
        return "Impulse spending detected"
    if risk_level == "medium":
        return "Budget warning"
    return "Safe spending detected"


def _budget_status(risk_level):
    if risk_level == "critical":
        return "high_risk"
    if risk_level == "high":
        return "at_risk"
    if risk_level == "medium":
        return "monitor"
    return "healthy"


def _resilience_score_change(risk_level):
    if risk_level == "critical":
        return -8
    if risk_level == "high":
        return -4
    if risk_level == "medium":
        return -1
    return 2


def _build_actions(risk_level, savings_amount, trigger_smart_radar):
    if risk_level == "low":
        return {
            "primary": "Continue",
            "secondary": "View Budget",
            "danger": None,
        }

    if trigger_smart_radar:
        return {
            "primary": "Find Cheaper Nearby",
            "secondary": f"Save RM{savings_amount} Instead",
            "danger": "Continue Anyway",
        }

    return {
        "primary": "Pause Purchase",
        "secondary": f"Save RM{savings_amount} First",
        "danger": "Continue Anyway",
    }


def _apply_demo_override(transaction_intent, risk_result, behaviour_result, velocity_result):
    amount = float(transaction_intent.get("amount", 0) or 0)
    category = str(transaction_intent.get("category", "")).lower()
    merchant = str(transaction_intent.get("merchant", "")).lower()

    is_bubble_tea_demo = (
        amount >= 15
        and category == "food"
        and ("bubble" in merchant or merchant == "bubble tea")
    )

    if DEMO_MODE and is_bubble_tea_demo:
        risk_result["riskLevel"] = "high"
        risk_result["riskScore"] = max(risk_result.get("riskScore", 0), 82)
        risk_result["reasons"] = [
            "Food spending exceeded safe limit",
            "Late-night spending detected",
            "Spending frequency increased this week",
        ]

        behaviour_result["primaryCategory"] = "food"
        behaviour_result["userFriendlyInsight"] = (
            "You have been spending more often than usual on food tonight."
        )

        velocity_result["velocityScore"] = max(
            velocity_result.get("velocityScore", 0),
            90,
        )
        velocity_result["overspendingPrediction"] = {
            "prediction": "Your weekly food budget may exceed in 2 days.",
            "predictedRisk": "high",
        }

    return risk_result, behaviour_result, velocity_result


# =========================
# Routes
# =========================

@app.get("/")
def home():
    return {
        "message": "ThinkTwice AI Service is running",
        "mode": "pre-confirmation intervention",
        "availableEndpoints": [
            "/analyze-risk",
            "/demo-response/bubble_tea",
            "/demo-response/mrt",
            "/demo-response/shoes",
        ],
    }


@app.get("/demo-response/{scenario}", response_model=AiDecisionResponse)
def get_demo_response(scenario: str):
    if scenario not in DEMO_RESPONSES:
        raise HTTPException(status_code=404, detail="Invalid scenario")

    return DEMO_RESPONSES[scenario]


@app.post("/analyze-risk")
def analyze_risk(user: UserProfile):
    transaction_intent = _build_transaction_intent(user)

    behaviour_result = analyse_behaviour(user)
    risk_result = calculate_risk(user)
    velocity_result = analyse_spending_velocity(user)

    risk_result, behaviour_result, velocity_result = _apply_demo_override(
        transaction_intent,
        risk_result,
        behaviour_result,
        velocity_result,
    )

    risk_level = _normalize_risk_level(risk_result.get("riskLevel", "low"))

    score_result = calculate_scores(user, risk_level)
    savings_result = suggest_savings(risk_level)
    savings_amount = savings_result.get("suggestedAmount", 0)

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

    orchestrator_result = check_safety_and_consent(orchestrator_result)

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

    llm_base_response = {
        "riskAnalysis": risk_result,
        "behaviourAnalysis": behaviour_result,
        "spendingVelocityAnalysis": velocity_result,
        "scoreAnalysis": score_result,
        "intervention": orchestrator_result,
    }

    llm_result = generate_llm_coaching_message(llm_base_response)

    trigger_smart_radar = orchestrator_result.get(
        "smartRadar",
        {},
    ).get(
        "triggerSmartRadar",
        risk_level in ["high", "critical"],
    )

    intervention_confidence = intelligence_result.get(
        "interventionConfidence",
        92 if risk_level in ["high", "critical"] else 80,
    )

    prediction_text = velocity_result.get(
        "overspendingPrediction",
        {},
    ).get(
        "prediction",
        "Your spending currently looks manageable.",
    )

    human_explanation = behaviour_result.get(
        "userFriendlyInsight",
        "ThinkTwice checked this purchase against your current spending pattern.",
    )

    recommended_action = orchestrator_result.get(
        "humanRecommendedAction",
        llm_result.get(
            "recommendedButtonText",
            "Choose a smarter option before confirming payment.",
        ),
    )

    reasons = risk_result.get("reasons", [])

    if not reasons:
        reasons = explanation_result.get(
            "explainabilitySummary",
            {},
        ).get(
            "reasons",
            ["Spending pattern was analysed before payment confirmation."],
        )

    final_response = {
        "transaction": {
            "amount": transaction_intent["amount"],
            "merchant": transaction_intent["merchant"],
            "category": transaction_intent["category"],
            "time": transaction_intent["time"],
        },

        "risk": {
            "level": risk_level,
            "score": risk_result.get("riskScore", 0),
            "confidence": round(intervention_confidence / 100, 2),
        },

        "ui": {
            "headline": _headline(risk_level),
            "explanation": human_explanation,
            "futureImpact": prediction_text,
            "suggestedAction": recommended_action,
        },

        "reasons": reasons,

        "actions": _build_actions(
            risk_level,
            savings_amount,
            trigger_smart_radar,
        ),

        "smartRadar": {
            "trigger": trigger_smart_radar,
            "category": transaction_intent["category"],
            "message": (
                f"Cheaper nearby choices may help you save RM{savings_amount}."
                if trigger_smart_radar
                else "No cheaper alternative needed."
            ),
        },

        "dashboardUpdate": {
            "resilienceScoreChange": _resilience_score_change(risk_level),
            "savingOpportunity": savings_amount,
            "budgetStatus": _budget_status(risk_level),
        },

        "debug": {
            "riskAnalysis": risk_result,
            "behaviourAnalysis": behaviour_result,
            "spendingVelocityAnalysis": velocity_result,
            "scoreAnalysis": score_result,
            "nudge": nudge_result,
            "intervention": orchestrator_result,
            "decisionLayer": decision_layer_result,
            "learningLoop": learning_result,
            "explainability": explanation_result,
            "llmCoaching": llm_result,
        },
    }

    return final_response