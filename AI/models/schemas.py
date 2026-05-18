from pydantic import BaseModel
from typing import List, Optional, Literal, Dict, Any


class TransactionInfo(BaseModel):
    amount: float
    merchant: str
    category: str
    time: str


class RiskInfo(BaseModel):
    level: Literal["low", "medium", "high", "critical"]
    score: int
    confidence: float


class UiMessage(BaseModel):
    headline: str
    explanation: str
    futureImpact: str
    suggestedAction: str


class ActionButtons(BaseModel):
    primary: str
    secondary: str
    danger: Optional[str] = None


class SmartRadarPayload(BaseModel):
    trigger: bool
    category: str
    message: str


class DashboardUpdate(BaseModel):
    resilienceScoreChange: int
    savingOpportunity: float
    budgetStatus: str


class AiDecisionResponse(BaseModel):
    transaction: TransactionInfo
    risk: RiskInfo
    ui: UiMessage
    reasons: List[str]
    actions: ActionButtons
    smartRadar: SmartRadarPayload
    dashboardUpdate: DashboardUpdate
    debug: Optional[Dict[str, Any]] = None

class Transaction(BaseModel):
    amount: float
    merchant: str
    category: str
    time: str
    location: Optional[str] = None


class BudgetProfile(BaseModel):
    weekly_food_budget: float
    weekly_spent_food: float
    daily_safe_limit: float
    preferred_savings_amount: float
    adaptability_score: Optional[int] = None
    savings_rate: Optional[float] = None
    flexible_spend: Optional[float] = None
    category_percents: Optional[Dict[str, float]] = None

class UserProfile(BaseModel):
    user_id: str
    daily_budget: float
    current_daily_spending: float
    savings_goal: float

    transactions: List[Transaction]

    user_action: Optional[str] = None
    budget_profile: Optional[BudgetProfile] = None