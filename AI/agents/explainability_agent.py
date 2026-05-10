def generate_explanation(
    risk_result,
    behaviour_result,
    orchestrator_result,
    velocity_result=None
):

    explanations = []

    explainability_reasons = []

    for reason in risk_result.get("reasons", []):
        explanations.append(reason)
        explainability_reasons.append(reason)

    if behaviour_result.get("lateNightSpending"):

        explanations.append(
            "Late-night spending behaviour increases impulsive spending risk."
        )

        explainability_reasons.append(
            "This transaction happened during a late-night high-risk period."
        )

    primary_category = behaviour_result.get(
        "primaryCategory",
        "spending"
    )

    if behaviour_result.get("riskyCategoryDetected"):

        explanations.append(
            f"Repeated {primary_category} spending increases category-level financial risk."
        )

        explainability_reasons.append(
            f"{primary_category.capitalize()} is currently your most active spending category."
        )

    if velocity_result:

        velocity = velocity_result.get(
            "spendingVelocity",
            "normal"
        )

        spending_trend = velocity_result.get(
            "spendingTrend",
            "Spending behaviour remains stable."
        )

        explanations.append(
            f"Spending velocity is classified as {velocity}."
        )

        explanations.append(
            spending_trend
        )

        explainability_reasons.append(
            f"Your spending speed is currently classified as {velocity}."
        )

    final_action = orchestrator_result.get(
        "finalAction"
    )

    if final_action == "auto_save":

        explanations.append(
            "AI recommends micro-saving to reduce overspending risk."
        )

        recommended_explanation = (
            "A small user-approved saving action can reduce the impact of overspending."
        )

    elif final_action == "smart_radar_and_auto_save":

        explanations.append(
            "AI recommends cheaper nearby alternatives and micro-saving action."
        )

        recommended_explanation = (
            "Smart Radar can help find cheaper alternatives while micro-saving protects the savings streak."
        )

    elif final_action == "send_warning_nudge":

        explanations.append(
            "AI detected moderate financial risk and triggered a warning nudge."
        )

        recommended_explanation = (
            "A warning nudge is enough because the risk is still manageable."
        )

    else:

        explanations.append(
            "AI detected stable behaviour and continued passive financial monitoring."
        )

        recommended_explanation = (
            "No strong intervention is needed because spending behaviour is currently manageable."
        )

    safety = orchestrator_result.get(
        "safetyCheck",
        {}
    )

    if safety.get("requiresUserConsent"):

        explanations.append(
            "Financial actions require user approval before execution."
        )

        explainability_reasons.append(
            "ThinkTwice will not move money without your approval."
        )

    return {
        "aiExplanation": explanations,

        "explainabilitySummary": {
            "mainReason":
            explanations[0] if explanations else "Spending behaviour was analysed.",

            "whyThisMatters":
            "This helps prevent small spending habits from becoming larger financial problems.",

            "recommendedExplanation":
            recommended_explanation,

            "userControlNote":
            "ThinkTwice provides recommendations only. The user stays in control of financial actions.",

            "popupReasons":
            explainability_reasons
        }
    }