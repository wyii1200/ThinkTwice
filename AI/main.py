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
from dotenv import load_dotenv
from pathlib import Path
from agents.llm_coaching_agent import generate_llm_coaching_message


env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=env_path)

app = FastAPI(
    title="ThinkTwice AI Service",
    description="Agentic financial behaviour intelligence service for ThinkTwice.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
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

        # Gemini / LLM coaching enhancement
    llm_result = generate_llm_coaching_message(response)

    response["llmCoaching"] = llm_result

    response["intervention"]["llmEnhancedNudge"] = llm_result["coachingMessage"]
    response["intervention"]["dashboardInsight"] = llm_result["dashboardInsight"]
    response["intervention"]["recommendedButtonText"] = llm_result["recommendedButtonText"]

    response["integrationPayload"]["llmCoaching"] = llm_result

    response["integrationPayload"]["notification"]["notificationBody"] = llm_result["coachingMessage"]

    response["integrationPayload"]["fcmPayload"]["body"] = llm_result["coachingMessage"]

    return response

