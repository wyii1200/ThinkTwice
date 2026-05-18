import os
import json

import google.generativeai as genai


def generate_llm_coaching_message(ai_result: dict) -> dict:
    """
    Gemini-enhanced behavioural coaching layer.

    IMPORTANT:
    - Rule-based agents remain the PRIMARY decision system.
    - Gemini only enhances:
        * coaching message
        * dashboard insight
        * button wording
        * emotional microcopy
    - System must remain stable even if Gemini fails.
    """

    enable_gemini = (
        os.getenv(
            "ENABLE_GEMINI",
            "false"
        ).lower() == "true"
    )

    api_key = os.getenv(
        "GEMINI_API_KEY"
    )

    intervention = ai_result.get(
        "intervention",
        {}
    )

    risk_analysis = ai_result.get(
        "riskAnalysis",
        {}
    )

    fallback_nudge = intervention.get(
        "nudge",
        "You’ve been spending more on food than usual tonight."
    )

    fallback_response = {

        "llmEnabled":
        False,

        "coachingMessage":
        fallback_nudge,

        "dashboardInsight":
        (
            "ThinkTwice AI coaching is running in stable mode."
        ),

        "recommendedButtonText":
        intervention.get(
            "ctaButtonText",
            "View Insight"
        ),

        "emotionalMicrocopy":
        (
            "Small savings become stronger habits."
        ),

        "aiCoachTone":
        "supportive",

        "llmStatus":
        "Stable rule-based fallback active."
    }

    # =========================================================
    # GEMINI DISABLED
    # =========================================================

    if not enable_gemini:

        fallback_response["llmStatus"] = (
            "Gemini disabled. Stable rule-based fallback active."
        )

        return fallback_response

    # =========================================================
    # NO API KEY
    # =========================================================

    if not api_key:

        fallback_response["llmStatus"] = (
            "Missing Gemini API key. Using fallback coaching."
        )

        return fallback_response

    try:

        genai.configure(
            api_key=api_key
        )

        model = genai.GenerativeModel(
            "gemini-2.5-flash-preview-05-20"
        )

        risk_level = risk_analysis.get(
            "riskLevel",
            "unknown"
        )

        risk_label = risk_analysis.get(
            "riskLabel",
            "Budget Warning"
        )

        reasons = risk_analysis.get(
            "reasons",
            []
        )

        prediction = ai_result.get(
            "spendingVelocityAnalysis",
            {}
        ).get(
            "overspendingPrediction",
            {}
        ).get(
            "prediction",
            ""
        )

        suggested_amount = intervention.get(
            "suggestedSavingsAmount",
            0
        )

        final_action = intervention.get(
            "finalAction",
            ""
        )

        trigger_smart_radar = intervention.get(
            "smartRadar",
            {}
        ).get(
            "triggerSmartRadar",
            False
        )

        safety_check = intervention.get(
            "safetyCheck",
            {}
        )

        requires_consent = safety_check.get(
            "requiresUserConsent",
            False
        )

        budget_profile = ai_result.get("budgetProfile", {})
        budget_context = ""
        if budget_profile:
            adaptability = budget_profile.get("adaptability_score", 50)
            savings_rate = budget_profile.get("savings_rate", "Unknown")
            
            if adaptability < 40:
                protection_level = "STRICT: User requested strict protection over their savings goal. Be firm but polite."
            elif adaptability > 70:
                protection_level = "FLEXIBLE: User is comfortable with flexible spending. Focus on gentle guidance."
            else:
                protection_level = "MODERATE: User prefers balanced guidance."
                
            budget_context = f"\nUser Adaptability Score: {adaptability} ({protection_level})\nTarget Savings Rate: {savings_rate}"

        prompt = f"""
You are ThinkTwice, a warm and supportive AI financial behaviour coach for Malaysian university students and young adults.

You are NOT a bank warning system.
You are a proactive spending behaviour coach.

Generate a SHORT JSON response for a mobile banking app.

CONTEXT:
Risk level: {risk_level}
Risk label: {risk_label}
Risk reasons: {reasons}
Prediction: {prediction}
Suggested savings amount: RM{suggested_amount}
Final action: {final_action}
Smart Radar triggered: {trigger_smart_radar}
User consent required: {requires_consent}{budget_context}

Return ONLY valid JSON in this EXACT format:

{{
  "coachingMessage": "...",
  "dashboardInsight": "...",
  "recommendedButtonText": "...",
  "emotionalMicrocopy": "...",
  "aiCoachTone": "..."
}}

STRICT RULES:
- coachingMessage max 20 words
- dashboardInsight max 25 words
- recommendedButtonText max 4 words
- emotionalMicrocopy max 12 words
- Be supportive and non-judgmental
- Sound like a modern fintech app
- Avoid robotic banking language
- Never scare the user
- If Smart Radar is active, mention cheaper nearby options naturally
- Never say money is moved automatically
- Mention user approval naturally if savings is involved
- Use RM naturally
- Avoid emojis except 👏
"""

        gemini_response = model.generate_content(
            prompt
        )

        raw_text = gemini_response.text.strip()

        raw_text = raw_text.replace(
            "```json",
            ""
        )

        raw_text = raw_text.replace(
            "```",
            ""
        )

        raw_text = raw_text.strip()

        parsed = json.loads(
            raw_text
        )

        if not isinstance(parsed, dict):
            raise ValueError("Invalid Gemini JSON response")

        return {

            "llmEnabled":
            True,

            "coachingMessage":
            parsed.get(
                "coachingMessage",
                fallback_nudge
            ),

            "dashboardInsight":
            parsed.get(
                "dashboardInsight",
                "ThinkTwice generated a personalised spending insight."
            ),

            "recommendedButtonText":
            parsed.get(
                "recommendedButtonText",
                intervention.get(
                    "ctaButtonText",
                    "View Insight"
                )
            ),

            "emotionalMicrocopy":
            parsed.get(
                "emotionalMicrocopy",
                "Good choices build better habits."
            ),

            "aiCoachTone":
            parsed.get(
                "aiCoachTone",
                "supportive"
            ),

            "llmStatus":
            "Gemini coaching generated successfully.",

            "aiEnhancementMode":
            "gemini_behavioural_coaching"
        }

    except Exception as e:

        return {

            "llmEnabled":
            False,

            "coachingMessage":
            fallback_nudge,

            "dashboardInsight":
            (
                "Gemini fallback activated. Stable AI coaching is still available."
            ),

            "recommendedButtonText":
            intervention.get(
                "ctaButtonText",
                "View Insight"
            ),

            "emotionalMicrocopy":
            (
                "Small savings become stronger habits."
            ),

            "aiCoachTone":
            "supportive",

            "llmStatus":
            f"Gemini failed. Using fallback. Error: {str(e)}",

           "aiEnhancementMode":
            "rule_based_fallback"
            
        }