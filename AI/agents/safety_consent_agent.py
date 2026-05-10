from config.constants import (
    FINANCIAL_ACTIONS_REQUIRING_CONSENT
)


def check_safety_and_consent(
    ai_decision: dict
) -> dict:

    final_action = ai_decision.get(
        "finalAction",
        ""
    )

    requires_consent = any(
        action in final_action
        for action in FINANCIAL_ACTIONS_REQUIRING_CONSENT
    )

    if requires_consent:
        safety_level = "financial_action"

    else:
        safety_level = "informational"


    can_execute = not requires_consent

    if requires_consent:

        consent_status = (
            "pending_user_approval"
        )

        consent_reason = (
            "This intervention may move user money or modify financial behaviour settings, so explicit user approval is required before execution."
        )

        user_control_message = (
            "The user remains fully in control of financial actions."
        )

    else:

        consent_status = "not_required"

        consent_reason = (
            "This intervention only provides guidance, tracking, or behavioural recommendations."
        )

        user_control_message = (
            "No financial action will be executed automatically."
        )

    responsible_ai_flags = {
        "transparentDecisionMaking": True,
        "requiresExplicitConsent":
        requires_consent,

        "financialSafetyEnabled": True,

        "userControlProtected": True
    }

    ai_decision["safetyCheck"] = {
        "safetyLevel": safety_level,

        "requiresUserConsent":
        requires_consent,

        "consentStatus":
        consent_status,

        "consentReason":
        consent_reason,

        "userControlMessage":
        user_control_message,

        "canExecuteAction":
        can_execute,

        "responsibleAI":
        responsible_ai_flags
    }

    return ai_decision