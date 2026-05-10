import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';

import '../services/ai_service.dart';
import '../services/ai_state.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({
    super.key,
    required this.plan,
    required this.goal,
    required this.aiInsights,
    required this.nudgeHistory,
    required this.savingsPocket,
    required this.transactions,
  });

  final BudgetPlan plan;
  final double goal;
  final List<String> aiInsights;
  final List<Map<String, dynamic>> nudgeHistory;
  final double savingsPocket;
  final List<TransactionRecord> transactions;

  @override
  Widget build(BuildContext context) {
    final aiResult = AiState.latestAiResult;

    final riskScore = aiResult?['riskAnalysis']?['riskScore'] ?? 35;
    final velocityScore =
        aiResult?['spendingVelocityAnalysis']?['velocityScore'] ?? 35;

    final suggestedSavings =
        aiResult?['intervention']?['suggestedSavingsAmount'] ?? 0;

    final riskLevel =
        aiResult != null ? AiService.extractRiskLevel(aiResult) : 'low';

    final prediction = aiResult != null
        ? AiService.extractPrediction(aiResult)
        : 'AI is monitoring your spending behaviour.';

    final coachingMessage = aiResult != null
        ? AiService.extractCoachingMessage(aiResult)
        : 'Keep tracking your spending habits.';

    final dashboardInsight = aiResult != null
        ? AiService.extractDashboardInsight(aiResult)
        : plan.recommendations.first;

    final resilienceScore =
        aiResult != null ? AiService.extractResilienceScore(aiResult) : 50;

    final smartScore =
        aiResult != null ? AiService.extractSmartDecisionScore(aiResult) : 50;

    final explanationList =
        aiResult != null ? AiService.extractInsightTexts(aiResult) : [];

    final trend = [
      30,
      38,
      42,
      45,
      50,
      riskScore * 0.35,
      velocityScore * 0.4,
      riskScore * 0.45,
      velocityScore * 0.5,
      riskScore * 0.55,
      velocityScore * 0.6,
      riskScore * 0.65,
    ].map((e) => e.clamp(25, 110).toDouble()).toList();

    final savings = [
      savingsPocket * 0.15,
      savingsPocket * 0.25,
      savingsPocket * 0.30,
      savingsPocket * 0.42,
      savingsPocket * 0.50,
      savingsPocket * 0.65,
      savingsPocket + suggestedSavings,
    ].map((e) => e.clamp(10, 90).toDouble()).toList();

    final topAllocations = plan.allocations.take(3).toList();

    final categoryBreakdown = aiResult?['riskAnalysis']?['categoryBreakdown']
        as Map<String, dynamic>?;

    final liveCategoryRows = categoryBreakdown != null
        ? categoryBreakdown.entries.map((entry) {
            final amount = (entry.value as num).toDouble();
            final total = categoryBreakdown.values
                .map((v) => (v as num).toDouble())
                .fold<double>(0, (a, b) => a + b);

            final percent = total == 0 ? 0.0 : amount / total;

            return (
              entry.key,
              percent,
              amount,
            );
          }).toList()
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your AI financial intelligence',
            style: TextStyle(
              fontSize: 14,
              color: context.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Personalized insights',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          InsightCard(
            icon: Icons.warning_amber_rounded,
            tone: riskLevel == 'high' ? 'warning' : 'primary',
            title: 'Current AI risk level: ${riskLevel.toUpperCase()}',
            body: prediction,
          ),
          const SizedBox(height: 8),
          InsightCard(
            icon: Icons.psychology_alt_rounded,
            tone: 'primary',
            title: 'AI coaching insight',
            body: coachingMessage,
          ),
          const SizedBox(height: 8),
          InsightCard(
            icon: Icons.track_changes_rounded,
            tone: 'primary',
            title:
                'Resilience score: $resilienceScore | Smart score: $smartScore',
            body: dashboardInsight,
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI explanation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (explanationList.isEmpty)
                  Text(
                    'Run the AI analysis to generate explainable financial intelligence.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.mutedForeground,
                    ),
                  ),
                ...explanationList.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-driven spending trend',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generated from latest risk score and spending velocity.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 128,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      trend.length,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              height: trend[index],
                              decoration: BoxDecoration(
                                color: index == trend.length - 1
                                    ? null
                                    : context.colors.muted,
                                gradient: index == trend.length - 1
                                    ? context.colors.primaryGradient
                                    : null,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI category distribution',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  liveCategoryRows != null
                      ? 'Based on latest AI category breakdown.'
                      : 'Showing planned budget allocation until AI analysis runs.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                if (liveCategoryRows != null)
                  ...liveCategoryRows.map((allocation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                allocation.$1.toString().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${formatRm(allocation.$2 * 100)}% | RM ${formatRm(allocation.$3)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: allocation.$2,
                              minHeight: 6,
                              backgroundColor: context.colors.muted,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                else
                  ...topAllocations.map((allocation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                allocation.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${formatRm(allocation.percent * 100)}% | RM ${formatRm(allocation.amount)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: allocation.percent,
                              minHeight: 6,
                              backgroundColor: context.colors.muted,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                allocation.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                Text(
                  aiResult != null
                      ? 'AI detected category-level spending behaviour from the latest transaction pattern.'
                      : plan.recommendations.last,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: context.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI savings momentum',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+RM ${(savingsPocket + suggestedSavings).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: context.colors.success,
                  ),
                ),
                Text(
                  suggestedSavings > 0
                      ? 'includes AI suggested RM ${formatRm(suggestedSavings)} micro-saving'
                      : 'AI is tracking your savings momentum',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      savings.length,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: savings[index] + 30,
                              decoration: BoxDecoration(
                                gradient: context.colors.warmGradient,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GradientCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.psychology_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI Recommendation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dashboardInsight,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Learning loop: accepted nudges, ignored warnings, savings wins, and Radar usage all refine tomorrow\'s recommendations.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.92),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
