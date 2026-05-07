from datetime import datetime


def safe_divide(numerator, denominator):
    if denominator == 0:
        return 0
    return numerator / denominator


def normalize_category(category: str) -> str:
    if not category:
        return "other"
    return category.strip().lower()


def get_primary_category(transactions):
    category_totals = {}

    for transaction in transactions:
        category = normalize_category(transaction.category)
        category_totals[category] = category_totals.get(category, 0) + transaction.amount

    if not category_totals:
        return "other"

    return max(category_totals, key=category_totals.get)


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

    try:
        if "AM" in time_text or "PM" in time_text:
            parsed_time = datetime.strptime(time_text, "%I:%M %p")
            hour = parsed_time.hour
        else:
            parsed_time = datetime.strptime(time_text, "%H:%M")
            hour = parsed_time.hour

        return hour >= 22 or hour < 5

    except ValueError:
        return False