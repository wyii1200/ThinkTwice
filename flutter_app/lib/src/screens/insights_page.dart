import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
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
    final trend = [40, 55, 38, 62, 45, 70, 48, 30, 52, 60, 35, 42];
    final savings = [10, 25, 18, 35, 42, 50, 47];
    final foodAllocation = plan.allocations.firstWhere((item) => item.name == 'Food & drinks');
    final topAllocations = plan.allocations.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Insights', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Your AI financial intelligence', style: TextStyle(fontSize: 14, color: context.colors.mutedForeground)),
          const SizedBox(height: 16),
          const Text('Personalized insights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...[
            (Icons.schedule_rounded, true, 'You overspend most after 10PM', '62% of impulse purchases happen late at night.'),
            (
              Icons.trending_up_rounded,
              true,
              'Food budget rebalanced to ${formatRm(foodAllocation.percent * 100)}%',
              'If food keeps trending high, ThinkTwice can tighten lifestyle categories before it touches your essentials.',
            ),
            (
              Icons.track_changes_rounded,
              false,
              'Safe daily spend is RM ${formatRm(plan.dailyLimit)}',
              'You\'re on track to save RM ${formatRm(goal)} with an auto-protected monthly savings bucket of RM ${formatRm(plan.savingsAmount)}.',
            ),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InsightCard(
                  icon: item.$1,
                  tone: item.$2 ? 'warning' : 'primary',
                  title: item.$3,
                  body: item.$4,
                ),
              )),
          const SizedBox(height: 8),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Spending trend (12 weeks)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 128,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(trend.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            height: trend[index].toDouble(),
                            decoration: BoxDecoration(
                              color: index == trend.length - 1 ? null : context.colors.muted,
                              gradient: index == trend.length - 1 ? context.colors.primaryGradient : null,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      );
                    }),
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
                const Text('Category distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...topAllocations.map((allocation) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(allocation.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              '${formatRm(allocation.percent * 100)}% | RM ${formatRm(allocation.amount)}',
                              style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
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
                            valueColor: AlwaysStoppedAnimation<Color>(allocation.color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Text(
                  plan.recommendations.last,
                  style: TextStyle(fontSize: 12, height: 1.35, color: context.colors.mutedForeground),
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
                const Text('Savings momentum', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('+RM ${savingsPocket.toStringAsFixed(0)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: context.colors.success)),
                Text('vs last week', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(savings.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                            height: savings[index] + 30,
                            decoration: BoxDecoration(
                              gradient: context.colors.warmGradient,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      );
                    }),
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
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: context.colors.accentForeground),
                    const SizedBox(width: 8),
                    const Text('Risk alert history', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...(nudgeHistory.isNotEmpty
                    ? nudgeHistory.take(3).map((n) {
                        final status = n['status'] as String? ?? 'sent';
                        final nudgeText = n['nudgeText'] as String? ?? 'AI intervention triggered';
                        final riskLevel = n['riskLevel'] as String? ?? 'low';
                        return (
                          'Recently',
                          nudgeText,
                          riskLevel == 'high'
                              ? context.colors.warning
                              : status == 'accepted'
                                  ? context.colors.success
                                  : context.colors.warning,
                        );
      }).toList()
    : [
        ('Today', 'High food spending risk', context.colors.warning),
        ('Yesterday', 'Late-night impulse buy avoided', context.colors.success),
        ('2 days ago', 'Budget threshold crossed', context.colors.warning),
      ]
).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(width: 2, height: 34, color: item.$3),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text(item.$1, style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
                    Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('AI Recommendation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  aiInsights.isNotEmpty ? aiInsights.first : plan.recommendations.first,
                  style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.45),
                ),
                const SizedBox(height: 12),
                Text(
                  'Learning loop: accepted nudges, ignored warnings, savings wins, and Radar usage all refine tomorrow\'s recommendations.',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.92), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







