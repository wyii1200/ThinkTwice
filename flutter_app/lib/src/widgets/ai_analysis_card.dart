import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/shared.dart';

class AiAnalysisCard extends StatelessWidget {
  final Map<String, dynamic> aiResult;

  const AiAnalysisCard({
    super.key,
    required this.aiResult,
  });

  @override
  Widget build(BuildContext context) {
    final demoDecision = aiResult['demoDecision'] ?? {};
    final risk = aiResult['riskAnalysis'] ?? {};
    final intervention = aiResult['intervention'] ?? {};
    final integrationPayload = aiResult['integrationPayload'] ?? {};
    final smartRadar = integrationPayload['smartRadar'] ?? {};

    final explanation = aiResult['aiExplanation'] as List<dynamic>? ?? [];
    final aiTimeline = aiResult['aiTimeline'] as List<dynamic>? ?? [];
    final riskLevel = risk['riskLevel']?.toString().toLowerCase() ?? 'low';

    final humanRiskLabel = friendlyRiskTitle(riskLevel);

    final humanExplanation = demoDecision['humanExplanation']?.toString() ??
        friendlyRiskSummary(riskLevel);

    final futureImpact = demoDecision['futureImpact']?.toString() ??
        friendlyRiskSummary(riskLevel);

    final recommendedAction = demoDecision['recommendedAction']?.toString() ??
        'Keep tracking your spending.';

    final estimatedSavings =
        demoDecision['estimatedSavings']?.toString() ?? 'RM0';

    final confidence = demoDecision['confidence'] ??
        intervention['interventionConfidence'] ??
        aiResult['interventionConfidence'] ??
        0;

    final triggerRadar = demoDecision['triggerSmartRadar'] == true ||
        smartRadar['triggerSmartRadar'] == true;

    final riskTags = intervention['riskTags'] as List<dynamic>? ?? [];

    Color riskColor;

    switch (riskLevel) {
      case 'high':
        riskColor = const Color(0xFFFF6B6B);
        break;
      case 'medium':
        riskColor = const Color(0xFFFFB84D);
        break;
      default:
        riskColor = const Color(0xFF52C7A5);
    }

    return StaggeredReveal(
      index: 2,
      child: WhiteCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: context.colors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ThinkTwice Check-In',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'A quick read on how this purchase fits today',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF52C7A5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'CHECKING THIS PURCHASE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF52C7A5),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// HUMAN RISK LABEL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                humanRiskLabel,
                style: TextStyle(
                  color: riskColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// RISK TAGS
            if (riskTags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: riskTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: riskColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            /// FUTURE IMPACT BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    riskColor.withOpacity(0.10),
                    riskColor.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    color: riskColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      futureImpact,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// SMART RADAR BANNER
            if (triggerRadar) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radar_rounded,
                      color: Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You could save $estimatedSavings today with a cheaper nearby option.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            /// HUMAN EXPLANATION BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: riskColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      humanExplanation,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// AI EXPLANATION
            const Text(
              'Why we flagged this:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            ...explanation.take(5).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: riskColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 6),

            /// AI RECOMMENDATION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: context.colors.guardianGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recommendedAction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// INTERVENTION BUTTONS
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildActionButton(
                  'Continue Anyway',
                  Colors.grey.shade200,
                  Colors.black87,
                ),
                _buildActionButton(
                  'Save $estimatedSavings Instead',
                  const Color(0xFF52C7A5),
                  Colors.white,
                ),
                _buildActionButton(
                  'Find Cheaper Nearby',
                  const Color(0xFF6C63FF),
                  Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// CONFIDENCE BAR
            Row(
              children: [
                const Text(
                  'Confidence',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '$confidence%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: riskColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ((confidence is num ? confidence / 100 : 0).clamp(0, 1))
                    .toDouble(),
                minHeight: 8,
                backgroundColor: context.colors.muted,
                valueColor: AlwaysStoppedAnimation<Color>(
                  riskColor,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// AI TIMELINE
            const Text(
              'What happened',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            if (aiTimeline.isNotEmpty)
              ...aiTimeline.take(6).map((item) {
                final event = item['event']?.toString() ?? 'Check completed';

                return _buildTimelineItem(
                  event,
                  Icons.auto_awesome_rounded,
                );
              })
            else ...[
              _buildTimelineItem(
                'Payment intent detected',
                Icons.payment_rounded,
              ),
              _buildTimelineItem(
                'Spending pattern reviewed',
                Icons.psychology_alt_rounded,
              ),
              _buildTimelineItem(
                friendlyRiskSummary(riskLevel),
                Icons.warning_amber_rounded,
              ),
              _buildTimelineItem(
                'Intervention generated',
                Icons.lightbulb_rounded,
              ),
              if (triggerRadar)
                _buildTimelineItem(
                  'Smart Radar activated',
                  Icons.radar_rounded,
                ),
            ],

            const SizedBox(height: 10),

            /// EXPLAINABLE AI BUTTON
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  _showExplainabilityDialog(
                    context,
                    explanation,
                    aiResult,
                  );
                },
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text(
                  'Why am I seeing this?',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String text,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExplainabilityDialog(
    BuildContext context,
    List<dynamic> explanation,
    Map<String, dynamic> aiResult,
  ) {
    final explainability = aiResult['explainability'] ?? {};
    final summary = explainability['summary'] ?? {};
    final popupReasons = summary['popupReasons'] as List<dynamic>? ?? [];

    final reasons = popupReasons.isNotEmpty ? popupReasons : explanation;

    showContainedDialog(
      context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Why am I seeing this?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary['mainReason'] != null) ...[
                Text(
                  summary['mainReason'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ...reasons.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• ${e.toString()}'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                explainability['transparencyNote']?.toString() ??
                    'ThinkTwice only recommends actions. You always stay in control.',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
