def analyse_spending_velocity(user):

    velocity_score = (
        user.current_daily_spending /
        user.daily_budget
    ) * 100

    # Velocity classification
    if velocity_score >= 150:
        velocity = "very_fast"

    elif velocity_score >= 100:
        velocity = "fast"

    elif velocity_score >= 50:
        velocity = "normal"

    else:
        velocity = "slow"

    # Overspending prediction
    if velocity_score >= 150:

        prediction = (
            "User may exceed weekly budget within 2 days."
        )

        predicted_risk = "high"

    elif velocity_score >= 100:

        prediction = (
            "User may exceed weekly budget within 4 days."
        )

        predicted_risk = "medium"

    else:

        prediction = (
            "Current spending behaviour remains manageable."
        )

        predicted_risk = "low"

    return {
        "spendingVelocity": velocity,
        "velocityScore": round(velocity_score, 2),
        "overspendingPrediction": {
            "prediction": prediction,
            "predictedRisk": predicted_risk
        }
    }