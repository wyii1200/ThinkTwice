def calculate_risk(user):

    spending_ratio = (
        user.current_daily_spending / user.daily_budget
    )

    risk_score = spending_ratio * 100

    reasons = []

    # Budget overspending
    if spending_ratio >= 1:
        reasons.append("Daily budget exceeded.")
        risk_score += 20

    elif spending_ratio >= 0.75:
        reasons.append("Close to daily budget limit.")
        risk_score += 10

    # Category overspending
    food_spending = 0

    for transaction in user.transactions:

        if transaction.category.lower() == "food":
            food_spending += transaction.amount

    if food_spending >= 30:
        reasons.append("High food spending detected.")
        risk_score += 15

    # Spending frequency
    if len(user.transactions) >= 5:
        reasons.append("High transaction frequency detected.")
        risk_score += 10

    # Late-night spending
    late_night = False

    for transaction in user.transactions:

        if "PM" in transaction.time:

            hour = int(transaction.time.split(":")[0])

            if hour >= 10:
                late_night = True

    if late_night:
        reasons.append("Late-night spending behaviour detected.")
        risk_score += 10

    # Final risk level
    if risk_score >= 120:
        risk_level = "high"

    elif risk_score >= 80:
        risk_level = "medium"

    else:
        risk_level = "low"

    return {
        "riskLevel": risk_level,
        "riskScore": round(risk_score, 2),
        "reasons": reasons
    }