from pydantic import BaseModel
from typing import List


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