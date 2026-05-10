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

    final_action = FINAL_ACTIONS["CONTINUE_TRACKING"]

    smart_radar = {
        "triggerSmartRadar": False,
        "radarCategory": None,
        "radarMessage": None,
        "openMode": "none",
        "recommendedRoute": None
    }

    notification = {
        "sendPushNotification": False,
        "notificationTitle": None,
        "notificationBody": None,
        "notificationType": "none"
    }

    intervention_reason = (
        "User behaviour is currently manageable, so the system continues monitoring."
    )

    if risk_level == RISK_LEVELS["HIGH"]:

        notification["sendPushNotification"] = True

        should_trigger_radar = (
            late_night_spending
            or primary_category in ["food", "shopping"]
            or risk_result.get("riskScore", 0) >= 150
        )

        if should_trigger_radar:

            final_action = FINAL_ACTIONS["SMART_RADAR_AND_AUTO_SAVE"]

            smart_radar = {
                "triggerSmartRadar": True,
                "radarCategory": primary_category,
                "radarMessage": (
                    f"AI detected risky {primary_category} spending behaviour. "
                    "Find cheaper nearby alternatives and reduce overspending?"
                ),
                "openMode": "category_filter",
                "recommendedRoute": "/smart-radar"
            }

            notification.update({
                "notificationTitle": "Smart Savings Radar Activated",
                "notificationBody": (
                    f"ThinkTwice detected risky {primary_category} spending. "
                    f"Save RM{savings_amount} and explore cheaper nearby options."
                ),
                "notificationType": "smart_radar"
            })

            intervention_reason = (
                "High risk detected, so Smart Radar and auto-save suggestion are triggered."
            )

        else:

            final_action = FINAL_ACTIONS["AUTO_SAVE"]

            notification.update({
                "notificationTitle": "Auto-Save Recommendation",
                "notificationBody": (
                    f"AI recommends saving RM{savings_amount} to protect your savings goal."
                ),
                "notificationType": "auto_save"
            })

            intervention_reason = (
                "High risk detected, so the system recommends a user-approved micro-saving action."
            )

    elif risk_level == RISK_LEVELS["MEDIUM"]:

        final_action = FINAL_ACTIONS["SEND_WARNING_NUDGE"]

        notification.update({
            "sendPushNotification": True,
            "notificationTitle": "Budget Warning",
            "notificationBody": (
                f"You are close to exceeding today's budget for {primary_category}."
            ),
            "notificationType": "budget_warning"
        })

        intervention_reason = (
            "Medium risk detected, so the system sends a warning nudge before overspending happens."
        )

    else:

        final_action = FINAL_ACTIONS["CONTINUE_TRACKING"]

        notification.update({
            "sendPushNotification": False,
            "notificationTitle": "Healthy Spending",
            "notificationBody": (
                "Your spending behaviour looks manageable. Keep maintaining your savings habits."
            ),
            "notificationType": "positive_reinforcement"
        })

        intervention_reason = (
            "Low risk detected, so the system continues tracking and reinforces healthy behaviour."
        )

    reward_action = (
        "streak_bonus"
        if smart_decision_score >= 70
        else "no_reward"
    )

    final_decision = {
        "finalAction": final_action,
        "interventionReason": intervention_reason,
        "smartRadar": smart_radar,
        "notification": notification,
        "rewardAction": reward_action
    }

    final_decision = check_safety_and_consent(
        final_decision
    )

    return final_decision