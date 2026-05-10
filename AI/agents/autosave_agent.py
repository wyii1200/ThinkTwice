from config.constants import DEFAULT_SAVINGS_AMOUNT


def suggest_savings(risk_level):

    suggested_amount = DEFAULT_SAVINGS_AMOUNT.get(
        risk_level,
        0
    )

    if risk_level == "high":

        savings_reason = (
            "High financial risk detected. Small immediate savings may help reduce overspending impact."
        )

        savings_priority = "urgent"

        savings_strategy = (
            "micro_save_and_reduce_spending"
        )

    elif risk_level == "medium":

        savings_reason = (
            "Preventive savings action recommended before spending risk increases."
        )

        savings_priority = "important"

        savings_strategy = (
            "preventive_micro_save"
        )

    else:

        savings_reason = (
            "Maintain healthy savings consistency."
        )

        savings_priority = "normal"

        savings_strategy = (
            "maintain_savings_habit"
        )

    return {
        "suggestedAmount": suggested_amount,

        "savingsReason": savings_reason,

        "savingsPriority": savings_priority,

        "savingsStrategy": savings_strategy
    }