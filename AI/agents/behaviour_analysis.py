from utils.transaction_utils import is_late_night_time, get_primary_category


def analyse_behaviour(user):
    late_night_spending = any(
        is_late_night_time(transaction.time)
        for transaction in user.transactions
    )

    primary_category = get_primary_category(user.transactions)

    transaction_count = len(user.transactions)

    return {
        "lateNightSpending": late_night_spending,
        "primaryCategory": primary_category,
        "transactionCount": transaction_count
    }