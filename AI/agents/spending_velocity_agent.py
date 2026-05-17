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

    if velocity_score >= 150:
        velocity_label = "🔥 High Overspending Risk"

    elif velocity_score >= 100:
        velocity_label = "⚠️ Budget Risk Increasing"

    elif velocity_score >= 50:
        velocity_label = "👀 Spending Under Monitoring"

    else:
        velocity_label = "✅ Stable Spending"

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