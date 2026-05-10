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
    final risk = aiResult['riskAnalysis'] ?? {};
    final intervention = aiResult['intervention'] ?? {};
    final velocity = aiResult['spendingVelocityAnalysis'] ?? {};
    final integrationPayload = aiResult['integrationPayload'] ?? {};
    final smartRadar = integrationPayload['smartRadar'] ?? {};

    final explanation = aiResult['aiExplanation'] as List<dynamic>? ?? [];
    final aiTimeline = aiResult['aiTimeline'] as List<dynamic>? ?? [];

    final riskLevel = risk['riskLevel']?.toString().toUpperCase() ?? 'LOW';

    final confidence = intervention['interventionConfidence'] ??
        aiResult['interventionConfidence'] ??
        0;

    final severityScore = aiResult['behaviourSeverityScore'] ?? 0;

    final prediction = velocity['overspendingPrediction']?['prediction'] ??
        aiResult['aiVisibility']?['predictionText'] ??
        'AI is monitoring your financial behaviour.';

    final coaching = intervention['llmEnhancedNudge'] ??
        intervention['nudge'] ??
        aiResult['llmCoaching']?['coachingMessage'] ??
        'Your spending behaviour is stable.';

    final triggerRadar = smartRadar['triggerSmartRadar'] == true;

    final radarCategory = smartRadar['radarCategory']?.toString() ?? '';

    final riskTags = intervention['riskTags'] as List<dynamic>? ?? [];

    Color riskColor;

    switch (riskLevel.toLowerCase()) {
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
                        'ThinkTwice AI Analysis',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Real-time behavioural intelligence',
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
                            'LIVE AI ACTIVE',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    riskLevel,
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

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

            /// PREDICTION BOX
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
                      prediction.toString(),
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
                        'Smart Savings Radar activated for $radarCategory spending.',
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

            /// AI EXPLANATION
            const Text(
              'AI detected:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            ...explanation.take(6).map(
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

            /// AI COACHING
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
                      coaching.toString(),
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

            /// CONFIDENCE BAR
            Row(
              children: [
                const Text(
                  'AI Confidence',
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

            const SizedBox(height: 14),

            /// SEVERITY SCORE
            Row(
              children: [
                const Text(
                  'Behaviour Severity',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '$severityScore/100',
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
                value: ((severityScore is num ? severityScore / 100 : 0)
                        .clamp(0, 1))
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
              'AI Timeline',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            if (aiTimeline.isNotEmpty)
              ...aiTimeline.take(7).map((item) {
                final event = item['event']?.toString() ?? 'AI step completed';
                final agent = item['agent']?.toString() ?? 'AI Agent';

                return _buildTimelineItem(
                  '$agent: $event',
                  Icons.auto_awesome_rounded,
                );
              })
            else ...[
              _buildTimelineItem(
                'Spending spike detected',
                Icons.trending_up_rounded,
              ),
              _buildTimelineItem(
                'Overspending risk increased',
                Icons.warning_amber_rounded,
              ),
              _buildTimelineItem(
                'Behaviour intervention triggered',
                Icons.psychology_alt_rounded,
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

    showDialog(
      context: context,
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
                    'ThinkTwice only recommends actions. Financial actions always require user approval.',
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
