import os
import json
import google.generativeai as genai


def generate_llm_coaching_message(ai_result: dict) -> dict:
    """
    Gemini-powered coaching layer for ThinkTwice.

    Rule-based agents still control:
    - risk scoring
    - spending velocity
    - intervention decision
    - safety and consent
    - Smart Radar trigger

    Gemini only enhances:
    - notification message
    - dashboard insight
    - action button text
    """

    api_key = os.getenv("GEMINI_API_KEY")

    fallback_nudge = ai_result.get("intervention", {}).get(
        "nudge",
        "ThinkTwice detected your spending pattern. Keep tracking your financial habits today."
    )

    fallback_response = {
        "llmEnabled": False,
        "coachingMessage": fallback_nudge,
        "dashboardInsight": "AI analysis completed using rule-based financial intelligence.",
        "recommendedButtonText": "View Insight",
        "llmStatus": "Using fallback coaching message."
    }

    if not api_key:
        fallback_response["llmStatus"] = "Missing Gemini API key. Using fallback nudge."
        return fallback_response

    try:
        genai.configure(api_key=api_key)

        # Use latest available stable model from your free-tier list
        model = genai.GenerativeModel("gemini-2.5-flash")

        risk_level = ai_result.get("riskAnalysis", {}).get("riskLevel", "unknown")
        reasons = ai_result.get("riskAnalysis", {}).get("reasons", [])
        prediction = ai_result.get("spendingVelocityAnalysis", {}).get(
            "overspendingPrediction", {}
        ).get("prediction", "")

        suggested_amount = ai_result.get("intervention", {}).get(
            "suggestedSavingsAmount", 0
        )

        final_action = ai_result.get("intervention", {}).get("finalAction", "")
        trigger_smart_radar = ai_result.get("intervention", {}).get(
            "smartRadar", {}
        ).get("triggerSmartRadar", False)

        safety_check = ai_result.get("intervention", {}).get("safetyCheck", {})
        requires_consent = safety_check.get("requiresUserConsent", False)

        prompt = f"""
You are ThinkTwice, an AI financial behaviour coach for Malaysian youth.

Generate a short JSON response for a mobile banking app.

Context:
Risk level: {risk_level}
Risk reasons: {reasons}
Prediction: {prediction}
Suggested savings amount: RM{suggested_amount}
Final action: {final_action}
Smart Radar triggered: {trigger_smart_radar}
User consent required: {requires_consent}

Return ONLY valid JSON in this exact format:
{{
  "coachingMessage": "...",
  "dashboardInsight": "...",
  "recommendedButtonText": "..."
}}

Rules:
- coachingMessage must be maximum 20 words.
- dashboardInsight must be maximum 25 words.
- recommendedButtonText must be maximum 4 words.
- Be warm, concise, and non-judgmental.
- If savings is involved, mention approval or consent.
- If Smart Radar is involved, mention cheaper nearby options.
- Do not say money is moved automatically.
- Use RM naturally.
"""

        response = model.generate_content(prompt)
        raw_text = response.text.strip()

        # Clean possible markdown formatting from Gemini
        raw_text = raw_text.replace("```json", "").replace("```", "").strip()

        parsed = json.loads(raw_text)

        return {
            "llmEnabled": True,
            "coachingMessage": parsed.get("coachingMessage", fallback_nudge),
            "dashboardInsight": parsed.get(
                "dashboardInsight",
                "Gemini generated a personalised financial coaching insight."
            ),
            "recommendedButtonText": parsed.get("recommendedButtonText", "View Insight"),
            "llmStatus": "Gemini coaching generated successfully."
        }

    except Exception as e:
        return {
            "llmEnabled": False,
            "coachingMessage": fallback_nudge,
            "dashboardInsight": "Gemini fallback activated. Rule-based AI response is still available.",
            "recommendedButtonText": "View Insight",
            "llmStatus": f"Gemini failed. Using fallback. Error: {str(e)}"
        }