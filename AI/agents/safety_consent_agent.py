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

    final_action_lower = str(
        final_action
    ).lower()

    requires_consent = any(
        action.lower() in final_action_lower
        for action in FINANCIAL_ACTIONS_REQUIRING_CONSENT
    )

    safety_level = (
        "financial_action"
        if requires_consent
        else "informational"
    )

    can_execute = not requires_consent

    if requires_consent:

        consent_status = (
            "pending_user_approval"
        )

        consent_reason = (
            "This recommendation may involve saving money or changing a financial action, so it needs user approval first."
        )

        user_control_message = (
            "You stay in control. ThinkTwice will never move money without your approval."
        )

        consent_cta = (
            "Approve Action"
        )

    else:

        consent_status = (
            "not_required"
        )

        consent_reason = (
            "This recommendation only provides guidance, reminders, or spending insights."
        )

        user_control_message = (
            "No money will be moved automatically."
        )

        consent_cta = (
            "Got it"
        )

    ai_decision["safetyCheck"] = {

        "safetyLevel":
        safety_level,

        "requiresUserConsent":
        requires_consent,

        "consentStatus":
        consent_status,

        "consentReason":
        consent_reason,

        "userControlMessage":
        user_control_message,

        "consentCta":
        consent_cta,

        "canExecuteAction":
        can_execute,

        "responsibleAI": {

            "transparentDecisionMaking":
            True,

            "requiresExplicitConsent":
            requires_consent,

            "financialSafetyEnabled":
            True,

            "userControlProtected":
            True,

            "preConfirmationOnly":
            True
        }
    }

    return ai_decision