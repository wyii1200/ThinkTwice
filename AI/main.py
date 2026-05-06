from fastapi import FastAPI

from models.schemas import UserProfile

from agents.spending_risk_agent import calculate_risk
from agents.nudge_agent import generate_nudge
from agents.autosave_agent import suggest_savings
from agents.behaviour_analysis import analyse_behaviour

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

    savings_amount = suggest_savings(
        risk_result["riskLevel"]
    )

    behaviour_result = analyse_behaviour(user)

    return {
        **risk_result,
        **nudge_result,
        "suggestedSavingsAmount": savings_amount,
        "behaviourAnalysis": behaviour_result
    }