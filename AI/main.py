from fastapi import FastAPI

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

app = FastAPI(
    title="ThinkTwice AI Service",
    description="Agentic financial behaviour intelligence service for ThinkTwice.",
    version="1.0.0"
)


@app.get("/")
def home():
    return {
        "message": "ThinkTwice AI Service is running",
        "availableEndpoints": [
            "/analyze-risk"
        ]
    }


@app.post("/analyze-risk")
def analyze_risk(user: UserProfile):

    behaviour_result = analyse_behaviour(user)

    risk_result = calculate_risk(user)

    velocity_result = analyse_spending_velocity(user)

    score_result = calculate_scores(
        user,
        risk_result["riskLevel"]
    )

    savings_amount = suggest_savings(
        risk_result["riskLevel"]
    )

    nudge_result = generate_nudge(
        risk_result["riskLevel"],
        savings_amount,
        behaviour_result["primaryCategory"]
    )

    intelligence_result = evaluate_intervention_intelligence(
        risk_result,
        behaviour_result,
        velocity_result
    )

    orchestrator_result = orchestrate_intervention(
        risk_result,
        score_result,
        behaviour_result,
        savings_amount
    )

    learning_result = learning_feedback(
        risk_result["riskLevel"],
        orchestrator_result["finalAction"],
        user.user_action
    )

    decision_layer_result = build_decision_layer(
        risk_result,
        orchestrator_result,
        learning_result
    )

    explanation_result = generate_explanation(
        risk_result,
        behaviour_result,
        orchestrator_result,
        velocity_result
    )

    response = {
        "userId": user.user_id,
        "aiService": "ThinkTwice Agentic Financial Intelligence",
        "riskAnalysis": risk_result,
        "behaviourAnalysis": behaviour_result,
        "spendingVelocityAnalysis": velocity_result,
        "scoreAnalysis": score_result,
        "intervention": {
            **orchestrator_result,
            **nudge_result,
            "suggestedSavingsAmount": savings_amount,
            **intelligence_result
        },
        "learningLoop": learning_result,
        **decision_layer_result,
        **explanation_result
    }

    response["integrationPayload"] = {
        "userId": user.user_id,
        "finalAction": orchestrator_result["finalAction"],
        "smartRadar": orchestrator_result["smartRadar"],
        "notification": orchestrator_result["notification"],
        "safetyCheck": orchestrator_result["safetyCheck"],
        "fcmPayload": {
            "shouldSend": orchestrator_result["notification"]["sendPushNotification"],
            "title": orchestrator_result["notification"]["notificationTitle"],
            "body": orchestrator_result["notification"]["notificationBody"],
            "data": {
                "finalAction": orchestrator_result["finalAction"],
                "triggerSmartRadar": str(
                    orchestrator_result["smartRadar"]["triggerSmartRadar"]
                ).lower(),
                "radarCategory": orchestrator_result["smartRadar"]["radarCategory"] or "",
                "notificationType": orchestrator_result["notification"]["notificationType"]
            }
        }
    }

    return response