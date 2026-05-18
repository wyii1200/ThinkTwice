def generate_nudge(
    risk_level,
    savings_amount=0,
    primary_category="spending"
):

    # =========================================================
    # HIGH RISK
    # =========================================================

    if risk_level == "high":

        return {

            "nudge": (
                f"You’ve been spending more on {primary_category} than usual tonight."
            ),

            "nudgeType":
            "critical_intervention",

            "emotionStyle":
            "urgent_supportive",

            "recommendedAction":
            "smart_radar_and_save_nudge",

            "headline":
            "🔥 Impulse Spending Detected",

            "subHeadline":
            (
                f"You could save RM{savings_amount} today with a smarter nearby option."
            ),

            "ctaButtonText":
            f"Save RM{savings_amount} Instead",

            "secondaryActionText":
            "Find Cheaper Nearby",

            "continueActionText":
            "Continue Anyway",

            "microcopy":
            (
                "Small savings today can become healthier financial habits tomorrow."
            ),

            "encouragementMessage":
            (
                "Your future self will thank you 👏"
            ),

            "aiAssistantTone":
            "protective",

            "loadingMessage":
            "Checking whether this purchase may affect your budget...",

            "nudgeConfidence":
            95,

            "aiVisibilityStatus":
            "AI detected possible impulse spending behaviour.",

            "uiPriority":
            "critical",
        }

    # =========================================================
    # MEDIUM RISK
    # =========================================================

    elif risk_level == "medium":

        return {

            "nudge": (
                f"Your {primary_category} spending is getting close to the limit. Want a cheaper option nearby?"
            ),

            "nudgeType":
            "preventive_warning",

            "emotionStyle":
            "gentle_warning",

            "recommendedAction":
            "continue_with_warning",

            "headline":
            "⚠️ Budget Warning",

            "subHeadline":
            (
                "ThinkTwice noticed your spending is getting close to today's limit."
            ),

            "ctaButtonText":
            f"Save RM{savings_amount} Instead",

            "secondaryActionText":
            "Find Cheaper Nearby",

            "continueActionText":
            "Continue Anyway",

            "microcopy":
            (
                "A small adjustment now can prevent larger overspending later."
            ),

            "encouragementMessage":
            (
                "You’re still in control of your spending."
            ),

            "aiAssistantTone":
            "supportive",

            "loadingMessage":
            "Reviewing your spending pattern...",

            "nudgeConfidence":
            84,

            "aiVisibilityStatus":
            "AI is monitoring your spending pattern.",

            "uiPriority":
            "warning",
        }

    # =========================================================
    # LOW RISK
    # =========================================================

    else:

        return {

            "nudge": (
                "This purchase looks manageable based on your current spending behaviour."
            ),

            "nudgeType":
            "positive_reinforcement",

            "emotionStyle":
            "encouraging",

            "recommendedAction":
            "safe_spending_reward",

            "headline":
            "✅ Safe Spending",

            "subHeadline":
            (
                "You’re staying within your spending habits today."
            ),

            "ctaButtonText":
            "Continue",

            "secondaryActionText":
            "View Progress",

            "continueActionText":
            "Continue",

            "microcopy":
            (
                "Good choices today help build stronger money habits."
            ),

            "encouragementMessage":
            (
                "Nice save 👏"
            ),

            "aiAssistantTone":
            "positive",

            "loadingMessage":
            "Checking purchase impact...",

            "nudgeConfidence":
            72,

            "aiVisibilityStatus":
            "AI confirmed this purchase looks manageable.",

            "uiPriority":
            "safe",
        }