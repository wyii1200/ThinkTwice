DEMO_RESPONSES = {
    "bubble_tea": {
        "transaction": {
            "amount": 18,
            "merchant": "Bubble Tea",
            "category": "food",
            "time": "21:30"
        },
        "risk": {
            "level": "high",
            "score": 82,
            "confidence": 0.91
        },
        "ui": {
            "headline": "Impulse spending detected",
            "explanation": "You have been spending more often than usual on food tonight.",
            "futureImpact": "Your weekly food budget may exceed in 2 days.",
            "suggestedAction": "Save RM8 instead or find a cheaper nearby option."
        },
        "reasons": [
            "Food spending exceeded safe limit",
            "Late-night spending detected",
            "Spending frequency increased this week"
        ],
        "actions": {
            "primary": "Find Cheaper Nearby",
            "secondary": "Save RM8 Instead",
            "danger": "Continue Anyway"
        },
        "smartRadar": {
            "trigger": True,
            "category": "food",
            "message": "Cheaper drink options are available nearby."
        },
        "dashboardUpdate": {
            "resilienceScoreChange": -4,
            "savingOpportunity": 8,
            "budgetStatus": "at_risk"
        }
    },

    "mrt": {
        "transaction": {
            "amount": 6,
            "merchant": "MRT",
            "category": "transport",
            "time": "08:20"
        },
        "risk": {
            "level": "low",
            "score": 18,
            "confidence": 0.88
        },
        "ui": {
            "headline": "Safe spending detected",
            "explanation": "This looks like a normal transport expense within your usual pattern.",
            "futureImpact": "Your weekly budget is still healthy.",
            "suggestedAction": "You can continue safely."
        },
        "reasons": [
            "Amount is within normal range",
            "Transport is an essential spending category",
            "No unusual spending pattern detected"
        ],
        "actions": {
            "primary": "Continue",
            "secondary": "View Budget",
            "danger": None
        },
        "smartRadar": {
            "trigger": False,
            "category": "transport",
            "message": "No cheaper alternative needed."
        },
        "dashboardUpdate": {
            "resilienceScoreChange": 2,
            "savingOpportunity": 0,
            "budgetStatus": "healthy"
        }
    },

    "shoes": {
        "transaction": {
            "amount": 120,
            "merchant": "Shoes",
            "category": "shopping",
            "time": "22:10"
        },
        "risk": {
            "level": "critical",
            "score": 94,
            "confidence": 0.93
        },
        "ui": {
            "headline": "High-impact purchase warning",
            "explanation": "This purchase is much higher than your usual shopping spending.",
            "futureImpact": "It may reduce your savings progress and affect your monthly budget.",
            "suggestedAction": "Pause this purchase or move RM50 into savings first."
        },
        "reasons": [
            "Large non-essential purchase detected",
            "Spending amount is higher than usual",
            "Purchase may affect savings goal"
        ],
        "actions": {
            "primary": "Pause Purchase",
            "secondary": "Save RM50 First",
            "danger": "Continue Anyway"
        },
        "smartRadar": {
            "trigger": False,
            "category": "shopping",
            "message": "Smart Radar is not needed for this purchase."
        },
        "dashboardUpdate": {
            "resilienceScoreChange": -8,
            "savingOpportunity": 50,
            "budgetStatus": "high_risk"
        }
    }
}