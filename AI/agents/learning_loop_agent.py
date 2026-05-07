def learning_feedback(
    risk_level,
    final_action,
    user_action=None
):
    """
    user_action.actionType can be:
    - accepted
    - ignored
    - opened_smart_radar
    - saved_money
    - dismissed_notification
    """

    action_type = None
    feedback_source = "demo_fallback"

    if user_action:
        action_type = user_action.actionType
        feedback_source = "frontend_user_action"

    positive_actions = [
        "accepted",
        "opened_smart_radar",
        "saved_money"
    ]

    negative_actions = [
        "ignored",
        "dismissed_notification"
    ]

    if action_type in positive_actions:
        accepted_nudge = True

    elif action_type in negative_actions:
        accepted_nudge = False

    else:
        accepted_nudge = risk_level != "high"

    if accepted_nudge:
        learning_status = "User responds positively to interventions."
        future_recommendation = "Continue proactive nudges."

    else:
        learning_status = "User frequently ignores interventions."
        future_recommendation = "Increase intervention intensity."

    return {
        "acceptedNudge": accepted_nudge,
        "learningStatus": learning_status,
        "futureRecommendation": future_recommendation,
        "trackedAction": final_action,
        "userActionType": action_type,
        "feedbackSource": feedback_source
    }   