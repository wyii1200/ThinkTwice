def generate_explanation(
    risk_result,
    behaviour_result,
    orchestrator_result,
    velocity_result=None
):

    explanations = []
    explainability_reasons = []

    primary_category = behaviour_result.get(
        "primaryCategory",
        "spending"
    )

    def add_reason(reason):
        if reason and reason not in explanations:
            explanations.append(reason)

        if reason and reason not in explainability_reasons:
            explainability_reasons.append(reason)

    for reason in risk_result.get("reasons", []):
        add_reason(reason)

    user_friendly_insight = behaviour_result.get(
        "userFriendlyInsight"
    )

    if user_friendly_insight:
        add_reason(user_friendly_insight)

    if behaviour_result.get("lateNightSpending"):
        add_reason(
            "This happened at a time when impulse spending risk is usually higher."
        )

    if behaviour_result.get("riskyCategoryDetected"):
        add_reason(
            f"{primary_category.capitalize()} is your most active spending category today."
        )

    if velocity_result:
        add_reason(
            velocity_result.get(
                "spendingTrend",
                "Your spending behaviour looks stable."
            )
        )

        add_reason(
            velocity_result.get(
                "overspendingPrediction",
                {}
            ).get(
                "prediction",
                "Your spending currently looks manageable."
            )
        )

    final_action = orchestrator_result.get(
        "finalAction",
        ""
    )

    if final_action in [
        "auto_save",
        "micro_save_recommendation",
        "save_rm8_instead"
    ]:
        recommended_explanation = (
            "ThinkTwice suggests a small save before you continue, so this purchase has less impact on your weekly budget."
        )

        recommendation_type = "Micro Save"

    elif final_action in [
        "smart_radar_and_auto_save",
        "smart_radar_and_save_nudge",
        "SMART_RADAR_AND_SAVE_NUDGE"
    ]:
        add_reason(
            "Smart Radar found a cheaper nearby option that may help you save money today."
        )

        recommended_explanation = (
            "Smart Radar helps you compare nearby alternatives before confirming payment."
        )

        recommendation_type = "Smart Radar"

    elif final_action in [
        "send_warning_nudge",
        "continue_with_warning",
        "CONTINUE_WITH_WARNING"
    ]:
        recommended_explanation = (
            "A gentle warning is enough because the risk is still manageable."
        )

        recommendation_type = "Budget Warning"

    else:
        recommended_explanation = (
            "No strong intervention is needed right now."
        )

        recommendation_type = "Safe Spending"

    safety = orchestrator_result.get(
        "safetyCheck",
        {}
    )

    if safety.get("requiresUserConsent", True):
        add_reason(
            "You stay in control. ThinkTwice will not move money without your approval."
        )

    main_reason = (
        explanations[0]
        if explanations
        else "ThinkTwice checked this purchase before payment confirmation."
    )

    return {
        "aiExplanation": explanations,

        "explainabilitySummary": {
            "explainabilityLevel": "high",

            "mainReason": main_reason,

            "whyThisMatters": (
                "This helps you notice risky spending before it becomes a bigger money problem."
            ),

            "recommendedExplanation": recommended_explanation,

            "recommendationType": recommendation_type,

            "userControlNote": (
                "ThinkTwice only recommends actions. You always stay in control."
            ),

            "popupReasons": explainability_reasons,

            "simpleFlow": [
                "Payment intent detected before confirmation",
                "Spending pattern checked",
                "Budget impact predicted",
                "Best intervention selected"
            ]
        }
    }