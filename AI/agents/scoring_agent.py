from utils.transaction_utils import safe_divide


def calculate_scores(
    user,
    risk_level
):


    resilience_score = 50
    smart_decision_score = 50

    spending_ratio = safe_divide(
        user.current_daily_spending,
        user.daily_budget
    )

    transaction_count = len(
        user.transactions
    )

    if spending_ratio < 0.5:

        resilience_score += 20
        smart_decision_score += 20

    elif spending_ratio < 0.75:

        resilience_score += 10
        smart_decision_score += 10

    elif spending_ratio >= 1:

        resilience_score -= 20
        smart_decision_score -= 20

    if risk_level == "high":

        resilience_score -= 10
        smart_decision_score -= 10

    elif risk_level == "medium":

        resilience_score -= 5
        smart_decision_score -= 5

    if transaction_count >= 5:

        resilience_score -= 5
        smart_decision_score -= 5

    if user.savings_goal >= 500:

        resilience_score += 5

    resilience_score = max(
        0,
        min(100, resilience_score)
    )

    smart_decision_score = max(
        0,
        min(100, smart_decision_score)
    )

    average_score = (
        resilience_score +
        smart_decision_score
    ) / 2

    if average_score >= 80:
        behaviour_grade = "excellent"

    elif average_score >= 65:
        behaviour_grade = "good"

    elif average_score >= 50:
        behaviour_grade = "moderate"

    else:
        behaviour_grade = "high_risk"


    if resilience_score >= 70:
        streak_status = "maintained"

    else:
        streak_status = "at_risk"

    return {
        "resilienceScore":
        resilience_score,

        "smartDecisionScore":
        smart_decision_score,

        "behaviourGrade":
        behaviour_grade,

        "streakStatus":
        streak_status
    }