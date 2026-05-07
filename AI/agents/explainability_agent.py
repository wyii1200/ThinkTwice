def generate_explanation(
    risk_result,
    behaviour_result,
    orchestrator_result,
    velocity_result=None
):
    explanations = []

    for reason in risk_result.get("reasons", []):
        explanations.append(reason)

    if behaviour_result.get("lateNightSpending"):
        explanations.append(
            "Late-night spending behaviour increases impulsive spending risk."
        )

    if velocity_result:
        explanations.append(
            f"Spending velocity is classified as {velocity_result['spendingVelocity']}."
        )

    final_action = orchestrator_result.get("finalAction")

    if final_action == "auto_save":
        explanations.append(
            "AI recommends micro-saving to reduce overspending risk."
        )

    elif final_action == "smart_radar_and_auto_save":
        explanations.append(
            "AI recommends cheaper nearby alternatives and micro-saving action."
        )

    elif final_action == "send_warning_nudge":
        explanations.append(
            "AI detected moderate financial risk and triggered a warning nudge."
        )

    elif final_action == "continue_tracking":
        explanations.append(
            "AI detected stable behaviour and continued passive financial monitoring."
        )

    safety = orchestrator_result.get("safetyCheck", {})

    if safety.get("requiresUserConsent"):
        explanations.append(
            "Financial actions require user approval before execution."
        )

    return {
        "aiExplanation": explanations
    }