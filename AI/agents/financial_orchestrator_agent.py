from agents.safety_consent_agent import check_safety_and_consent
from config.constants import FINAL_ACTIONS, RISK_LEVELS


def orchestrate_intervention(
    risk_result,
    score_result,
    behaviour_result,
    savings_amount
):
    risk_level = risk_result["riskLevel"]

    primary_category = behaviour_result.get(
        "primaryCategory",
        "spending"
    )

    late_night_spending = behaviour_result.get(
        "lateNightSpending",
        False
    )

    smart_decision_score = score_result.get(
        "smartDecisionScore",
        50
    )

    risk_score = risk_result.get(
        "riskScore",
        0
    )

    final_action = FINAL_ACTIONS["CONTINUE_TRACKING"]

    smart_radar = {
        "triggerSmartRadar": False,
        "radarCategory": None,
        "radarMessage": None,
        "openMode": "none",
        "recommendedRoute": None,
        "estimatedSavings": f"RM{savings_amount}"
    }

    notification = {
        "sendPushNotification": False,
        "notificationTitle": None,
        "notificationBody": None,
        "notificationType": "none"
    }

    intervention_reason = (
        "Your spending looks manageable, so ThinkTwice will continue monitoring quietly."
    )

    human_recommended_action = (
        "Keep tracking your spending."
    )

    if risk_level == RISK_LEVELS["HIGH"]:

        notification["sendPushNotification"] = True

        should_trigger_radar = (
            late_night_spending
            or primary_category in ["food", "shopping", "entertainment"]
            or risk_score >= 120
        )

        if should_trigger_radar:

            final_action = FINAL_ACTIONS.get(
                "SMART_RADAR_AND_SAVE_NUDGE",
                FINAL_ACTIONS["SMART_RADAR_AND_AUTO_SAVE"]
            )

            smart_radar = {
                "triggerSmartRadar": True,
                "radarCategory": primary_category,
                "radarMessage": (
                    f"Want a cheaper {primary_category} option nearby? "
                    f"You could save RM{savings_amount} today."
                ),
                "openMode": "category_filter",
                "recommendedRoute": "/smart-radar",
                "estimatedSavings": f"RM{savings_amount}"
            }

            notification.update({
                "notificationTitle": "Want a cheaper option nearby?",
                "notificationBody": (
                    f"ThinkTwice noticed possible {primary_category} overspending. "
                    f"You could save RM{savings_amount} today."
                ),
                "notificationType": "smart_radar"
            })

            intervention_reason = (
                "ThinkTwice found that this purchase may affect your budget, so it opened a cheaper nearby option."
            )

            human_recommended_action = (
                f"Save RM{savings_amount} or find a cheaper option nearby."
            )

        else:

            final_action = FINAL_ACTIONS.get(
                "MICRO_SAVE_RECOMMENDATION",
                FINAL_ACTIONS["AUTO_SAVE"]
            )

            notification.update({
                "notificationTitle": "Small save suggested",
                "notificationBody": (
                    f"Saving RM{savings_amount} now could help protect your weekly goal."
                ),
                "notificationType": "auto_save"
            })

            intervention_reason = (
                "ThinkTwice detected budget risk, so it suggests a small saving action before spending."
            )

            human_recommended_action = (
                f"Save RM{savings_amount} instead."
            )

    elif risk_level == RISK_LEVELS["MEDIUM"]:

        final_action = FINAL_ACTIONS.get(
            "CONTINUE_WITH_WARNING",
            FINAL_ACTIONS["SEND_WARNING_NUDGE"]
        )

        notification.update({
            "sendPushNotification": True,
            "notificationTitle": "Budget warning",
            "notificationBody": (
                f"You are close to your {primary_category} budget today."
            ),
            "notificationType": "budget_warning"
        })

        intervention_reason = (
            "ThinkTwice noticed that you are close to your budget, so it gives a gentle warning before confirmation."
        )

        human_recommended_action = (
            "Review your budget before continuing."
        )

    else:

        final_action = FINAL_ACTIONS.get(
            "SAFE_SPENDING_REWARD",
            FINAL_ACTIONS["CONTINUE_TRACKING"]
        )

        notification.update({
            "sendPushNotification": False,
            "notificationTitle": "Safe spending",
            "notificationBody": (
                "This purchase looks safe based on your current spending pattern."
            ),
            "notificationType": "positive_reinforcement"
        })

        intervention_reason = (
            "This purchase looks manageable, so ThinkTwice gives positive feedback."
        )

        human_recommended_action = (
            "You can continue safely."
        )

    reward_action = (
        "streak_bonus"
        if smart_decision_score >= 70
        else "no_reward"
    )

    final_decision = {
        "finalAction": final_action,
        "interventionReason": intervention_reason,
        "humanRecommendedAction": human_recommended_action,
        "smartRadar": smart_radar,
        "notification": notification,
        "rewardAction": reward_action
    }

    final_decision = check_safety_and_consent(
        final_decision
    )

    return final_decision