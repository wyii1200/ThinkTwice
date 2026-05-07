def build_decision_layer(
    risk_result,
    orchestrator_result,
    learning_result
):

    # BEFORE spending problem
    if risk_result["riskLevel"] == "high":

        before_spending = (
            "AI detected risky spending trends before severe budget exhaustion."
        )

    elif risk_result["riskLevel"] == "medium":

        before_spending = (
            "AI detected moderate overspending behaviour early."
        )

    else:

        before_spending = (
            "AI detected healthy financial behaviour patterns."
        )

    # DURING intervention
    final_action = orchestrator_result["finalAction"]

    if final_action == "smart_radar_and_auto_save":

        during_spending = (
            "AI triggered Smart Savings Radar and micro-saving intervention."
        )

    elif final_action == "auto_save":

        during_spending = (
            "AI triggered proactive micro-saving protection."
        )

    elif final_action == "send_warning_nudge":

        during_spending = (
            "AI triggered behavioural warning nudges."
        )

    else:

        during_spending = (
            "AI continued passive financial monitoring."
        )

    # AFTER user behaviour
    if learning_result["acceptedNudge"]:

        after_action = (
            "System reinforced positive financial behaviour and updated resilience learning."
        )

    else:

        after_action = (
            "System detected resistance to intervention and increased future intervention intensity."
        )

    return {
        "decisionLayer": {
            "beforeSpending": before_spending,
            "duringSpending": during_spending,
            "afterAction": after_action
        }
    }