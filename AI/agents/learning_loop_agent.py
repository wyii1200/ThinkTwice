def learning_feedback(
    risk_level,
    final_action
):

    accepted_nudge = False

    if risk_level == "high":
        accepted_nudge = False

    elif risk_level == "medium":
        accepted_nudge = True

    else:
        accepted_nudge = True

    # Learning result
    if accepted_nudge:

        learning_status = (
            "User responds positively to interventions."
        )

        future_recommendation = (
            "Continue proactive nudges."
        )

    else:

        learning_status = (
            "User frequently ignores interventions."
        )

        future_recommendation = (
            "Increase intervention intensity."
        )

    return {
        "acceptedNudge": accepted_nudge,
        "learningStatus": learning_status,
        "futureRecommendation": future_recommendation,
        "trackedAction": final_action
    }