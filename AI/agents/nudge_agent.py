def generate_nudge(risk_level):

    if risk_level == "high":
        return {
            "suggestedAction": "auto_save",
            "nudge": (
                "You have exceeded your daily budget. "
                "Save RM8 now to protect your savings streak?"
            )
        }

    elif risk_level == "medium":
        return {
            "suggestedAction": "send_nudge",
            "nudge": (
                "You are close to your daily budget. "
                "Try reducing your next spending."
            )
        }

    else:
        return {
            "suggestedAction": "continue_tracking",
            "nudge": (
                "Good job! Your spending is still under control today."
            )
        }