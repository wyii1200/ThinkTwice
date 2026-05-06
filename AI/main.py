from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

app = FastAPI()

class Transaction(BaseModel):
    amount: float
    category: str
    time: str
    location: str

class UserProfile(BaseModel):
    daily_budget: float
    current_daily_spending: float
    savings_goal: float
    transactions: List[Transaction]

@app.get("/")
def home():
    return {"message": "ThinkTwice AI Service is running"}

@app.post("/analyze-risk")
def analyze_risk(user: UserProfile):
    spending_ratio = user.current_daily_spending / user.daily_budget

    if spending_ratio >= 1:
        risk_level = "high"
        reason = "User has exceeded the daily budget."
        suggested_action = "auto_save"
        nudge = "You have exceeded your daily budget. Save RM8 now to protect your savings streak?"
    elif spending_ratio >= 0.75:
        risk_level = "medium"
        reason = "User is close to reaching the daily budget."
        suggested_action = "send_nudge"
        nudge = "You are close to your daily budget. Try reducing your next spending."
    else:
        risk_level = "low"
        reason = "User spending is still within a safe range."
        suggested_action = "continue_tracking"
        nudge = "Good job! Your spending is still under control today."

    return {
        "riskLevel": risk_level,
        "riskScore": round(spending_ratio * 100, 2),
        "reason": reason,
        "suggestedAction": suggested_action,
        "nudge": nudge
    }