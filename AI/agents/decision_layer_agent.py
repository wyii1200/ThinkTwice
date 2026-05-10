def build_decision_layer(
    risk_result,
    orchestrator_result,
    learning_result
):

    risk_level = risk_result.get(
        "riskLevel",
        "low"
    )

    final_action = orchestrator_result.get(
        "finalAction",
        "continue_tracking"
    )

    accepted_nudge = learning_result.get(
        "acceptedNudge",
        False
    )

    next_best_intervention = learning_result.get(
        "nextBestIntervention",
        "positive_reinforcement"
    )

    if risk_level == "high":

        before_spending = (
            "AI detected high-risk financial behaviour before severe budget exhaustion."
        )

        before_stage_status = "risk_detected"

    elif risk_level == "medium":

        before_spending = (
            "AI detected moderate overspending behaviour early."
        )

        before_stage_status = "early_warning"

    else:

        before_spending = (
            "AI detected healthy financial behaviour patterns."
        )

        before_stage_status = "stable"

    if final_action == "smart_radar_and_auto_save":

        during_spending = (
            "AI triggered Smart Savings Radar and user-approved micro-saving recommendation."
        )

        during_stage_status = "active_intervention"

    elif final_action == "auto_save":

        during_spending = (
            "AI triggered proactive user-approved micro-saving protection."
        )

        during_stage_status = "saving_intervention"

    elif final_action == "send_warning_nudge":

        during_spending = (
            "AI triggered behavioural warning nudges to prevent future overspending."
        )

        during_stage_status = "warning_nudge"

    else:

        during_spending = (
            "AI continued passive financial monitoring."
        )

        during_stage_status = "monitoring"

    if accepted_nudge:

        after_action = (
            "System reinforced positive financial behaviour and updated future recommendation strategy."
        )

        after_stage_status = "positive_reinforcement"

    else:

        after_action = (
            "System detected weak intervention response and adjusted future recommendation strategy."
        )

        after_stage_status = "adaptive_escalation"

    return {
        "decisionLayer": {
            "beforeSpending": before_spending,
            "beforeStageStatus": before_stage_status,

            "duringSpending": during_spending,
            "duringStageStatus": during_stage_status,

            "afterAction": after_action,
            "afterStageStatus": after_stage_status,

            "nextBestIntervention":
            next_best_intervention
        }
    }