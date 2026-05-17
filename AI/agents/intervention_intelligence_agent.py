def evaluate_intervention_intelligence(
    risk_result,
    behaviour_result,
    velocity_result
):

    confidence = 55

    reasons = risk_result.get(
        "reasons",
        []
    )

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

    transaction_count = behaviour_result.get(
        "transactionCount",
        0
    )

    # =========================================================
    # 1. RISK SCORE SIGNALS
    # =========================================================

    if risk_score >= 90:
        confidence += 20

    elif risk_score >= 75:
        confidence += 15

    elif risk_score >= 60:
        confidence += 8

    # =========================================================
    # 2. HUMAN REASON MATCHING
    # =========================================================

    reason_text = " ".join(
        reasons
    ).lower()

    keyword_confidence_map = {

        "safe spending limit": 15,

        "approaching today's spending limit": 10,

        "spending more frequently": 10,

        "several purchases": 5,

        "food spending": 10,

        "shopping spending": 10,

        "entertainment spending": 8,

        "transport spending": 5,

        "before payment confirmation": 8,

        "late-night": 10,

        "impulse": 15
    }

    for keyword, score in keyword_confidence_map.items():

        if keyword in reason_text:
            confidence += score

    # =========================================================
    # 3. BEHAVIOUR SIGNALS
    # =========================================================

    if late_night:
        confidence += 10

    if transaction_count >= 5:
        confidence += 8

    elif transaction_count >= 3:
        confidence += 5

    # =========================================================
    # 4. VELOCITY SIGNALS
    # =========================================================

    if velocity == "very_fast":
        confidence += 15

    elif velocity == "fast":
        confidence += 10

    elif velocity == "watch":
        confidence += 5

    elif velocity == "slow":
        confidence -= 5

    # =========================================================
    # 5. CATEGORY RISK
    # =========================================================

    risky_categories = [
        "food",
        "shopping",
        "entertainment",
        "transport"
    ]

    if primary_category in risky_categories:
        confidence += 5

    # =========================================================
    # 6. LIMIT CONFIDENCE
    # =========================================================

    confidence = max(
        0,
        min(confidence, 100)
    )

    # =========================================================
    # 7. SEVERITY LEVEL
    # =========================================================

    if risk_score >= 90:
        severity = "critical"

    elif risk_score >= 75:
        severity = "high"

    elif risk_score >= 55:
        severity = "moderate"

    else:
        severity = "low"

    # =========================================================
    # 8. PRIORITY
    # =========================================================

    if confidence >= 90:
        priority = "urgent"

    elif confidence >= 75:
        priority = "important"

    elif confidence >= 60:
        priority = "normal"

    else:
        priority = "low"

    # =========================================================
    # 9. RISK TAGS
    # =========================================================

    risk_tags = []

    if late_night:
        risk_tags.append(
            "Late-Night Spending"
        )

    if velocity == "very_fast":
        risk_tags.append(
            "Spending Spike"
        )

    elif velocity == "fast":
        risk_tags.append(
            "Fast Spending Pattern"
        )

    if primary_category == "food":
        risk_tags.append(
            "Food Overspending"
        )

    elif primary_category == "shopping":
        risk_tags.append(
            "Shopping Overspending"
        )

    elif primary_category == "entertainment":
        risk_tags.append(
            "Entertainment Overspending"
        )

    elif primary_category == "transport":
        risk_tags.append(
            "Transport Overspending"
        )

    if severity == "critical":
        risk_tags.append(
            "Critical Budget Risk"
        )

    elif severity == "high":
        risk_tags.append(
            "High Financial Risk"
        )

    # =========================================================
    # 10. AI VISIBILITY
    # =========================================================

    if confidence >= 90:

        ai_confidence_label = (
            "AI is highly confident this purchase may affect your budget."
        )

    elif confidence >= 75:

        ai_confidence_label = (
            "AI detected several spending risk signals."
        )

    elif confidence >= 60:

        ai_confidence_label = (
            "AI noticed early spending pressure."
        )

    else:

        ai_confidence_label = (
            "AI will continue monitoring spending behaviour."
        )

    recommended_intervention = (
    "Smart Radar + Save Recommendation"
    if confidence >= 85
    else
    "Budget Warning"
    if confidence >= 60
    else
    "Monitoring Only"
)

    # =========================================================
    # RETURN
    # =========================================================

    return {

        "severityLevel":
        severity,

        "interventionConfidence":
        confidence,

        "recommendationPriority":
        priority,

        "riskTags":
        risk_tags,

        "aiConfidenceLabel":
        ai_confidence_label,

        "aiMonitoringMode":
        "pre_confirmation_intervention",

        "frontendUrgency": priority,

        "recommendedIntervention": recommended_intervention
    }