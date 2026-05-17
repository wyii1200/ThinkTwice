from agents.safety_consent_agent import check_safety_and_consent

from config.constants import (
    FINAL_ACTIONS,
    RISK_LEVELS
)


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

    reasons = risk_result.get(
        "reasons",
        []
    )

    # =========================================================
    # DEFAULT STATE
    # =========================================================

    final_action = FINAL_ACTIONS[
        "CONTINUE_TRACKING"
    ]

    smart_radar = {
        "triggerSmartRadar": False,
        "radarCategory": None,
        "radarMessage": None,
        "openMode": "none",
        "recommendedRoute": None,
        "estimatedSavings": f"RM{savings_amount}",
        "aiReasoning": None
    }

    notification = {
        "sendPushNotification": False,
        "notificationTitle": None,
        "notificationBody": None,
        "notificationType": "none"
    }

    intervention_reason = (
        "ThinkTwice analysed this purchase and found no major budget concerns."
    )

    human_recommended_action = (
        "You can continue safely."
    )

    emotional_feedback = (
        "Nice choice 👏"
    )

    intervention_priority = "low"

    # =========================================================
    # HIGH RISK INTERVENTION
    # =========================================================

    if risk_level == RISK_LEVELS["HIGH"]:

        intervention_priority = "critical"

        notification["sendPushNotification"] = True

        should_trigger_radar = (
            late_night_spending
            or primary_category in [
                "food",
                "shopping",
                "entertainment"
            ]
            or risk_score >= 85
        )

        # -----------------------------------------------------
        # SMART RADAR FLOW
        # -----------------------------------------------------

        if should_trigger_radar:

            final_action = FINAL_ACTIONS.get(
                "SMART_RADAR_AND_SAVE_NUDGE",
                "SMART_RADAR_AND_SAVE_NUDGE"
            )

            smart_radar = {
                "triggerSmartRadar": True,

                "radarCategory": primary_category,

                "radarMessage": (
                    f"We found cheaper nearby {primary_category} options that could help you save RM{savings_amount}."
                ),

                "openMode": "auto_expand",

                "recommendedRoute": "/smart-radar",

                "estimatedSavings": f"RM{savings_amount}",

                "aiReasoning": (
                    f"ThinkTwice detected possible {primary_category} overspending behaviour and found a smarter nearby alternative."
                )
            }

            notification.update({

                "notificationTitle":
                "🔥 Impulse Spending Detected",

                "notificationBody": (
                    f"You could save RM{savings_amount} today with a smarter nearby option."
                ),

                "notificationType":
                "smart_radar"
            })

            intervention_reason = (
                "ThinkTwice predicted that this purchase may affect your weekly budget, so it recommended a cheaper nearby option before payment confirmation."
            )

            human_recommended_action = (
                f"Want to save RM{savings_amount} or find a cheaper option nearby?"
            )

            emotional_feedback = (
                "Your future self will thank you."
            )

        # -----------------------------------------------------
        # SAVE INSTEAD FLOW
        # -----------------------------------------------------

        else:

            final_action = FINAL_ACTIONS.get(
                "MICRO_SAVE_RECOMMENDATION",
                "MICRO_SAVE_RECOMMENDATION"
            )

            notification.update({

                "notificationTitle":
                "⚠️ Budget Warning",

                "notificationBody": (
                    f"Saving RM{savings_amount} now may help protect your weekly budget."
                ),

                "notificationType":
                "micro_save"
            })

            intervention_reason = (
                "ThinkTwice detected increased financial risk and recommended a small saving action before continuing."
            )

            human_recommended_action = (
                f"Save RM{savings_amount} instead."
            )

            emotional_feedback = (
                "Small savings become big habits."
            )

    # =========================================================
    # MEDIUM RISK INTERVENTION
    # =========================================================

    elif risk_level == RISK_LEVELS["MEDIUM"]:

        intervention_priority = "medium"

        final_action = FINAL_ACTIONS.get(
            "CONTINUE_WITH_WARNING",
            "CONTINUE_WITH_WARNING"
        )

        notification.update({

            "sendPushNotification": True,

            "notificationTitle":
            "⚠️ Budget Warning",

            "notificationBody": (
                f"This purchase may slightly affect your {primary_category} budget."
            ),

            "notificationType":
            "budget_warning"
        })

        intervention_reason = (
            "ThinkTwice noticed you are approaching your spending limit and generated a gentle warning before confirmation."
        )

        human_recommended_action = (
            "Review your spending before continuing."
        )

        emotional_feedback = (
            "You’re still in control of your spending."
        )

    # =========================================================
    # LOW RISK INTERVENTION
    # =========================================================

    else:

        intervention_priority = "safe"

        final_action = FINAL_ACTIONS.get(
            "SAFE_SPENDING_REWARD",
            "SAFE_SPENDING_REWARD"
        )

        notification.update({

            "sendPushNotification": False,

            "notificationTitle":
            "✅ Safe Spending",

            "notificationBody": (
                "This purchase looks manageable based on your current spending behaviour."
            ),

            "notificationType":
            "positive_reinforcement"
        })

        intervention_reason = (
            "ThinkTwice analysed this purchase and found that it fits your current spending behaviour."
        )

        human_recommended_action = (
            "You can continue safely."
        )

        emotional_feedback = (
            "Good choice today 👏"
        )

    # =========================================================
    # REWARD ENGINE
    # =========================================================

    reward_action = (
        "streak_bonus"
        if smart_decision_score >= 70
        else "no_reward"
    )

    # =========================================================
    # FINAL DECISION OBJECT
    # =========================================================

    final_decision = {

        "finalAction": final_action,

        "interventionReason": intervention_reason,

        "humanRecommendedAction":
        human_recommended_action,

        "emotionalFeedback":
        emotional_feedback,

        "interventionPriority":
        intervention_priority,

        "smartRadar":
        smart_radar,

        "notification":
        notification,

        "rewardAction":
        reward_action,

        "orchestratorMetadata": {

            "riskLevel":
            risk_level,

            "riskScore":
            risk_score,

            "primaryCategory":
            primary_category,

            "lateNightSpending":
            late_night_spending,

            "reasonCount":
            len(reasons),

            "aiDecisionEngine":
            "ThinkTwice Financial Orchestrator",

            "decisionMode":
            "pre_confirmation_intervention"
        }
    }

    # =========================================================
    # SAFETY CHECK
    # =========================================================

    final_decision = check_safety_and_consent(
        final_decision
    )

    return final_decision