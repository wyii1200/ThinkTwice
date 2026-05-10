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

    weekend_spending_pattern = transaction_count >= 4

    risky_categories = [
        "food",
        "shopping",
        "entertainment"
    ]

    risky_category_detected = (
        primary_category in risky_categories
    )

    if late_night_spending and risky_category_detected:
        behaviour_pattern = (
            "Impulsive spending behaviour detected."
        )

    elif risky_category_detected:
        behaviour_pattern = (
            "Frequent risky-category spending detected."
        )

    else:
        behaviour_pattern = (
            "Spending behaviour currently stable."
        )

    return {
        "lateNightSpending": late_night_spending,

        "primaryCategory": primary_category,

        "transactionCount": transaction_count,

        "weekendSpendingPattern":
        weekend_spending_pattern,

        "riskyCategoryDetected":
        risky_category_detected,

        "behaviourPattern":
        behaviour_pattern
    }