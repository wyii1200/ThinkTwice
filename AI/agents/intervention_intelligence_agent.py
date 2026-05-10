def evaluate_intervention_intelligence(
    risk_result,
    behaviour_result,
    velocity_result
):

    confidence = 50

    reasons = risk_result.get("reasons", [])

    risk_score = risk_result.get(
        "riskScore",
        0
    )

    velocity = velocity_result.get(
        "spendingVelocity",
        "normal"
    )

    late_night = behaviour_result.get(
        "lateNightSpending",
        False
    )

    primary_category = behaviour_result.get(
        "primaryCategory",
        "unknown"
    )

    if "Daily budget exceeded." in reasons:
        confidence += 20

    if "Close to daily budget limit." in reasons:
        confidence += 10

    if "High transaction frequency detected." in reasons:
        confidence += 10

    if "Moderate transaction frequency detected." in reasons:
        confidence += 5

    if "High food spending detected." in reasons:
        confidence += 10

    if "High shopping spending detected." in reasons:
        confidence += 8

    if "High entertainment spending detected." in reasons:
        confidence += 8

    if late_night:
        confidence += 12

    if velocity == "very_fast":
        confidence += 15

    elif velocity == "fast":
        confidence += 8

    elif velocity == "normal":
        confidence += 3

    elif velocity == "slow":
        confidence -= 5

    risky_categories = [
        "food",
        "shopping",
        "entertainment"
    ]

    if primary_category in risky_categories:
        confidence += 5

    confidence = max(
        0,
        min(confidence, 100)
    )

    if risk_score >= 170:
        severity = "critical"

    elif risk_score >= 120:
        severity = "high"

    elif risk_score >= 80:
        severity = "moderate"

    else:
        severity = "low"

    if confidence >= 90:
        priority = "urgent"

    elif confidence >= 75:
        priority = "important"

    elif confidence >= 60:
        priority = "normal"

    else:
        priority = "low"

    risk_tags = []

    if late_night:
        risk_tags.append("Late-Night Spending")

    if velocity == "very_fast":
        risk_tags.append("Spending Spike")

    elif velocity == "fast":
        risk_tags.append("Fast Spending Velocity")

    if primary_category == "food":
        risk_tags.append("Food Overspending")

    elif primary_category == "shopping":
        risk_tags.append("Shopping Overspending")

    elif primary_category == "entertainment":
        risk_tags.append("Entertainment Overspending")

    if severity == "critical":
        risk_tags.append("Critical Overspending Risk")

    elif severity == "high":
        risk_tags.append("High Financial Risk")


    return {
        "severityLevel": severity,
        "interventionConfidence": confidence,
        "recommendationPriority": priority,
        "riskTags": risk_tags
    }