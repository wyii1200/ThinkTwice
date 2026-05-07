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

app = FastAPI()


@app.get("/")
def home():
    return {
        "message": "ThinkTwice AI Service is running"
    }


@app.post("/analyze-risk")
def analyze_risk(user: UserProfile):

    risk_result = calculate_risk(user)

    nudge_result = generate_nudge(
        risk_result["riskLevel"]
    )

    score_result = calculate_scores(
        user,
        risk_result["riskLevel"]
    )

    savings_amount = suggest_savings(
        risk_result["riskLevel"]
    )

    behaviour_result = analyse_behaviour(user)

    velocity_result = analyse_spending_velocity(user)

    intelligence_result = evaluate_intervention_intelligence(
    risk_result,
    behaviour_result,
    velocity_result
)

    orchestrator_result = orchestrate_intervention(
    risk_result,
    score_result,
    behaviour_result
)
    
    learning_result = learning_feedback(
    risk_result["riskLevel"],
    orchestrator_result["finalAction"]
)
    
    explanation_result = generate_explanation(
    risk_result,
    behaviour_result,
    orchestrator_result
)

    return {
        **risk_result,
        **nudge_result,
        **score_result,
        **orchestrator_result,
        **learning_result,
        **explanation_result,
        **velocity_result,
        **intelligence_result,
        "suggestedSavingsAmount": savings_amount,
        "behaviourAnalysis": behaviour_result
    }