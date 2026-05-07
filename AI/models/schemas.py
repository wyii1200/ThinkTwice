from pydantic import BaseModel
from typing import List, Optional


class Transaction(BaseModel):
    transaction_id: Optional[str] = None
    amount: float
    category: str
    time: str
    location: Optional[str] = None


class UserProfile(BaseModel):
    user_id: Optional[str] = None
    daily_budget: float
    current_daily_spending: float
    savings_goal: float
    transactions: List[Transaction]
    user_action: Optional[str] = None