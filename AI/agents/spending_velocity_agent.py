from utils.transaction_utils import safe_divide


def analyse_spending_velocity(user):

    velocity_score = safe_divide(
        user.current_daily_spending,
        user.daily_budget
    ) * 100

    if velocity_score >= 150:
        velocity = "very_fast"

    elif velocity_score >= 100:
        velocity = "fast"

    elif velocity_score >= 50:
        velocity = "normal"

    else:
        velocity = "slow"

    if velocity_score >= 150:
        prediction = (
            "User may exceed weekly budget within 2 days."
        )

        predicted_risk = "high"

        spending_trend = (
            "Critical spending acceleration detected."
        )

    elif velocity_score >= 100:
        prediction = (
            "User may exceed weekly budget within 4 days."
        )

        predicted_risk = "medium"

        spending_trend = (
            "Spending pattern increasing rapidly."
        )

    elif velocity_score >= 70:
        prediction = (
            "User spending behaviour should be monitored closely."
        )

        predicted_risk = "moderate"

        spending_trend = (
            "Moderate spending growth detected."
        )

    else:
        prediction = (
            "Current spending behaviour remains manageable."
        )

        predicted_risk = "low"

        spending_trend = (
            "Spending behaviour remains stable."
        )

    if velocity_score >= 150:
        velocity_label = "Extreme"

    elif velocity_score >= 100:
        velocity_label = "High"

    elif velocity_score >= 50:
        velocity_label = "Moderate"

    else:
        velocity_label = "Low"

    return {
        "spendingVelocity": velocity,

        "velocityLabel": velocity_label,

        "velocityScore": round(
            velocity_score,
            2
        ),

        "spendingTrend":
        spending_trend,

        "overspendingPrediction": {
            "prediction": prediction,
            "predictedRisk": predicted_risk
        }
    }