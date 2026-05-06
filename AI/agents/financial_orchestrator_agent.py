def orchestrate_intervention(
    risk_result,
    score_result,
    behaviour_result
):

    intervention = "none"

    # High risk intervention
    if risk_result["riskLevel"] == "high":

        if behaviour_result["lateNightSpending"]:

            intervention = "smart_radar_and_auto_save"

        else:
            intervention = "auto_save"

    # Medium risk intervention
    elif risk_result["riskLevel"] == "medium":

        intervention = "send_warning_nudge"

    # Good behaviour reward
    if score_result["smartDecisionScore"] >= 70:

        reward = "streak_bonus"

    else:
        reward = "no_reward"

    return {
        "selectedIntervention": intervention,
        "rewardAction": reward
    }