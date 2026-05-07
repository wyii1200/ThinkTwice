def check_safety_and_consent(ai_decision: dict) -> dict:

    financial_actions = [
        "auto_save",
        "round_up_save",
        "transfer_to_savings",
        "salary_auto_allocation"
    ]

    suggested_action = ai_decision.get("selectedIntervention", "")

    requires_consent = any(
        action in suggested_action
        for action in financial_actions
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
            else "This action only provides advice or notification, so no financial consent is required."
        ),
        "canExecuteAction": not requires_consent
    }

    return ai_decision