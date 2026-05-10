def generate_nudge(
    risk_level,
    savings_amount=0,
    primary_category="spending"
):

    if risk_level == "high":

        return {
            "nudge": (
                f"Your {primary_category} spending is risky today. "
                f"Save RM{savings_amount} now to protect your savings streak?"
            ),

            "nudgeType": "critical_intervention",

            "emotionStyle": "urgent_supportive",

            "recommendedAction": "auto_save_and_smart_radar",

            "ctaButtonText": "Save Now",

            "secondaryActionText": "Find Cheaper Alternatives"
        }

    elif risk_level == "medium":

        return {
            "nudge": (
                f"You are close to your daily budget. "
                f"Try reducing your next {primary_category} spending."
            ),

            "nudgeType": "preventive_warning",

            "emotionStyle": "gentle_warning",

            "recommendedAction": "spending_awareness",

            "ctaButtonText": "Track Spending",

            "secondaryActionText": "Review Budget"
        }


    else:

        return {
            "nudge": (
                "Good job! Your spending is still under control today."
            ),

            "nudgeType": "positive_reinforcement",

            "emotionStyle": "encouraging",

            "recommendedAction": "continue_tracking",

            "ctaButtonText": "View Progress",

            "secondaryActionText": "Maintain Streak"
        }