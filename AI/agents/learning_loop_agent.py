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


    if action_type == "opened_smart_radar":

        learning_status = (
            "User responds well to Smart Radar recommendations."
        )

        future_recommendation = (
            "Prioritize Smart Radar suggestions for future risky spending situations."
        )

        next_best_intervention = "smart_radar"

    elif action_type == "saved_money":

        learning_status = (
            "User responds positively to micro-saving actions."
        )

        future_recommendation = (
            "Continue recommending small user-approved savings actions."
        )

        next_best_intervention = "auto_save"

    elif action_type == "accepted":

        learning_status = (
            "User responds positively to behavioural nudges."
        )

        future_recommendation = (
            "Continue proactive nudges with clear action recommendations."
        )

        next_best_intervention = "personalised_nudge"

    elif action_type in negative_actions:

        learning_status = (
            "User ignored or dismissed recent interventions."
        )

        future_recommendation = (
            "Reduce notification frequency but improve explanation clarity."
        )

        next_best_intervention = "soft_explainable_nudge"

    elif risk_level == "high":

        learning_status = (
            "High financial risk detected without strong positive intervention response."
        )

        future_recommendation = (
            "Escalate intervention using Smart Radar and auto-save recommendations."
        )

        next_best_intervention = "smart_radar_and_auto_save"

    else:

        learning_status = (
            "User behaviour remains manageable."
        )

        future_recommendation = (
            "Maintain lightweight positive reinforcement."
        )

        next_best_intervention = "positive_reinforcement"


    if accepted_nudge:
        learning_impact_score = 10

    else:
        learning_impact_score = -8


    if learning_impact_score >= 10:
        reinforcement_strength = "strong"

    elif learning_impact_score > 0:
        reinforcement_strength = "moderate"

    else:
        reinforcement_strength = "weak"


    return {
        "acceptedNudge": accepted_nudge,

        "learningStatus": learning_status,

        "futureRecommendation":
        future_recommendation,

        "nextBestIntervention":
        next_best_intervention,

        "learningImpactScore":
        learning_impact_score,

        "reinforcementStrength":
        reinforcement_strength,

        "trackedAction":
        final_action,

        "userActionType":
        action_type,

        "feedbackSource":
        feedback_source
    }