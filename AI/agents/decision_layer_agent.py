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

    # =========================================================
    # BEFORE PAYMENT CONFIRMATION
    # =========================================================

    if risk_level == "high":

        before_spending = (
            "AI detected possible impulse spending before payment confirmation."
        )

        before_stage_status = "risk_detected"

        before_user_message = (
            "This purchase may affect your weekly budget."
        )

    elif risk_level == "medium":

        before_spending = (
            "AI detected early budget pressure before payment confirmation."
        )

        before_stage_status = "early_warning"

        before_user_message = (
            "You are getting close to your spending limit."
        )

    else:

        before_spending = (
            "AI checked this purchase before payment confirmation and found it manageable."
        )

        before_stage_status = "stable"

        before_user_message = (
            "This purchase looks safe."
        )

    # =========================================================
    # DURING DECISION MOMENT
    # =========================================================

    if final_action in [
        "smart_radar_and_auto_save",
        "smart_radar_and_save_nudge",
        "SMART_RADAR_AND_SAVE_NUDGE"
    ]:

        during_spending = (
            "AI selected Smart Radar to help the user compare cheaper nearby alternatives."
        )

        during_stage_status = "active_intervention"

        selected_intervention = "Smart Radar + Save Nudge"

        during_user_message = (
            "Want a cheaper option nearby?"
        )

    elif final_action in [
        "auto_save",
        "micro_save_recommendation",
        "save_rm8_instead",
        "MICRO_SAVE_RECOMMENDATION"
    ]:

        during_spending = (
            "AI selected a user-approved micro-saving recommendation to reduce budget impact."
        )

        during_stage_status = "saving_intervention"

        selected_intervention = "Micro Save"

        during_user_message = (
            "Save a small amount instead?"
        )

    elif final_action in [
        "send_warning_nudge",
        "continue_with_warning",
        "CONTINUE_WITH_WARNING"
    ]:

        during_spending = (
            "AI selected a gentle budget warning because the risk is still manageable."
        )

        during_stage_status = "warning_nudge"

        selected_intervention = "Budget Warning"

        during_user_message = (
            "Review before continuing."
        )

    elif final_action in [
        "safe_spending_reward",
        "SAFE_SPENDING_REWARD"
    ]:

        during_spending = (
            "AI selected positive reinforcement because this purchase looks safe."
        )

        during_stage_status = "positive_reinforcement"

        selected_intervention = "Safe Spending Reward"

        during_user_message = (
            "Good choice today 👏"
        )

    else:

        during_spending = (
            "AI continued quiet financial monitoring."
        )

        during_stage_status = "monitoring"

        selected_intervention = "Monitoring"

        during_user_message = (
            "ThinkTwice will keep monitoring quietly."
        )

    # =========================================================
    # AFTER USER ACTION
    # =========================================================

    if accepted_nudge:

        after_action = (
            "The system reinforced the positive financial decision and improved future nudges."
        )

        after_stage_status = "positive_reinforcement"

        after_user_message = (
            "Nice save 👏 Your Money Habit Score improved."
        )

    else:

        after_action = (
            "The system recorded the response and will adapt future recommendations."
        )

        after_stage_status = "adaptive_learning"

        after_user_message = (
            "ThinkTwice will learn from this decision."
        )

    # =========================================================
    # RETURN
    # =========================================================

    return {
        "decisionLayer": {

            "beforeSpending":
            before_spending,

            "beforeStageStatus":
            before_stage_status,

            "beforeUserMessage":
            before_user_message,

            "duringSpending":
            during_spending,

            "duringStageStatus":
            during_stage_status,

            "duringUserMessage":
            during_user_message,

            "selectedIntervention":
            selected_intervention,

            "afterAction":
            after_action,

            "afterStageStatus":
            after_stage_status,

            "afterUserMessage":
            after_user_message,

            "nextBestIntervention":
            next_best_intervention,

            "visibleDemoFlow": [
                {
                    "stage": "Before",
                    "title": "Payment Intent Detected",
                    "description": before_spending,
                    "status": before_stage_status
                },
                {
                    "stage": "During",
                    "title": selected_intervention,
                    "description": during_spending,
                    "status": during_stage_status
                },
                {
                    "stage": "After",
                    "title": "Learning Loop Updated",
                    "description": after_action,
                    "status": after_stage_status
                }
            ]
        }
    }