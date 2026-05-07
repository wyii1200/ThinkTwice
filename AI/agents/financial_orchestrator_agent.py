from agents.safety_consent_agent import check_safety_and_consent
from config.constants import FINAL_ACTIONS, RISK_LEVELS


def orchestrate_intervention(
    risk_result,
    score_result,
    behaviour_result,
    savings_amount
):
    risk_level = risk_result["riskLevel"]
    primary_category = behaviour_result.get("primaryCategory", "spending")
    late_night_spending = behaviour_result.get("lateNightSpending", False)

    final_action = FINAL_ACTIONS["CONTINUE_TRACKING"]

    smart_radar = {
        "triggerSmartRadar": False,
        "radarCategory": None,
        "radarMessage": None,
        "openMode": "none"
    }

    notification = {
        "sendPushNotification": False,
        "notificationTitle": None,
        "notificationBody": None,
        "notificationType": "none"
    }

    # High risk intervention
    if risk_level == RISK_LEVELS["HIGH"]:

        notification["sendPushNotification"] = True

        if late_night_spending:
            final_action = FINAL_ACTIONS["SMART_RADAR_AND_AUTO_SAVE"]

            smart_radar = {
                "triggerSmartRadar": True,
                "radarCategory": primary_category,
                "radarMessage": (
                    f"You usually overspend on {primary_category} during risky hours. "
                    "Find cheaper nearby alternatives?"
                ),
                "openMode": "category_filter"
            }

            notification.update({
                "notificationTitle": "Smart Savings Alert",
                "notificationBody": (
                    f"AI detected risky {primary_category} spending. "
                    f"Save RM{savings_amount} or find cheaper options nearby."
                ),
                "notificationType": "smart_radar"
            })

        else:
            final_action = FINAL_ACTIONS["AUTO_SAVE"]

            notification.update({
                "notificationTitle": "Auto-Save Recommendation",
                "notificationBody": (
                    f"AI recommends saving RM{savings_amount} to protect your savings goal."
                ),
                "notificationType": "auto_save"
            })

    # Medium risk intervention
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

    # Reward logic
    reward_action = (
        "streak_bonus"
        if score_result["smartDecisionScore"] >= 70
        else "no_reward"
    )

    final_decision = {
        "finalAction": final_action,
        "smartRadar": smart_radar,
        "notification": notification,
        "rewardAction": reward_action
    }

    final_decision = check_safety_and_consent(final_decision)

    return final_decision