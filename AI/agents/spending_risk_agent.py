from config.constants import RISK_LEVELS
from utils.transaction_utils import safe_divide, normalize_category, is_late_night_time


def calculate_risk(user):
    spending_ratio = safe_divide(
        user.current_daily_spending,
        user.daily_budget
    )

    risk_score = spending_ratio * 100
    reasons = []

    # 1. Budget usage risk
    if spending_ratio >= 1:
        reasons.append("You have already passed today's safe spending limit.")
        risk_score += 20

    elif spending_ratio >= 0.75:
        reasons.append("You are close to today's spending limit.")
        risk_score += 10

    # 2. Category spending risk
    category_totals = {}

    for transaction in user.transactions:
        category = normalize_category(transaction.category)
        category_totals[category] = (
            category_totals.get(category, 0) + transaction.amount
        )

    food_spending = category_totals.get("food", 0)
    shopping_spending = category_totals.get("shopping", 0)
    entertainment_spending = category_totals.get("entertainment", 0)

    if food_spending >= 30:
        reasons.append("Your food spending is higher than usual today.")
        risk_score += 15

    if shopping_spending >= 40:
        reasons.append("Your shopping spending is higher than usual today.")
        risk_score += 12

    if entertainment_spending >= 40:
        reasons.append("Your entertainment spending is higher than usual today.")
        risk_score += 12

    # 3. Frequency risk
    transaction_count = len(user.transactions)

    if transaction_count >= 5:
        reasons.append("You have been spending more often than usual today.")
        risk_score += 10

    elif transaction_count >= 3:
        reasons.append("You made several purchases today.")
        risk_score += 5

    # 4. Late-night impulse risk
    late_night = any(
        is_late_night_time(transaction.time)
        for transaction in user.transactions
    )

    if late_night:
        reasons.append("Late-night spending can increase impulse purchase risk.")
        risk_score += 10

    # 5. Pre-confirmation transaction intent
    latest_transaction = user.transactions[0] if user.transactions else None

    if latest_transaction:
        status = getattr(latest_transaction, "status", None)

        if status == "before_confirmation":
            reasons.append("This purchase is being checked before payment confirmation.")

    if not reasons:
        reasons.append("Your current spending still looks manageable.")

    # 6. Risk level classification
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