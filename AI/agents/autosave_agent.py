from config.constants import DEFAULT_SAVINGS_AMOUNT


def suggest_savings(risk_level):

    suggested_amount = DEFAULT_SAVINGS_AMOUNT.get(
        risk_level,
        0
    )

    # =========================================================
    # HIGH RISK
    # =========================================================

    if risk_level == "high":

        savings_reason = (
            f"Saving RM{suggested_amount} now may help prevent overspending tonight."
        )

        savings_priority = "urgent"

        savings_strategy = (
            "micro_save_before_confirmation"
        )

        encouragement_message = (
            "Your future self will thank you for this small save 👏"
        )

        savings_impact = (
            "This small save could help protect your weekly food budget."
        )

        emotional_tone = "protective"

    # =========================================================
    # MEDIUM RISK
    # =========================================================

    elif risk_level == "medium":

        savings_reason = (
            f"A small RM{suggested_amount} save now may help keep your spending under control."
        )

        savings_priority = "important"

        savings_strategy = (
            "preventive_micro_save"
        )

        encouragement_message = (
            "Small savings become healthy financial habits."
        )

        savings_impact = (
            "A small adjustment now can prevent larger overspending later."
        )

        emotional_tone = "supportive"

    # =========================================================
    # LOW RISK
    # =========================================================

    else:

        savings_reason = (
            "Your spending behaviour currently looks healthy."
        )

        savings_priority = "normal"

        savings_strategy = (
            "maintain_healthy_habits"
        )

        encouragement_message = (
            "Nice job staying within your budget today 👏"
        )

        savings_impact = (
            "Your current spending pattern remains manageable."
        )

        emotional_tone = "positive"

    # =========================================================
    # RETURN
    # =========================================================

    return {

        "suggestedAmount":
        suggested_amount,

        "savingsReason":
        savings_reason,

        "savingsPriority":
        savings_priority,

        "savingsStrategy":
        savings_strategy,

        "encouragementMessage":
        encouragement_message,

        "savingsImpact":
        savings_impact,

        "emotionalTone":
        emotional_tone
    }