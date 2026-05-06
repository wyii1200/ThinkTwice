def calculate_risk(user):

    spending_ratio = (
        user.current_daily_spending / user.daily_budget
    )

    if spending_ratio >= 1:
        risk_level = "high"
        reason = "User has exceeded the daily budget."

    elif spending_ratio >= 0.75:
        risk_level = "medium"
        reason = "User is close to reaching the daily budget."

    else:
        risk_level = "low"
        reason = "User spending is still within a safe range."

    return {
        "riskLevel": risk_level,
        "riskScore": round(spending_ratio * 100, 2),
        "reason": reason
    }