def generate_explanation(
    risk_result,
    behaviour_result,
    orchestrator_result
):

    explanations = []

    # Risk explanations
    for reason in risk_result["reasons"]:
        explanations.append(reason)

    # Behaviour explanations
    if behaviour_result["lateNightSpending"]:
        explanations.append(
            "Late-night spending behaviour increases impulsive spending risk."
        )

    # Intervention explanations
    intervention = orchestrator_result["selectedIntervention"]

    if intervention == "auto_save":
        explanations.append(
            "AI recommends micro-saving to reduce overspending risk."
        )

    elif intervention == "smart_radar_and_auto_save":
        explanations.append(
            "AI recommends cheaper nearby alternatives and micro-saving action."
        )

    elif intervention == "send_warning_nudge":
        explanations.append(
            "AI detected moderate financial risk and triggered a warning nudge."
        )

    # Safety explanation
    safety = orchestrator_result.get("safetyCheck", {})

    if safety.get("requiresUserConsent"):
        explanations.append(
            "Financial actions require user approval before execution."
        )

    return {
        "aiExplanation": explanations
    }