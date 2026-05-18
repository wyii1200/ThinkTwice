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
    - continued_anyway
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
        "dismissed_notification",
        "continued_anyway"
    ]

    if action_type in positive_actions:
        accepted_nudge = True

    elif action_type in negative_actions:
        accepted_nudge = False

    else:
        accepted_nudge = risk_level != "high"

    # =========================================================
    # LEARNING RESPONSE
    # =========================================================

    if action_type == "opened_smart_radar":

        learning_status = (
            "User responded well to Smart Radar recommendations."
        )

        future_recommendation = (
            "Prioritize cheaper nearby alternatives for similar future spending moments."
        )

        next_best_intervention = "smart_radar_and_save_nudge"

        learning_message = (
            "ThinkTwice learned that Smart Radar is helpful for this user."
        )

    elif action_type == "saved_money":

        learning_status = (
            "User responded positively to micro-saving suggestions."
        )

        future_recommendation = (
            "Continue recommending small user-approved saving actions."
        )

        next_best_intervention = "micro_save_recommendation"

        learning_message = (
            "ThinkTwice learned that small save suggestions work well for this user."
        )

    elif action_type == "accepted":

        learning_status = (
            "User responded positively to behavioural nudges."
        )

        future_recommendation = (
            "Continue proactive nudges with clear action recommendations."
        )

        next_best_intervention = "personalised_nudge"

        learning_message = (
            "ThinkTwice learned that direct nudges are useful for this user."
        )

    elif action_type == "continued_anyway":

        learning_status = (
            "User continued despite the intervention."
        )

        future_recommendation = (
            "Use softer explanations next time and make the savings benefit clearer."
        )

        next_best_intervention = "soft_explainable_nudge"

        learning_message = (
            "ThinkTwice learned to make future nudges clearer and less interruptive."
        )

    elif action_type in negative_actions:

        learning_status = (
            "User ignored or dismissed recent interventions."
        )

        future_recommendation = (
            "Reduce notification pressure but improve explanation clarity."
        )

        next_best_intervention = "soft_explainable_nudge"

        learning_message = (
            "ThinkTwice learned to use softer future interventions."
        )

    elif risk_level == "high":

        learning_status = (
            "High financial risk detected without confirmed positive response."
        )

        future_recommendation = (
            "Prioritize Smart Radar and user-approved saving suggestions in future risky situations."
        )

        next_best_intervention = "smart_radar_and_save_nudge"

        learning_message = (
            "ThinkTwice will prioritize smarter alternatives when similar risk appears again."
        )

    else:

        learning_status = (
            "User behaviour remains manageable."
        )

        future_recommendation = (
            "Maintain lightweight positive reinforcement."
        )

        next_best_intervention = "positive_reinforcement"

        learning_message = (
            "ThinkTwice will continue encouraging healthy spending habits."
        )

    # =========================================================
    # LEARNING IMPACT
    # =========================================================

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

    # =========================================================
    # DASHBOARD-FRIENDLY OUTPUT
    # =========================================================

    if accepted_nudge:
        dashboard_learning_text = (
            "Learning loop updated: this user responds well to helpful spending nudges."
        )

    else:
        dashboard_learning_text = (
            "Learning loop updated: future nudges will be softer and clearer."
        )

    learning_confidence = (
        92 if accepted_nudge
        else 70
    )

    frontend_learning_status = (
        "positive_adaptation"
        if accepted_nudge
        else "soft_recalibration"
    )

    return {
        "acceptedNudge": accepted_nudge,
        "learningStatus": learning_status,
        "futureRecommendation": future_recommendation,
        "nextBestIntervention": next_best_intervention,
        "learningImpactScore": learning_impact_score,
        "reinforcementStrength": reinforcement_strength,
        "learningMessage": learning_message,
        "dashboardLearningText": dashboard_learning_text,
        "trackedAction": final_action,
        "userActionType": action_type,
        "feedbackSource": feedback_source,
        "learningLoopVisible": True,
        "learningConfidence": learning_confidence,
        "frontendLearningStatus": frontend_learning_status
    }