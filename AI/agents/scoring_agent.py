def calculate_scores(user, risk_level):

    resilience_score = 50
    smart_decision_score = 50

    # Spending behaviour
    spending_ratio = (
        user.current_daily_spending /
        user.daily_budget
    )

    # Good financial behaviour
    if spending_ratio < 0.5:
        resilience_score += 20
        smart_decision_score += 20

    elif spending_ratio < 0.75:
        resilience_score += 10
        smart_decision_score += 10

    # Bad financial behaviour
    elif spending_ratio >= 1:
        resilience_score -= 20
        smart_decision_score -= 20

    # Risk adjustment
    if risk_level == "high":
        resilience_score -= 10

    elif risk_level == "medium":
        resilience_score -= 5

    # Keep scores within 0–100
    resilience_score = max(
        0,
        min(100, resilience_score)
    )

    smart_decision_score = max(
        0,
        min(100, smart_decision_score)
    )

    return {
        "resilienceScore": resilience_score,
        "smartDecisionScore": smart_decision_score
    }