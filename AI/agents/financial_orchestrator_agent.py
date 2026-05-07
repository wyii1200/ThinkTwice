from agents.safety_consent_agent import check_safety_and_consent


def orchestrate_intervention(
    risk_result,
    score_result,
    behaviour_result
):

    intervention = "none"

    # Smart Radar defaults
    trigger_smart_radar = False
    radar_category = None
    radar_message = None

    # Notification defaults
    send_push_notification = False
    notification_title = None
    notification_body = None

    # High risk intervention
    if risk_result["riskLevel"] == "high":

        send_push_notification = True

        if behaviour_result["lateNightSpending"]:

            intervention = "smart_radar_and_auto_save"

            trigger_smart_radar = True

            radar_category = "food"

            radar_message = (
                "You usually overspend on food after 10PM. "
                "Find cheaper nearby alternatives?"
            )

            notification_title = "Smart Savings Alert"

            notification_body = (
                "AI detected risky late-night food spending."
            )

        else:

            intervention = "auto_save"

            notification_title = "Auto-Save Recommendation"

            notification_body = (
                "AI recommends securing part of your remaining budget."
            )

    # Medium risk intervention
    elif risk_result["riskLevel"] == "medium":

        intervention = "send_warning_nudge"

        send_push_notification = True

        notification_title = "Budget Warning"

        notification_body = (
            "You are close to exceeding today's budget."
        )

    # Low risk
    else:

        intervention = "continue_tracking"

    # Reward logic
    if score_result["smartDecisionScore"] >= 70:

        reward = "streak_bonus"

    else:

        reward = "no_reward"

    # Final orchestrator response
    final_decision = {
        "finalAction": intervention,

        "smartRadar": {
            "triggerSmartRadar": trigger_smart_radar,
            "radarCategory": radar_category,
            "radarMessage": radar_message
        },

        "notification": {
            "sendPushNotification": send_push_notification,
            "notificationTitle": notification_title,
            "notificationBody": notification_body
        },

        "rewardAction": reward
    }

    # Safety layer
    final_decision = check_safety_and_consent(final_decision)

    return final_decision