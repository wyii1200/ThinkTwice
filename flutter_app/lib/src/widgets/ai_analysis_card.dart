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

    final explanation = (aiResult['aiExplanation'] as List<dynamic>? ?? []);

    final riskLevel = risk['riskLevel']?.toString().toUpperCase() ?? 'LOW';

    final confidence = intervention['interventionConfidence'] ?? 0;

    final prediction = velocity['overspendingPrediction']?['prediction'] ??
        'AI is monitoring your financial behaviour.';

    final coaching = intervention['llmEnhancedNudge'] ??
        intervention['nudge'] ??
        'Your spending behaviour is stable.';

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
                      const SizedBox(height: 2),
                      Text(
                        'Real-time behavioural intelligence',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.mutedForeground,
                        ),
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
                      prediction,
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

            /// AI EXPLANATION
            const Text(
              'AI detected:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            ...explanation.map(
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
                      coaching,
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
                value: confidence / 100,
                minHeight: 8,
                backgroundColor: context.colors.muted,
                valueColor: AlwaysStoppedAnimation<Color>(
                  riskColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
