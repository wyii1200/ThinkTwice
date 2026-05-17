from config.constants import RISK_LEVELS

from utils.transaction_utils import (
    safe_divide,
    normalize_category,
    is_late_night_time
)


HIGH_RISK_MERCHANTS = [
    "bubble tea",
    "starbucks",
    "coffee",
    "dessert",
    "snack",
    "shopping",
    "shoes",
    "fashion"
]


def calculate_risk(user):

    spending_ratio = safe_divide(
        user.current_daily_spending,
        user.daily_budget
    )

    risk_score = spending_ratio * 100

    reasons = []

    latest_transaction = (
        user.transactions[-1]
        if user.transactions
        else None
    )

    # =========================================================
    # 1. DAILY BUDGET PRESSURE
    # =========================================================

    if spending_ratio >= 1.2:

        reasons.append(
            "You have already exceeded today's safe spending limit."
        )

        risk_score += 30

    elif spending_ratio >= 1:

        reasons.append(
            "You are very close to exceeding today's spending limit."
        )

        risk_score += 20

    elif spending_ratio >= 0.75:

        reasons.append(
            "You are approaching today's spending limit."
        )

        risk_score += 10

    # =========================================================
    # 2. CATEGORY SPENDING ANALYSIS
    # =========================================================

    category_totals = {}

    for transaction in user.transactions:

        category = normalize_category(
            transaction.category
        )

        category_totals[category] = (
            category_totals.get(category, 0)
            +
            transaction.amount
        )

    food_spending = category_totals.get(
        "food",
        0
    )

    shopping_spending = category_totals.get(
        "shopping",
        0
    )

    entertainment_spending = category_totals.get(
        "entertainment",
        0
    )

    transport_spending = category_totals.get(
        "transport",
        0
    )

    if food_spending >= 30:

        reasons.append(
            "Your food spending is higher than usual today."
        )

        risk_score += 20

    if shopping_spending >= 40:

        reasons.append(
            "Your shopping spending is higher than usual today."
        )

        risk_score += 18

    if entertainment_spending >= 40:

        reasons.append(
            "Entertainment spending increased significantly today."
        )

        risk_score += 12

    if transport_spending >= 25:

        reasons.append(
            "Transport spending is slightly higher than usual."
        )

        risk_score += 5

    # =========================================================
    # 3. TRANSACTION FREQUENCY ANALYSIS
    # =========================================================

    transaction_count = len(
        user.transactions
    )

    if transaction_count >= 5:

        reasons.append(
            "You’ve been making purchases more frequently today."
        )

        risk_score += 12

    elif transaction_count >= 3:

        reasons.append(
            "Several purchases were detected today."
        )

        risk_score += 5

    # =========================================================
    # 4. LATE NIGHT IMPULSE DETECTION
    # =========================================================

    late_night_detected = any(
        is_late_night_time(transaction.time)
        for transaction in user.transactions
    )

    if late_night_detected:

        reasons.append(
            "Late-night spending may increase impulse purchase risk."
        )

        risk_score += 12

    # =========================================================
    # 5. MERCHANT-LEVEL IMPULSE DETECTION
    # =========================================================

    if latest_transaction:

        merchant_name = (
            latest_transaction.merchant or ""
        ).lower()

        if any(
            keyword in merchant_name
            for keyword in HIGH_RISK_MERCHANTS
        ):

            reasons.append(
                "This purchase may be an impulse spending decision."
            )

            risk_score += 20

    # =========================================================
    # 6. PRE-CONFIRMATION AI INTERVENTION
    # =========================================================

    if latest_transaction:

        status = getattr(
            latest_transaction,
            "status",
            None
        )

        if status == "before_confirmation":

            reasons.append(
                "ThinkTwice is checking this purchase before payment confirmation."
            )

            risk_score += 15

    # =========================================================
    # 7. HIGH AMOUNT DETECTION
    # =========================================================

    if latest_transaction:

        latest_amount = latest_transaction.amount

        if latest_amount >= 100:

            reasons.append(
                "This is a higher-value purchase compared to your usual spending."
            )

            risk_score += 20

        elif latest_amount >= 50:

            reasons.append(
                "This purchase amount is slightly higher than normal."
            )

            risk_score += 15

    # =========================================================
    # 8. FALLBACK
    # =========================================================

    if not reasons:

        reasons.append(
            "Your current spending behaviour looks manageable."
        )

    # =========================================================
    # 9. RISK LEVEL CLASSIFICATION
    # =========================================================

    if risk_score >= 120:

        risk_level = RISK_LEVELS["HIGH"]

    elif risk_score >= 80:

        risk_level = RISK_LEVELS["MEDIUM"]

    else:

        risk_level = RISK_LEVELS["LOW"]

    # =========================================================
    # 10. HUMAN-FRIENDLY RISK LABEL
    # =========================================================

    if risk_level == "high":

        human_risk_label = (
            "🔥 Impulse Purchase Detected"
        )

    elif risk_level == "medium":

        human_risk_label = (
            "⚠️ Budget Warning"
        )

    else:

        human_risk_label = (
            "✅ Safe Spending"
        )

    # =========================================================
    # 11. HUMAN SUMMARY
    # =========================================================

    if risk_level == "high":

        human_summary = (
            "There’s a high chance this spending may affect your weekly budget."
        )

    elif risk_level == "medium":

        human_summary = (
            "This purchase may slightly affect your budget."
        )

    else:

        human_summary = (
            "This spending behaviour currently looks healthy."
        )

    # =========================================================
    # 12. RETURN
    # =========================================================

    return {
        "riskLevel": risk_level,
        "riskLabel": human_risk_label,
        "riskSummary": human_summary,
        "riskScore": round(
            min(risk_score, 100),
            2
        ),
        "spendingRatio": round(
            spending_ratio,
            2
        ),
        "categoryBreakdown": category_totals,
        "transactionCount": transaction_count,
        "lateNightDetected": late_night_detected,
        "reasons": reasons
    }