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

from dotenv import load_dotenv
from pathlib import Path


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

    savings_result = suggest_savings(
        risk_result["riskLevel"]
    )

    savings_amount = savings_result["suggestedAmount"]

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
            "savingsInsights": savings_result,
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

    llm_result = generate_llm_coaching_message(
        response
    )

    response["llmCoaching"] = llm_result

    response["intervention"]["llmEnhancedNudge"] = (
        llm_result["coachingMessage"]
    )

    response["intervention"]["dashboardInsight"] = (
        llm_result["dashboardInsight"]
    )

    response["intervention"]["recommendedButtonText"] = (
        llm_result["recommendedButtonText"]
    )

    response["integrationPayload"]["llmCoaching"] = llm_result

    response["integrationPayload"]["notification"]["notificationBody"] = (
        llm_result["coachingMessage"]
    )

    response["integrationPayload"]["fcmPayload"]["body"] = (
        llm_result["coachingMessage"]
    )

    response["interventionConfidence"] = intelligence_result.get(
        "interventionConfidence",
        90
    )

    combined_score = (
        risk_result.get("riskScore", 0) * 0.6
        +
        velocity_result.get("velocityScore", 0) * 0.4
    )

    response["behaviourSeverityScore"] = round(
        min(combined_score, 100),
        2
    )

    risk_level = risk_result["riskLevel"]

    risk_color_map = {
        "high": "red",
        "medium": "orange",
        "low": "green"
    }

    response["aiVisibility"] = {
        "title": "ThinkTwice AI Analysis",
        "riskLabel": risk_level.upper(),
        "riskColor": risk_color_map.get(
            risk_level,
            "grey"
        ),
        "summary": f"{risk_level.upper()} financial risk detected.",
        "bulletReasons": risk_result.get(
            "reasons",
            []
        ),
        "predictionText": velocity_result.get(
            "overspendingPrediction",
            {}
        ).get(
            "prediction",
            "Current spending behaviour remains manageable."
        ),
        "recommendedActionText": llm_result.get(
            "recommendedButtonText",
            nudge_result.get(
                "nudge",
                "Keep maintaining healthy spending behaviour."
            )
        ),
        "confidenceText": f"{response['interventionConfidence']}%",
        "severityScoreText": f"{response['behaviourSeverityScore']}/100",
        "riskTags": intelligence_result.get(
            "riskTags",
            []
        ),
        "recommendationPriority": intelligence_result.get(
            "recommendationPriority",
            "normal"
        ),
        "isAiMonitoringLive": True,
        "aiStatus": "LIVE AI MONITORING"
    }

    response["explainability"] = {
        "question": "Why am I seeing this?",
        "reasons": risk_result.get(
            "reasons",
            []
        ),
        "behaviourInsights": [
            behaviour_result.get(
                "behaviourPattern",
                "Spending behaviour was analysed."
            ),
            velocity_result.get(
                "spendingTrend",
                "Spending behaviour remains stable."
            ),
            "ThinkTwice detected increased financial risk."
        ],
        "transparencyNote":
        "ThinkTwice only recommends actions. Financial actions always require user approval.",
        "summary": explanation_result.get(
            "explainabilitySummary",
            {}
        )
    }

    response["aiTimeline"] = [
        {
            "step": 1,
            "agent": "Transaction Processor",
            "agentType": "transaction_ingestion",
            "event": "Transaction received"
        },
        {
            "step": 2,
            "agent": "Behaviour Analysis Logic",
            "agentType": "behaviour_analysis",
            "event": behaviour_result.get(
                "behaviourPattern",
                "Behaviour pattern analysed"
            )
        },
        {
            "step": 3,
            "agent": "Spending Risk Agent",
            "agentType": "risk_detection",
            "event": "Financial risk analysed"
        },
        {
            "step": 4,
            "agent": "Spending Velocity Agent",
            "agentType": "velocity_prediction",
            "event": velocity_result.get(
                "spendingTrend",
                "Spending velocity evaluated"
            )
        },
        {
            "step": 5,
            "agent": "Financial Orchestrator Agent",
            "agentType": "intervention_orchestration",
            "event": orchestrator_result.get(
                "interventionReason",
                "Best intervention selected"
            )
        },
        {
            "step": 6,
            "agent": "Nudge Agent",
            "agentType": "nudge_generation",
            "event": "Personalised intervention generated"
        },
        {
            "step": 7,
            "agent": "Learning Loop Agent",
            "agentType": "adaptive_learning",
            "event": learning_result.get(
                "futureRecommendation",
                "Future recommendation updated"
            )
        }
    ]

    response["firestorePayload"] = {
        "collectionPath": f"users/{user.user_id}/ai/latest_ai_analysis",
        "data": {
            "userId": user.user_id,
            "riskLevel": risk_level,
            "riskScore": risk_result.get(
                "riskScore",
                0
            ),
            "spendingRatio": risk_result.get(
                "spendingRatio",
                0
            ),
            "reasons": risk_result.get(
                "reasons",
                []
            ),
            "prediction": response["aiVisibility"]["predictionText"],
            "recommendedAction": response["aiVisibility"]["recommendedActionText"],
            "finalAction": orchestrator_result["finalAction"],
            "interventionConfidence": response["interventionConfidence"],
            "behaviourSeverityScore": response["behaviourSeverityScore"],
            "triggerSmartRadar":
            orchestrator_result["smartRadar"]["triggerSmartRadar"],
            "radarCategory":
            orchestrator_result["smartRadar"]["radarCategory"],
            "resilienceScore": score_result.get(
                "resilienceScore",
                50
            ),
            "smartDecisionScore": score_result.get(
                "smartDecisionScore",
                50
            ),
            "behaviourGrade": score_result.get(
                "behaviourGrade",
                "moderate"
            ),
            "streakStatus": score_result.get(
                "streakStatus",
                "at_risk"
            ),
            "learningStatus": learning_result.get(
                "learningStatus",
                ""
            ),
            "nextBestIntervention": learning_result.get(
                "nextBestIntervention",
                ""
            ),
            "updatedAt": "SERVER_TIMESTAMP"
        }
    }

    response["aiHistory"] = [
        {
            "date": "2026-05-10",
            "riskLevel": risk_level,
            "finalAction": orchestrator_result["finalAction"],
            "confidence": response["interventionConfidence"],
            "severityScore": response["behaviourSeverityScore"]
        }
    ]

    return response