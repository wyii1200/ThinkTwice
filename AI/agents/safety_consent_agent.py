from config.constants import FINANCIAL_ACTIONS_REQUIRING_CONSENT


def check_safety_and_consent(ai_decision: dict) -> dict:
    final_action = ai_decision.get("finalAction", "")

    requires_consent = any(
        action in final_action
        for action in FINANCIAL_ACTIONS_REQUIRING_CONSENT
    )

    ai_decision["safetyCheck"] = {
        "requiresUserConsent": requires_consent,
        "consentStatus": (
            "pending_user_approval"
            if requires_consent
            else "not_required"
        ),
        "consentReason": (
            "This action may move user money, so user approval is required before execution."
            if requires_consent
            else "This action only provides advice, tracking, or notification."
        ),
        "canExecuteAction": not requires_consent
    }

    return ai_decision