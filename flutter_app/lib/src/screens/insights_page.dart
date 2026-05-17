import 'dart:math' as math;

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

  Color _categoryColor(BuildContext context, String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('food')) return context.colors.warning;
    if (normalized.contains('transport')) return context.colors.primary;
    if (normalized.contains('bill')) return context.colors.success;
    if (normalized.contains('shop')) return context.colors.accentForeground;
    if (normalized.contains('entertain')) return context.colors.accent;
    if (normalized.contains('income')) return context.colors.success;
    return context.colors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final aiResult = AiState.latestAiResult;
    final hasLiveInsights = aiResult != null;
    final smartTips = [
      'Small savings decisions add up over time.',
      'Tracking food spending helps improve your budget habits.',
      'Avoiding impulse spending helps maintain your streak.',
    ];

    final riskScore = aiResult?['riskAnalysis']?['riskScore'] ?? 35;
    final velocityScore =
        aiResult?['spendingVelocityAnalysis']?['velocityScore'] ?? 35;
    final suggestedSavings =
        aiResult?['intervention']?['suggestedSavingsAmount'] ?? 0;
    final riskLevel =
        aiResult != null ? AiService.extractRiskLevel(aiResult) : 'low';

    final spendingBehaviourMessage = switch (riskLevel) {
      'high' => "You've been spending more actively tonight.",
      'medium' => 'Your spending is slightly higher than usual.',
      _ => 'Your spending looks balanced today.',
    };

    final dashboardInsight = aiResult != null
        ? AiService.extractDashboardInsight(aiResult)
        : plan.recommendations.first;
    final resilienceScore =
        aiResult != null ? AiService.extractResilienceScore(aiResult) : 50;
    final smartTipIndex =
        (riskScore.round() + velocityScore.round() + transactions.length) %
            smartTips.length;
    final smartTip = smartTips[smartTipIndex];

    final spendingTransactions =
        transactions.where((tx) => tx.amount < 0).toList(growable: false);
    final recentSpending = spendingTransactions.take(7).toList(growable: false);
    final spendingPatternValues = (recentSpending.isNotEmpty
            ? recentSpending.reversed
                .map((tx) => tx.amount.abs())
                .toList(growable: false)
            : [plan.dailyLimit * 0.55, plan.dailyLimit * 0.72, plan.dailyLimit])
        .map((amount) => amount.clamp(6, plan.dailyLimit * 1.6).toDouble())
        .toList(growable: false);
    final maxSpendingPoint = spendingPatternValues.fold<double>(
      1,
      (max, value) => value > max ? value : max,
    );
    final trendHeights = spendingPatternValues
        .map((amount) => 28 + ((amount / maxSpendingPoint) * 82))
        .toList(growable: false);
    final trendLabels = recentSpending.isNotEmpty
        ? recentSpending.reversed
            .map((tx) => tx.timestampLabel)
            .toList(growable: false)
        : const ['Earlier', 'Midweek', 'Today'];

    final categoryBreakdown = aiResult?['riskAnalysis']?['categoryBreakdown']
        as Map<String, dynamic>?;
    final transactionCategoryTotals = <String, double>{};
    for (final transaction in spendingTransactions) {
      transactionCategoryTotals.update(
        transaction.category,
        (value) => value + transaction.amount.abs(),
        ifAbsent: () => transaction.amount.abs(),
      );
    }

    final liveCategoryRows = categoryBreakdown != null
        ? categoryBreakdown.entries.map((entry) {
            final amount = (entry.value as num).toDouble();
            final total = categoryBreakdown.values
                .map((v) => (v as num).toDouble())
                .fold<double>(0, (a, b) => a + b);
            final percent = total == 0 ? 0.0 : amount / total;
            return (entry.key, percent, amount);
          }).toList(growable: false)
        : transactionCategoryTotals.isNotEmpty
            ? (() {
                final total = transactionCategoryTotals.values.fold<double>(
                  0,
                  (sum, value) => sum + value,
                );
                final rows = transactionCategoryTotals.entries
                    .map((entry) {
                      final percent = total == 0 ? 0.0 : entry.value / total;
                      return (entry.key, percent, entry.value);
                    })
                    .toList();
                rows.sort((a, b) => b.$3.compareTo(a.$3));
                return rows;
              })()
            : null;

    final topAllocations = liveCategoryRows == null
        ? plan.allocations.take(3).toList(growable: false)
        : const <BudgetAllocation>[];
    final pieChartRows = liveCategoryRows != null
        ? liveCategoryRows
        : topAllocations
            .map((allocation) => (
                  allocation.name,
                  allocation.percent,
                  allocation.amount,
                ))
            .toList(growable: false);
    final pieChartTotal = pieChartRows.fold<double>(
      0,
      (sum, item) => sum + item.$3,
    );

    final recentSpendTotal = recentSpending.fold<double>(
      0,
      (sum, tx) => sum + tx.amount.abs(),
    );
    final targetSavingsTotal =
        (savingsPocket + suggestedSavings).clamp(0, goal > 0 ? goal : 1)
            .toDouble();
    final savingsBase = [
      targetSavingsTotal * 0.22,
      targetSavingsTotal * 0.36,
      targetSavingsTotal * 0.50,
      targetSavingsTotal * 0.68,
      targetSavingsTotal * 0.82,
      savingsPocket,
      savingsPocket + suggestedSavings,
    ].map((value) => value.toDouble()).toList(growable: false);
    final spendingSoftener = recentSpendTotal == 0
        ? 1.0
        : (1 - (recentSpendTotal / (goal + 1))).clamp(0.78, 1.0).toDouble();
    final savingsHeights = savingsBase
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final scaled = entry.value * (index < 5 ? spendingSoftener : 1.0);
          return (scaled.clamp(10, 90).toDouble()) + 12;
        })
        .toList(growable: false);
    final savingsLabels = const [
      'Week 1',
      'Week 2',
      'Week 3',
      'Week 4',
      'Week 5',
      'Now',
      'Next',
    ];

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
            'A quick look at your money patterns',
            style: TextStyle(
              fontSize: 14,
              color: context.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'What stands out',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          InsightCard(
            icon: Icons.warning_amber_rounded,
            tone: riskLevel == 'high' ? 'warning' : 'primary',
            title: "Today's Spending Behaviour",
            body: spendingBehaviourMessage,
          ),
          const SizedBox(height: 10),
          InsightCard(
            icon: Icons.psychology_alt_rounded,
            tone: 'primary',
            title: 'Smart Tip',
            body: smartTip,
          ),
          const SizedBox(height: 10),
          InsightCard(
            icon: Icons.track_changes_rounded,
            tone: 'primary',
            title: 'Financial Resilience Score',
            body: '$resilienceScore/100',
          ),
          const SizedBox(height: 14),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spending Pattern',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasLiveInsights
                      ? 'Hover or tap a bar to see the amount.'
                      : 'Based on your recent spending activity.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 156,
                  child: _InteractiveBarChart(
                    heights: trendHeights,
                    values: spendingPatternValues,
                    labels: trendLabels,
                    tooltipPrefix: 'Spent',
                    primaryColor: context.colors.primary,
                    mutedColor: context.colors.muted,
                    gradient: context.colors.primaryGradient,
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
                  'Weekly Spending Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hover or tap a slice to explore the mix.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                _InteractivePieChart(
                  items: pieChartRows
                      .map(
                        (allocation) => _PieChartDatum(
                          label: allocation.$1.toString(),
                          percent: pieChartTotal == 0
                              ? 0
                              : allocation.$3 / pieChartTotal,
                          amount: allocation.$3,
                          color: _categoryColor(
                            context,
                            allocation.$1.toString(),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 12),
                Text(
                  aiResult != null
                      ? 'This is where most of your money is going right now.'
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
                  'Savings Progress',
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
                      ? 'Hover or tap a bar to inspect savings progress.'
                      : 'A simple view of how your savings are building up.',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: _InteractiveBarChart(
                    heights: savingsHeights,
                    values: savingsBase,
                    labels: savingsLabels,
                    tooltipPrefix: 'Saved',
                    primaryColor: context.colors.success,
                    mutedColor: context.colors.muted,
                    gradient: context.colors.warmGradient,
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
                      'Next best step',
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
                  hasLiveInsights
                      ? 'This updates as your recent choices, nudges, and savings progress come in.'
                      : 'More personalised guidance will show up here as your activity builds.',
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

class _InteractiveBarChart extends StatefulWidget {
  const _InteractiveBarChart({
    required this.heights,
    required this.values,
    required this.labels,
    required this.tooltipPrefix,
    required this.primaryColor,
    required this.mutedColor,
    required this.gradient,
  });

  final List<double> heights;
  final List<double> values;
  final List<String> labels;
  final String tooltipPrefix;
  final Color primaryColor;
  final Color mutedColor;
  final Gradient gradient;

  @override
  State<_InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<_InteractiveBarChart> {
  int? _activeIndex;

  @override
  Widget build(BuildContext context) {
    final safeIndex = _activeIndex != null &&
            _activeIndex! >= 0 &&
            _activeIndex! < widget.values.length
        ? _activeIndex!
        : widget.values.isNotEmpty
            ? widget.values.length - 1
            : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                widget.labels[safeIndex],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.tooltipPrefix} RM ${formatRm(widget.values[safeIndex])}',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.heights.length, (index) {
              final isActive = index == safeIndex;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _activeIndex = index),
                    onExit: (_) => setState(() => _activeIndex = null),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        height: widget.heights[index],
                        decoration: BoxDecoration(
                          color: isActive ? null : widget.mutedColor,
                          gradient: isActive ? widget.gradient : null,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        widget.primaryColor.withOpacity(0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PieChartDatum {
  const _PieChartDatum({
    required this.label,
    required this.percent,
    required this.amount,
    required this.color,
  });

  final String label;
  final double percent;
  final double amount;
  final Color color;
}

class _InteractivePieChart extends StatefulWidget {
  const _InteractivePieChart({required this.items});

  final List<_PieChartDatum> items;

  @override
  State<_InteractivePieChart> createState() => _InteractivePieChartState();
}

class _InteractivePieChartState extends State<_InteractivePieChart> {
  int? _activeIndex;
  final GlobalKey _chartKey = GlobalKey();

  int _segmentIndexForPosition(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distanceSquared = (dx * dx) + (dy * dy);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.48;

    if (distanceSquared < innerRadius * innerRadius ||
        distanceSquared > outerRadius * outerRadius) {
      return -1;
    }

    final angle =
        (math.atan2(dy, dx) + (math.pi / 2) + (math.pi * 2)) % (math.pi * 2);
    var startAngle = 0.0;
    for (var i = 0; i < widget.items.length; i++) {
      final sweep = widget.items[i].percent * math.pi * 2;
      if (angle >= startAngle && angle < startAngle + sweep) {
        return i;
      }
      startAngle += sweep;
    }
    return widget.items.isEmpty ? -1 : widget.items.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final selectedIndex =
        _activeIndex != null && _activeIndex! < widget.items.length
            ? _activeIndex!
            : 0;
    final selected = widget.items[selectedIndex];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final chartSize = math.min(
                      constraints.maxWidth,
                      170.0,
                    );
                    final size = Size.square(chartSize);
                    return Center(
                      child: MouseRegion(
                        onExit: (_) => setState(() => _activeIndex = null),
                        onHover: (event) {
                          final box = _chartKey.currentContext?.findRenderObject()
                              as RenderBox?;
                          if (box == null) return;
                          final local = box.globalToLocal(event.position);
                          final index = _segmentIndexForPosition(local, size);
                          setState(() => _activeIndex = index >= 0 ? index : null);
                        },
                        child: GestureDetector(
                          onTapDown: (details) {
                            final index = _segmentIndexForPosition(
                              details.localPosition,
                              size,
                            );
                            setState(() => _activeIndex = index >= 0 ? index : null);
                          },
                          child: SizedBox(
                            key: _chartKey,
                            width: size.width,
                            height: size.height,
                            child: CustomPaint(
                              painter: _PieChartPainter(
                                items: widget.items,
                                activeIndex: _activeIndex,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${formatRm(selected.percent * 100)}%',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selected.label,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.colors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final isActive = index == selectedIndex;
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _activeIndex = index),
                      onExit: (_) => setState(() => _activeIndex = null),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? item.color.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? item.color.withOpacity(0.28)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                'RM ${formatRm(item.amount)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.mutedForeground,
                                ),
                              ),
                            ],
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
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                selected.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${formatRm(selected.percent * 100)}% | RM ${formatRm(selected.amount)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({
    required this.items,
    required this.activeIndex,
  });

  final List<_PieChartDatum> items;
  final int? activeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.48;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isActive = i == activeIndex;
      final segmentRadius = isActive ? radius : radius - 6;
      final rect = Rect.fromCircle(center: center, radius: segmentRadius);
      final sweep = item.percent * math.pi * 2;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    final cutoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, cutoutPaint);

    final outlinePaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 6, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.activeIndex != activeIndex;
  }
}
