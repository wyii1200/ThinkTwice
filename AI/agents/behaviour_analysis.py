from utils.transaction_utils import (
    is_late_night_time,
    get_primary_category
)


def analyse_behaviour(user):
    transactions = user.transactions

    latest_transaction = (
        transactions[-1]
        if transactions
        else None
    )

    latest_merchant = (
        latest_transaction.merchant
        if latest_transaction and latest_transaction.merchant
        else "this purchase"
    )

    latest_amount = (
        latest_transaction.amount
        if latest_transaction
        else 0
    )

    late_night_spending = any(
        is_late_night_time(transaction.time)
        for transaction in transactions
    )

    primary_category = get_primary_category(
        transactions
    )

    transaction_count = len(
        transactions
    )

    frequent_spending_pattern = (
        transaction_count >= 4
    )

    risky_categories = [
        "food",
        "shopping",
        "entertainment",
        "transport"
    ]

    risky_category_detected = (
        primary_category in risky_categories
    )

    if late_night_spending and risky_category_detected:
        behaviour_pattern = (
            "Possible impulse spending behaviour detected."
        )

        user_friendly_insight = (
            f"You’ve been spending more on {primary_category} than usual tonight."
        )

        behaviour_tone = "urgent"

    elif risky_category_detected and frequent_spending_pattern:
        behaviour_pattern = (
            f"Repeated {primary_category} spending detected."
        )

        user_friendly_insight = (
            f"You’ve made several {primary_category} purchases today, so ThinkTwice is checking this before payment."
        )

        behaviour_tone = "warning"

    elif risky_category_detected:
        behaviour_pattern = (
            f"{primary_category.capitalize()} spending needs attention."
        )

        user_friendly_insight = (
            f"This {primary_category} purchase may affect your budget today."
        )

        behaviour_tone = "caution"

    elif frequent_spending_pattern:
        behaviour_pattern = (
            "Frequent small purchases detected."
        )

        user_friendly_insight = (
            "Small purchases can add up quickly, so ThinkTwice is checking your budget impact."
        )

        behaviour_tone = "caution"

    else:
        behaviour_pattern = (
            "Your spending behaviour currently looks stable."
        )

        user_friendly_insight = (
            "This purchase looks manageable based on your current spending pattern."
        )

        behaviour_tone = "positive"

    return {
        "lateNightSpending": late_night_spending,
        "primaryCategory": primary_category,
        "transactionCount": transaction_count,
        "frequentSpendingPattern": frequent_spending_pattern,
        "riskyCategoryDetected": risky_category_detected,
        "behaviourPattern": behaviour_pattern,
        "userFriendlyInsight": user_friendly_insight,
        "behaviourTone": behaviour_tone,
        "latestMerchant": latest_merchant,
        "latestAmount": latest_amount
    }