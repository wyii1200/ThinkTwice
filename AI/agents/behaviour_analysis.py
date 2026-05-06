def analyse_behaviour(user):

    late_night_spending = False

    for transaction in user.transactions:

        if "PM" in transaction.time:
            late_night_spending = True

    return {
        "lateNightSpending": late_night_spending
    }