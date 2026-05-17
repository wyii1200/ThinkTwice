from datetime import datetime


def safe_divide(numerator, denominator):
    try:
        if denominator is None or denominator == 0:
            return 0

        return numerator / denominator

    except Exception:
        return 0


def safe_amount(value):
    try:
        if value is None:
            return 0

        return float(value)

    except Exception:
        return 0


def normalize_category(category: str) -> str:
    if not category:
        return "other"

    normalized = str(category).strip().lower()

    category_aliases = {
        # Food
        "food": "food",
        "food & beverage": "food",
        "f&b": "food",
        "cafe": "food",
        "coffee": "food",
        "bubble tea": "food",
        "dessert": "food",
        "drink": "food",
        "restaurant": "food",
        "groceries": "food",
        "grocery": "food",
        "snack": "food",

        # Transport
        "transport": "transport",
        "grab": "transport",
        "lrt": "transport",
        "mrt": "transport",
        "bus": "transport",
        "taxi": "transport",
        "train": "transport",
        "rapidkl": "transport",

        # Shopping
        "shopping": "shopping",
        "mall": "shopping",
        "clothes": "shopping",
        "fashion": "shopping",
        "shoes": "shopping",
        "sneakers": "shopping",
        "retail": "shopping",

        # Entertainment
        "entertainment": "entertainment",
        "movie": "entertainment",
        "cinema": "entertainment",
        "game": "entertainment",
        "gaming": "entertainment",
        "karaoke": "entertainment",
    }

    return category_aliases.get(
        normalized,
        normalized
    )


def get_transaction_amount(transaction):
    return safe_amount(
        getattr(
            transaction,
            "amount",
            0
        )
    )


def get_transaction_category(transaction):
    return normalize_category(
        getattr(
            transaction,
            "category",
            "other"
        )
    )


def get_primary_category(transactions):
    category_totals = {}

    for transaction in transactions:
        category = get_transaction_category(
            transaction
        )

        amount = get_transaction_amount(
            transaction
        )

        category_totals[category] = (
            category_totals.get(category, 0)
            + amount
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
        category = get_transaction_category(
            transaction
        )

        amount = get_transaction_amount(
            transaction
        )

        category_totals[category] = (
            category_totals.get(category, 0)
            + amount
        )

    return category_totals


def is_late_night_time(time_text: str) -> bool:
    """
    Supports:
    - 10:45 PM
    - 22:45
    - 9:30 PM
    - 2026-05-17T22:45:00
    """

    if not time_text:
        return False

    time_text = str(time_text).strip().upper()

    time_formats = [
        "%I:%M %p",
        "%H:%M",
        "%Y-%m-%dT%H:%M:%S",
        "%Y-%m-%d %H:%M:%S"
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
    amount = safe_amount(
        amount
    )

    if amount.is_integer():
        return f"RM{int(amount)}"

    return f"RM{amount:.2f}"


def calculate_total_spending(transactions):
    return sum(
        get_transaction_amount(transaction)
        for transaction in transactions
    )