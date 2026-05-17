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

    # Final ThinkTwice pre-confirmation demo actions
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
    "micro_save",
    "save_rm8",
    "save_rm8_instead",
    "micro_save_recommendation",
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


MONEY_HABIT_LABELS = {
    "excellent": "Strong Money Habits",
    "good": "Good Money Habits",
    "moderate": "Needs Attention",
    "high_risk": "At Risk"
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
    "MICRO_SAVE": "micro_save",
    "BUDGET_WARNING": "budget_warning",
    "POSITIVE_REINFORCEMENT": "positive_reinforcement",
    "PRE_CONFIRMATION_NUDGE": "pre_confirmation_nudge"
}


AI_TIMELINE_EVENTS = {
    "TRANSACTION_RECEIVED": "Payment intent detected",
    "RISK_ANALYSED": "Spending behaviour analysed",
    "VELOCITY_ANALYSED": "Overspending risk predicted",
    "INTERVENTION_SELECTED": "Intervention options generated",
    "SMART_RADAR_ACTIVATED": "Smart Radar activated",
    "DASHBOARD_UPDATED": "Dashboard updated"
}


DEMO_INTERVENTION_OPTIONS = [
    "Continue Anyway",
    "Save RM8 Instead",
    "Find Cheaper Nearby"
]


DEMO_SCENARIOS = {
    "bubble_tea_high_risk": {
        "merchant": "Bubble Tea",
        "amount": 18,
        "category": "food",
        "time": "10:45 PM",
        "location": "Mid Valley",
        "status": "before_confirmation",
        "expectedRisk": "high",
        "expectedAction": "smart_radar_and_save_nudge",
        "estimatedSavings": "RM8"
    },

    "mrt_safe_spending": {
        "merchant": "MRT",
        "amount": 6,
        "category": "transport",
        "time": "8:00 AM",
        "location": "UM Station",
        "status": "before_confirmation",
        "expectedRisk": "low",
        "expectedAction": "safe_spending_reward",
        "estimatedSavings": "RM0"
    },

    "shoes_impulse_shopping": {
        "merchant": "Sneaker Store",
        "amount": 120,
        "category": "shopping",
        "time": "11:30 PM",
        "location": "Sunway Pyramid",
        "status": "before_confirmation",
        "expectedRisk": "high",
        "expectedAction": "micro_save_recommendation",
        "estimatedSavings": "RM8"
    }
}


DASHBOARD_LABELS = {
    "MONEY_HABIT_SCORE": "Money Habit Score",
    "MONEY_SAVED_THIS_WEEK": "Money Saved This Week",
    "SMART_SPENDING_STREAK": "Smart Spending Streak",
    "AI_INSIGHT": "AI Insight"
}


EMOTIONAL_MICROCOPY = {
    "NICE_SAVE": "Nice save 👏",
    "GOOD_CHOICE": "Good choice tonight.",
    "FUTURE_SELF": "Your future self will thank you.",
    "SMALL_HABITS": "Small savings become big habits.",
    "WITHIN_BUDGET": "You stayed within budget today!"
}