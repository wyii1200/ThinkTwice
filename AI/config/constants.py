RISK_LEVELS = {
    "LOW": "low",
    "MEDIUM": "medium",
    "HIGH": "high"
}


FINAL_ACTIONS = {
    "CONTINUE_TRACKING": "continue_tracking",

    "SEND_WARNING_NUDGE": "send_warning_nudge",

    "AUTO_SAVE": "auto_save",

    "SMART_RADAR_AND_AUTO_SAVE": "smart_radar_and_auto_save",

    # Final demo flow actions
    "SMART_RADAR_AND_SAVE_NUDGE": "smart_radar_and_save_nudge",

    "SAVE_RM8_INSTEAD": "save_rm8_instead",

    "CONTINUE_WITH_WARNING": "continue_with_warning",

    "SAFE_SPENDING_REWARD": "safe_spending_reward",

    "MICRO_SAVE_RECOMMENDATION": "micro_save_recommendation"
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


HUMAN_RISK_LABELS = {
    "high": "🔥 Impulse Purchase Detected",
    "medium": "⚠️ Budget Warning",
    "low": "✅ Safe Spending"
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
    "Payment intent detected",

    "RISK_ANALYSED":
    "Spending behaviour analysed",

    "VELOCITY_ANALYSED":
    "Overspending risk predicted",

    "INTERVENTION_SELECTED":
    "Smarter financial intervention selected",

    "NUDGE_GENERATED":
    "Personalised recommendation generated"
}


DEMO_INTERVENTION_OPTIONS = [
    "Continue Anyway",
    "Save RM8 Instead",
    "Find Cheaper Nearby"
]