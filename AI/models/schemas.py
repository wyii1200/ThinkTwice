from pydantic import BaseModel, Field
from typing import List, Optional


class Transaction(BaseModel):
    transaction_id: Optional[str] = "demo_txn_001"
    merchant: Optional[str] = "Bubble Tea"
    amount: float = 18
    category: str = "food"
    time: str = "10:45 PM"
    location: Optional[str] = "Mid Valley"
    status: Optional[str] = "before_confirmation"


class UserAction(BaseModel):
    actionType: Optional[str] = None
    timestamp: Optional[str] = None
    interactionSource: Optional[str] = None


class BudgetProfile(BaseModel):
    weekly_food_budget: Optional[float] = 80
    weekly_spent_food: Optional[float] = 68
    daily_safe_limit: Optional[float] = 25
    preferred_savings_amount: Optional[float] = 8


class UserProfile(BaseModel):
    user_id: Optional[str] = "demo_user"

    daily_budget: float = 25
    current_daily_spending: float = 30
    savings_goal: float = 200

    transactions: List[Transaction] = Field(
        default_factory=lambda: [
            Transaction()
        ]
    )

    budget_profile: Optional[BudgetProfile] = Field(
        default_factory=BudgetProfile
    )

    user_action: Optional[UserAction] = None

    demo_scenario: Optional[str] = "bubble_tea_high_risk"