RISK_LEVELS = {
    "LOW": "low",
    "MEDIUM": "medium",
    "HIGH": "high"
}

FINAL_ACTIONS = {
    "CONTINUE_TRACKING":
    "continue_tracking",

    "SEND_WARNING_NUDGE":
    "send_warning_nudge",

    "AUTO_SAVE":
    "auto_save",

    "SMART_RADAR_AND_AUTO_SAVE":
    "smart_radar_and_auto_save"
}

CATEGORIES = {
    "FOOD": "food",

    "TRANSPORT": "transport",

    "SHOPPING": "shopping",

    "ENTERTAINMENT": "entertainment",

    "HEALTHCARE": "healthcare",

    "EDUCATION": "education",

    "BILLS": "bills",

    "OTHER": "other"
}

FINANCIAL_ACTIONS_REQUIRING_CONSENT = [
    "auto_save",
    "round_up_save",
    "transfer_to_savings",
    "salary_auto_allocation"
]


DEFAULT_SAVINGS_AMOUNT = {
    "high": 8,
    "medium": 5,
    "low": 0
}


RISK_COLORS = {
    "high": "red",
    "medium": "orange",
    "low": "green"
}


BEHAVIOUR_GRADES = {
    "excellent": "excellent",
    "good": "good",
    "moderate": "moderate",
    "high_risk": "high_risk"
}


RECOMMENDATION_PRIORITIES = {
    "URGENT": "urgent",
    "IMPORTANT": "important",
    "NORMAL": "normal",
    "LOW": "low"
}


NOTIFICATION_TYPES = {
    "SMART_RADAR": "smart_radar",
    "AUTO_SAVE": "auto_save",
    "BUDGET_WARNING": "budget_warning",
    "POSITIVE_REINFORCEMENT": "positive_reinforcement"
}


AI_TIMELINE_EVENTS = {
    "TRANSACTION_RECEIVED":
    "Transaction received",

    "RISK_ANALYSED":
    "Financial risk analysed",

    "VELOCITY_ANALYSED":
    "Spending velocity evaluated",

    "INTERVENTION_SELECTED":
    "Best intervention selected",

    "NUDGE_GENERATED":
    "Personalised intervention generated"
}