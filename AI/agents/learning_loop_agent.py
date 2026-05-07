def learning_feedback(
    risk_level,
    final_action,
    user_action=None
):
    """
    user_action can be:
    - accepted
    - ignored
    - opened_smart_radar
    - saved_money
    - None
    """

    if user_action in ["accepted", "opened_smart_radar", "saved_money"]:
        accepted_nudge = True

    elif user_action == "ignored":
        accepted_nudge = False

    else:
        # Temporary fallback for demo if frontend has not sent real user action yet
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
        "feedbackSource": "frontend_user_action" if user_action else "demo_fallback"
    }