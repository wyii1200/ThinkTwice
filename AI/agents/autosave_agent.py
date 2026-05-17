from config.constants import DEFAULT_SAVINGS_AMOUNT


def suggest_savings(risk_level):

    suggested_amount = DEFAULT_SAVINGS_AMOUNT.get(
        risk_level,
        0
    )

    if risk_level == "high":

        savings_reason = (
            f"Saving RM{suggested_amount} now could help reduce overspending tonight."
        )

        savings_priority = "urgent"

        savings_strategy = (
            "micro_save_and_reduce_spending"
        )

        encouragement_message = (
            "Small savings today can become healthier financial habits later."
        )

    elif risk_level == "medium":

        savings_reason = (
            f"A small RM{suggested_amount} save now may help protect your weekly budget."
        )

        savings_priority = "important"

        savings_strategy = (
            "preventive_micro_save"
        )

        encouragement_message = (
            "A small adjustment now can prevent larger spending later."
        )

    else:

        savings_reason = (
            "Your spending looks healthy today."
        )

        savings_priority = "normal"

        savings_strategy = (
            "maintain_savings_habit"
        )

        encouragement_message = (
            "Nice job staying within your budget today."
        )

    return {
        "suggestedAmount": suggested_amount,

        "savingsReason": savings_reason,

        "savingsPriority": savings_priority,

        "savingsStrategy": savings_strategy,

        "encouragementMessage": encouragement_message
    }