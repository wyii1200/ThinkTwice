def generate_nudge(risk_level, savings_amount=0, primary_category="spending"):

    if risk_level == "high":
        return {
            "nudge": (
                f"Your {primary_category} spending is risky today. "
                f"Save RM{savings_amount} now to protect your savings streak?"
            )
        }

    elif risk_level == "medium":
        return {
            "nudge": (
                f"You are close to your daily budget. "
                f"Try reducing your next {primary_category} spending."
            )
        }

    else:
        return {
            "nudge": (
                "Good job! Your spending is still under control today."
            )
        }