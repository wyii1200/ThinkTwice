def evaluate_intervention_intelligence(
    risk_result,
    behaviour_result,
    velocity_result
):

    confidence = 50

    # Budget exceeded
    if "Daily budget exceeded." in risk_result["reasons"]:
        confidence += 20

    # High transaction frequency
    if "High transaction frequency detected." in risk_result["reasons"]:
        confidence += 10

    # High food spending
    if "High food spending detected." in risk_result["reasons"]:
        confidence += 10

    # Late-night behaviour
    if behaviour_result["lateNightSpending"]:
        confidence += 12

    # Spending velocity
    if velocity_result["spendingVelocity"] == "very_fast":
        confidence += 15

    elif velocity_result["spendingVelocity"] == "fast":
        confidence += 8

    confidence = min(confidence, 100)

    # Severity logic
    risk_score = risk_result["riskScore"]

    if risk_score >= 170:
        severity = "critical"

    elif risk_score >= 120:
        severity = "high"

    elif risk_score >= 80:
        severity = "moderate"

    else:
        severity = "low"

    return {
        "severityLevel": severity,
        "interventionConfidence": confidence
    }