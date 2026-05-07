from config.constants import DEFAULT_SAVINGS_AMOUNT


def suggest_savings(risk_level):
    return DEFAULT_SAVINGS_AMOUNT.get(risk_level, 0)