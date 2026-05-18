from utils.transaction_utils import safe_divide, normalize_category


def _get_latest_transaction(user):
    if not user.transactions:
        return None

    return user.transactions[-1]


def _get_category_total(user, target_category):
    total = 0

    for transaction in user.transactions:
        category = normalize_category(
        transaction["category"]
        if isinstance(transaction, dict)
        else transaction.category
    )

        if category == target_category:
            total += transaction.amount

    return total


def analyse_spending_velocity(user):
    latest_transaction = _get_latest_transaction(user)

    latest_category = (
        normalize_category(latest_transaction.category)
        if latest_transaction
        else "general"
    )

    velocity_score = safe_divide(
        user.current_daily_spending,
        user.daily_budget
    ) * 100

    category_total = _get_category_total(
        user,
        latest_category
    )

    weekly_food_budget = getattr(
        getattr(user, "budget_profile", None),
        "weekly_food_budget",
        80
    )

    weekly_spent_food = getattr(
        getattr(user, "budget_profile", None),
        "weekly_spent_food",
        68
    )

    # =========================================================
    # 1. VELOCITY LEVEL
    # =========================================================

    if velocity_score >= 150:
        velocity = "very_fast"

    elif velocity_score >= 100:
        velocity = "fast"

    elif velocity_score >= 70:
        velocity = "watch"

    elif velocity_score >= 50:
        velocity = "normal"

    else:
        velocity = "slow"

    # =========================================================
    # 2. CATEGORY-SPECIFIC PREDICTION
    # =========================================================

    if latest_category == "food":

        projected_food_total = weekly_spent_food + (
            latest_transaction.amount
            if latest_transaction
            else 0
        )

        food_budget_ratio = safe_divide(
            projected_food_total,
            weekly_food_budget
        ) * 100

        if food_budget_ratio >= 100:

            prediction = (
                "This purchase may push your weekly food budget over the limit."
            )

            predicted_risk = "high"

            spending_trend = (
                "Your food spending is increasing faster than usual."
            )

        elif food_budget_ratio >= 85:

            prediction = (
                "At this rate, your weekly food budget may exceed within 2 days."
            )

            predicted_risk = "high"

            spending_trend = (
                "Your food spending is getting close to the weekly limit."
            )

        elif food_budget_ratio >= 70:

            prediction = (
                "Your food spending is rising, so this purchase should be checked first."
            )

            predicted_risk = "medium"

            spending_trend = (
                "Your food spending is slowly increasing."
            )

        else:

            prediction = (
                "Your food spending currently looks manageable."
            )

            predicted_risk = "low"

            spending_trend = (
                "Your food spending remains stable."
            )

    # =========================================================
    # 3. GENERAL PREDICTION
    # =========================================================

    else:

        if velocity_score >= 150:

            prediction = (
                "At this rate, your weekly budget may be exceeded within 2 days."
            )

            predicted_risk = "high"

            spending_trend = (
                "Your spending is increasing very quickly."
            )

        elif velocity_score >= 100:

            prediction = (
                "Your current spending trend may exceed your weekly budget within 4 days."
            )

            predicted_risk = "medium"

            spending_trend = (
                "Your spending has been increasing faster than usual."
            )

        elif velocity_score >= 70:

            prediction = (
                "Your spending behaviour should be monitored closely."
            )

            predicted_risk = "moderate"

            spending_trend = (
                "Your spending is slowly increasing."
            )

        else:

            prediction = (
                "Your spending currently looks manageable."
            )

            predicted_risk = "low"

            spending_trend = (
                "Your spending behaviour remains stable."
            )

    # =========================================================
    # 4. HUMAN-FRIENDLY VELOCITY LABEL
    # =========================================================

    if predicted_risk == "high":
        velocity_label = "🔥 Budget Risk Increasing"

    elif predicted_risk in ["medium", "moderate"]:
        velocity_label = "⚠️ Spending Needs Attention"

    elif velocity_score >= 50:
        velocity_label = "👀 Spending Under Monitoring"

    else:
        velocity_label = "✅ Stable Spending"

    velocity_confidence = (
        93 if predicted_risk == "high"
        else 82 if predicted_risk in ["medium", "moderate"]
        else 70
    )

    normalized_velocity_score = round(
        min(max(velocity_score, 0), 100),
        2
    )

    velocity_urgency = (
    "critical"
    if predicted_risk == "high"
    else "warning"
    if predicted_risk in ["medium", "moderate"]
    else "safe"
)

    return {
        "velocityUrgency": velocity_urgency,
        "velocityConfidence": velocity_confidence,
        "spendingVelocity": velocity,
        "velocityLabel": velocity_label,
        "velocityScore": normalized_velocity_score,
        "categoryVelocity": {
            "category": latest_category,
            "categoryTotalToday": round(
                category_total,
                2
            ),
            "weeklyFoodBudget": weekly_food_budget,
            "weeklyFoodSpent": weekly_spent_food
        },
        "spendingTrend": spending_trend,
        "overspendingPrediction": {
            "prediction": prediction,
            "predictedRisk": predicted_risk
        }
    }