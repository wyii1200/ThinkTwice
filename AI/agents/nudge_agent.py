def generate_nudge(
    risk_level,
    savings_amount=0,
    primary_category="spending"
):

    if risk_level == "high":

        return {
            "nudge": (
                f"You may be overspending on {primary_category} tonight. "
                f"Want to save RM{savings_amount} or find a cheaper option nearby?"
            ),

            "nudgeType": "critical_intervention",

            "emotionStyle": "urgent_supportive",

            "recommendedAction": "smart_radar_and_save_nudge",

            "ctaButtonText": f"Save RM{savings_amount} Instead",

            "secondaryActionText": "Find Cheaper Nearby",

            "microcopy": (
                "Small savings today can become healthier financial habits tomorrow."
            )
        }

    elif risk_level == "medium":

        return {
            "nudge": (
                f"You are getting close to your {primary_category} budget today."
            ),

            "nudgeType": "preventive_warning",

            "emotionStyle": "gentle_warning",

            "recommendedAction": "continue_with_warning",

            "ctaButtonText": "Review Budget",

            "secondaryActionText": "Continue Anyway",

            "microcopy": (
                "A small adjustment now can prevent larger spending later."
            )
        }

    else:

        return {
            "nudge": (
                "Nice job — this purchase still looks manageable."
            ),

            "nudgeType": "positive_reinforcement",

            "emotionStyle": "encouraging",

            "recommendedAction": "safe_spending_reward",

            "ctaButtonText": "Continue",

            "secondaryActionText": "View Progress",

            "microcopy": (
                "Good choices today help build stronger money habits."
            )
        }