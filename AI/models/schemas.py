from pydantic import BaseModel, Field
from typing import List, Optional, Literal, Dict


# =========================
# Transaction Models
# =========================

class TransactionInput(BaseModel):
    amount: float
    merchant: str
    category: str
    time: str
    location: Optional[str] = None
    status: str


class TransactionInfo(BaseModel):
    amount: float
    merchant: str
    category: str
    time: str
    status: str


# =========================
# Risk Model
# =========================

class RiskInfo(BaseModel):
    level: Literal["low", "medium", "high", "critical"]
    score: int = Field(ge=0, le=100)
    confidence: Optional[float] = Field(default=None, ge=0.0, le=1.0)


# =========================
# UI Message Model
# =========================

class UiMessage(BaseModel):
    headline: str
    explanation: str
    futureImpact: str
    suggestedAction: str


# =========================
# Action System
# =========================

class ActionButton(BaseModel):
    label: str
    action: str
    style: Literal["primary", "secondary", "danger"] = "primary"


class ActionPayload(BaseModel):
    buttons: List[ActionButton]


# =========================
# Smart Radar System
# =========================

class SmartRadarPayload(BaseModel):
    triggerSmartRadar: bool
    category: Optional[str] = None
    message: Optional[str] = None
    estimatedSavings: Optional[float] = None
    priority: Optional[Literal["low", "medium", "high"]] = None


# =========================
# Dashboard / Gamification
# =========================

class DashboardUpdate(BaseModel):
    moneyHabitScore: int = Field(ge=0, le=100)
    smartSpendingStreak: int = Field(ge=0)
    moneySavedThisWeek: float = Field(ge=0)
    encouragementMessage: str


# =========================
# Timeline System
# =========================

class TimelineStep(BaseModel):
    order: int
    step: str
    status: Literal["pending", "completed", "active"]


# =========================
# Safety Layer
# =========================

class SafetyPayload(BaseModel):
    requiresUserConsent: bool
    message: str


# =========================
# AI Decision Response (MAIN OUTPUT)
# =========================

class AiDecisionResponse(BaseModel):
    transaction: TransactionInfo
    risk: RiskInfo

    ui: UiMessage
    actions: ActionPayload

    timeline: List[TimelineStep]

    reasons: List[str]

    smartRadar: SmartRadarPayload
    dashboardUpdate: DashboardUpdate
    safety: SafetyPayload


# =========================
# User Profile System
# =========================

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

    money_habit_score: Optional[int] = None

    transactions: List[TransactionInfo] = Field(default_factory=list)

    user_action: Optional[str] = None
    budget_profile: Optional[BudgetProfile] = None