RISK_LEVELS = {
    "LOW": "low",
    "MEDIUM": "medium",
    "HIGH": "high"
}

FINAL_ACTIONS = {
    "CONTINUE_TRACKING": "continue_tracking",
    "SEND_WARNING_NUDGE": "send_warning_nudge",
    "AUTO_SAVE": "auto_save",
    "SMART_RADAR_AND_AUTO_SAVE": "smart_radar_and_auto_save"
}

CATEGORIES = {
    "FOOD": "food",
    "TRANSPORT": "transport",
    "SHOPPING": "shopping",
    "ENTERTAINMENT": "entertainment",
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