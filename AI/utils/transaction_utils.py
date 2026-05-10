from datetime import datetime


def safe_divide(numerator, denominator):
    if denominator == 0:
        return 0

    return numerator / denominator


def normalize_category(category: str) -> str:
    if not category:
        return "other"

    normalized = category.strip().lower()

    category_aliases = {
        "food & beverage": "food",
        "f&b": "food",
        "cafe": "food",
        "restaurant": "food",
        "groceries": "food",

        "grab": "transport",
        "lrt": "transport",
        "mrt": "transport",
        "bus": "transport",
        "taxi": "transport",

        "mall": "shopping",
        "clothes": "shopping",
        "fashion": "shopping",

        "movie": "entertainment",
        "cinema": "entertainment",
        "game": "entertainment"
    }

    return category_aliases.get(
        normalized,
        normalized
    )


def get_primary_category(transactions):
    category_totals = {}

    for transaction in transactions:
        category = normalize_category(
            transaction.category
        )

        category_totals[category] = (
            category_totals.get(category, 0)
            + transaction.amount
        )

    if not category_totals:
        return "other"

    return max(
        category_totals,
        key=category_totals.get
    )


def get_category_totals(transactions):
    category_totals = {}

    for transaction in transactions:
        category = normalize_category(
            transaction.category
        )

        category_totals[category] = (
            category_totals.get(category, 0)
            + transaction.amount
        )

    return category_totals


def is_late_night_time(time_text: str) -> bool:
    """
    Supports:
    - 10:45 PM
    - 22:45
    - 9:30 PM
    """

    if not time_text:
        return False

    time_text = time_text.strip().upper()

    time_formats = [
        "%I:%M %p",
        "%H:%M"
    ]

    for time_format in time_formats:
        try:
            parsed_time = datetime.strptime(
                time_text,
                time_format
            )

            hour = parsed_time.hour

            return hour >= 22 or hour < 5

        except ValueError:
            continue

    return False


def format_rm(amount):
    return f"RM{amount:.2f}"


def calculate_total_spending(transactions):
    return sum(
        transaction.amount
        for transaction in transactions
    )