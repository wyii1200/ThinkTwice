from config.constants import RISK_LEVELS
from utils.transaction_utils import safe_divide, normalize_category, is_late_night_time


def calculate_risk(user):
    spending_ratio = safe_divide(
        user.current_daily_spending,
        user.daily_budget
    )

    risk_score = spending_ratio * 100
    reasons = []

    if spending_ratio >= 1:
        reasons.append("Daily budget exceeded.")
        risk_score += 20

    elif spending_ratio >= 0.75:
        reasons.append("Close to daily budget limit.")
        risk_score += 10

    category_totals = {}

    for transaction in user.transactions:
        category = normalize_category(transaction.category)
        category_totals[category] = category_totals.get(category, 0) + transaction.amount

    food_spending = category_totals.get("food", 0)
    shopping_spending = category_totals.get("shopping", 0)
    entertainment_spending = category_totals.get("entertainment", 0)

    if food_spending >= 30:
        reasons.append("High food spending detected.")
        risk_score += 15

    if shopping_spending >= 40:
        reasons.append("High shopping spending detected.")
        risk_score += 12

    if entertainment_spending >= 40:
        reasons.append("High entertainment spending detected.")
        risk_score += 12

    transaction_count = len(user.transactions)

    if transaction_count >= 5:
        reasons.append("High transaction frequency detected.")
        risk_score += 10

    elif transaction_count >= 3:
        reasons.append("Moderate transaction frequency detected.")
        risk_score += 5

    late_night = any(
        is_late_night_time(transaction.time)
        for transaction in user.transactions
    )

    if late_night:
        reasons.append("Late-night spending behaviour detected.")
        risk_score += 10

    if not reasons:
        reasons.append("Current spending behaviour remains manageable.")

    if risk_score >= 120:
        risk_level = RISK_LEVELS["HIGH"]

    elif risk_score >= 80:
        risk_level = RISK_LEVELS["MEDIUM"]

    else:
        risk_level = RISK_LEVELS["LOW"]

    return {
        "riskLevel": risk_level,
        "riskScore": round(risk_score, 2),
        "spendingRatio": round(spending_ratio, 2),
        "categoryBreakdown": category_totals,
        "reasons": reasons
    }