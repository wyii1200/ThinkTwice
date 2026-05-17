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

    for reason in risk_result.get("reasons", []):
        explanations.append(reason)
        explainability_reasons.append(reason)

    user_friendly_insight = behaviour_result.get(
        "userFriendlyInsight"
    )

    if user_friendly_insight:
        explanations.append(user_friendly_insight)
        explainability_reasons.append(user_friendly_insight)

    if behaviour_result.get("lateNightSpending"):

        explanations.append(
            "Late-night purchases are more likely to become impulse spending."
        )

        explainability_reasons.append(
            "This purchase happened at a time when impulse spending risk is usually higher."
        )

    if behaviour_result.get("riskyCategoryDetected"):

        explanations.append(
            f"{primary_category.capitalize()} is your most active spending category today."
        )

        explainability_reasons.append(
            f"ThinkTwice noticed repeated {primary_category} spending today."
        )

    if velocity_result:

        spending_trend = velocity_result.get(
            "spendingTrend",
            "Your spending behaviour looks stable."
        )

        prediction = velocity_result.get(
            "overspendingPrediction",
            {}
        ).get(
            "prediction",
            "Your spending currently looks manageable."
        )

        explanations.append(spending_trend)
        explanations.append(prediction)

        explainability_reasons.append(prediction)

    final_action = orchestrator_result.get(
        "finalAction"
    )

    if final_action in [
        "auto_save",
        "micro_save_recommendation",
        "save_rm8_instead"
    ]:

        explanations.append(
            "ThinkTwice suggests a small save to protect your weekly budget."
        )

        recommended_explanation = (
            "A small save now can reduce the impact of this purchase."
        )

    elif final_action in [
        "smart_radar_and_auto_save",
        "smart_radar_and_save_nudge"
    ]:

        explanations.append(
            "ThinkTwice found that a cheaper nearby option may help you save money today."
        )

        recommended_explanation = (
            "Smart Radar helps you compare nearby alternatives before confirming payment."
        )

    elif final_action in [
        "send_warning_nudge",
        "continue_with_warning"
    ]:

        explanations.append(
            "ThinkTwice gives a gentle warning because you are getting close to your budget."
        )

        recommended_explanation = (
            "A quick warning is enough because the risk is still manageable."
        )

    else:

        explanations.append(
            "This purchase looks manageable based on your current spending pattern."
        )

        recommended_explanation = (
            "No strong intervention is needed right now."
        )

    safety = orchestrator_result.get(
        "safetyCheck",
        {}
    )

    if safety.get("requiresUserConsent"):

        explanations.append(
            "ThinkTwice will not move money without your approval."
        )

        explainability_reasons.append(
            "You stay in control. Any saving action needs your approval first."
        )

    return {
        "aiExplanation": explanations,

        "explainabilitySummary": {
            "mainReason":
            explanations[0] if explanations else "ThinkTwice checked this purchase before confirmation.",

            "whyThisMatters":
            "This helps you notice risky spending before it turns into a bigger money problem.",

            "recommendedExplanation":
            recommended_explanation,

            "userControlNote":
            "ThinkTwice only recommends actions. You always stay in control.",

            "popupReasons":
            explainability_reasons
        }
    }