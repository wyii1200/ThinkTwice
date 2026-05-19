from utils.transaction_utils import safe_divide


def calculate_scores(
    user,
    risk_level
):

    current_score = getattr(user, "money_habit_score", None)
    if current_score is None:
        current_score = 75
        if getattr(user, "budget_profile", None) and getattr(user.budget_profile, "adaptability_score", None) is not None:
            current_score = user.budget_profile.adaptability_score

    money_habit_score = current_score
    smart_decision_score = current_score

    spending_ratio = safe_divide(
        user.current_daily_spending,
        user.daily_budget
    )

    transaction_count = len(
        user.transactions
    )

    # =========================================================
    # 1. BUDGET DISCIPLINE SCORE
    # =========================================================

    if spending_ratio < 0.5:

        money_habit_score += 20
        smart_decision_score += 20

    elif spending_ratio < 0.75:

        money_habit_score += 10
        smart_decision_score += 10

    elif spending_ratio >= 1.2:

        money_habit_score -= 12
        smart_decision_score -= 10

    elif spending_ratio >= 1:

        money_habit_score -= 10
        smart_decision_score -= 8

    # =========================================================
    # 2. RISK IMPACT SCORE
    # =========================================================

    if risk_level == "high":

        money_habit_score -= 10
        smart_decision_score -= 10

    elif risk_level == "medium":

        money_habit_score -= 5
        smart_decision_score -= 5

    else:

        money_habit_score += 5
        smart_decision_score += 5

    # =========================================================
    # 3. FREQUENCY IMPACT
    # =========================================================

    if transaction_count >= 5:

        money_habit_score -= 5
        smart_decision_score -= 5

    elif transaction_count <= 2:

        money_habit_score += 3
        smart_decision_score += 3

    # =========================================================
    # 4. SAVINGS GOAL SUPPORT
    # =========================================================

    if user.savings_goal >= 500:

        money_habit_score += 5

    elif user.savings_goal >= 200:

        money_habit_score += 3

    # =========================================================
    # 5. SCORE LIMIT
    # =========================================================

    money_habit_score = max(
        0,
        min(100, money_habit_score)
    )

    smart_decision_score = max(
        0,
        min(100, smart_decision_score)
    )

    average_score = (
        money_habit_score +
        smart_decision_score
    ) / 2

    # =========================================================
    # 6. HUMAN LABELS
    # =========================================================

    if average_score >= 80:

        behaviour_grade = "excellent"

        money_habit_label = (
            "Strong Money Habits"
        )

        dashboard_message = (
            "You’re building strong money habits. Keep going 👏"
        )

    elif average_score >= 65:

        behaviour_grade = "good"

        money_habit_label = (
            "Good Money Habits"
        )

        dashboard_message = (
            "Your spending is mostly on track today."
        )

    elif average_score >= 50:

        behaviour_grade = "moderate"

        money_habit_label = (
            "Needs Attention"
        )

        dashboard_message = (
            "A small adjustment today can help protect your budget."
        )

    else:

        behaviour_grade = "high_risk"

        money_habit_label = (
            "At Risk"
        )

        dashboard_message = (
            "ThinkTwice is helping you slow down before overspending."
        )

    # =========================================================
    # 7. STREAK LABEL
    # =========================================================

    streak_status = (
        "maintained"
        if money_habit_score >= 70
        else "at_risk"
    )

    smart_spending_streak = (
        "Smart Spending Streak Maintained"
        if streak_status == "maintained"
        else "Smart Spending Streak Needs Support"
    )

    return {
        # Keep old key for compatibility
        "resilienceScore": money_habit_score,

        # New preferred key for frontend
        "moneyHabitScore": money_habit_score,

        "smartDecisionScore": smart_decision_score,

        "behaviourGrade": behaviour_grade,

        "moneyHabitLabel": money_habit_label,

        "dashboardMessage": dashboard_message,

        "streakStatus": streak_status,

        "smartSpendingStreak": smart_spending_streak,

        "scoreImpactLabel": (
            "+3" if risk_level == "low"
            else "+1" if risk_level == "medium"
            else "-2"
        ),

        "frontendScoreStatus": (
            "safe" if average_score >= 65
            else "warning" if average_score >= 50
            else "risk"
        )

    }