from utils.transaction_utils import (
    is_late_night_time,
    get_primary_category
)


def analyse_behaviour(user):
    transactions = user.transactions

    late_night_spending = any(
        is_late_night_time(transaction.time)
        for transaction in transactions
    )

    primary_category = get_primary_category(transactions)
    transaction_count = len(transactions)

    frequent_spending_pattern = transaction_count >= 4

    risky_categories = [
        "food",
        "shopping",
        "entertainment"
    ]

    risky_category_detected = primary_category in risky_categories

    if late_night_spending and risky_category_detected:
        behaviour_pattern = (
            "You may be making an impulse purchase right now."
        )
        user_friendly_insight = (
            f"Your {primary_category} spending looks unusually active tonight."
        )

    elif risky_category_detected:
        behaviour_pattern = (
            f"Your {primary_category} spending is more active than usual."
        )
        user_friendly_insight = (
            f"ThinkTwice noticed repeated {primary_category} spending today."
        )

    elif frequent_spending_pattern:
        behaviour_pattern = (
            "You have made several purchases today."
        )
        user_friendly_insight = (
            "Small purchases can add up quickly, so ThinkTwice is checking your budget impact."
        )

    else:
        behaviour_pattern = (
            "Your spending behaviour currently looks stable."
        )
        user_friendly_insight = (
            "This purchase looks manageable based on your current spending pattern."
        )

    return {
        "lateNightSpending": late_night_spending,
        "primaryCategory": primary_category,
        "transactionCount": transaction_count,
        "frequentSpendingPattern": frequent_spending_pattern,
        "riskyCategoryDetected": risky_category_detected,
        "behaviourPattern": behaviour_pattern,
        "userFriendlyInsight": user_friendly_insight
    }