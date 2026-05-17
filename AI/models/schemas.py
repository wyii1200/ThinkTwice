from pydantic import BaseModel
from typing import List, Optional


class Transaction(BaseModel):
    transaction_id: Optional[str] = None
    amount: float
    category: str
    time: str
    location: Optional[str] = None
    merchant: Optional[str] = None
    status: Optional[str] = "before_confirmation"


class UserAction(BaseModel):
    actionType: Optional[str] = None
    timestamp: Optional[str] = None
    interactionSource: Optional[str] = None


class UserProfile(BaseModel):
    user_id: Optional[str] = "demo_user"
    daily_budget: float
    current_daily_spending: float
    savings_goal: float
    transactions: List[Transaction]
    user_action: Optional[UserAction] = None