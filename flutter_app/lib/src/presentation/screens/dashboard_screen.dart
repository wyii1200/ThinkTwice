import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(mockRepositoryProvider);
    final profile = ref.watch(appStateProvider).profile;
    final controller = ref.read(appStateProvider.notifier);
    final nudges = ref.watch(appStateProvider).nudges.where((item) => !item.dismissed).toList();
    final tick = ref.watch(realtimeTickProvider).valueOrNull ?? 0;
    final transactions = repo.loadTransactions().take(4).toList();
    final liveBalance = 1847.22 + ((tick % 3) * 6.4);
    final dailyBudgetUsed = 42 + (tick % 4);
    final dailyBudgetTotal = 60;
    final monthlySavings = 312 + (tick * 3);
    final monthlySavingsTarget = 500;
    final resilienceScore = (profile.resilience + (tick % 4)).clamp(0, 100);
    final smartDecisionScore = 82 + (tick % 3);
    final streakDays = 7 + (tick % 2);
    final weeklyTrend = [
      38.0,
      42.0,
      36.0,
      44.0,
      40.0,
      34.0,
      29.0,
    ];
    final catState = switch (tick % 4) {
      0 => (
          emotion: 'Happy',
          room: 'Cozy savings room',
          dialogue: "You're doing great today.",
          accent: AppColors.emerald,
        ),
      1 => (
          emotion: 'Sleepy',
          room: 'Quiet recharge room',
          dialogue: 'No movement for a while. Ready for a small win?',
          accent: AppColors.gold,
        ),
      2 => (
          emotion: 'Worried',
          room: 'Alert mode room',
          dialogue: 'Careful... food spending is getting high.',
          accent: AppColors.risk,
        ),
      _ => (
          emotion: 'Excited',
          room: 'Streak celebration room',
          dialogue: 'Milestone reached. Your streak is glowing.',
          accent: AppColors.ai,
        ),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Home Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _SectionTitle(
            title: 'Top Status',
            trailing: _SyncBadge(
              label: switch (tick % 3) {
                0 => 'GXBank synced',
                1 => 'AI updated',
                _ => 'Live now',
              },
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            gradient: const LinearGradient(colors: AppColors.aiGradient),
            radius: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current GXBank balance',
                            style: TextStyle(fontSize: 12, color: Color(0xD9FFFFFF)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RM ${liveBalance.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Daily budget remaining: RM${(dailyBudgetTotal - dailyBudgetUsed).clamp(0, dailyBudgetTotal)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xD9FFFFFF)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Monthly savings progress: RM$monthlySavings / RM$monthlySavingsTarget',
                            style: const TextStyle(fontSize: 12, color: Color(0xC7FFFFFF)),
                          ),
                        ],
                      ),
                    ),
                    _ResilienceRing(score: resilienceScore),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _GlassStatPill(
                        label: 'Smart Decision',
                        value: '$smartDecisionScore',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GlassStatPill(
                        label: 'Streak',
                        value: '$streakDays days',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GlassCard(
                  radius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.local_fire_department_rounded, color: AppColors.risk, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '7-Day Smart Spending Streak',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Pixel Cat Companion'),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 30,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        catState.accent.withValues(alpha: 0.22),
                        AppColors.surfaceStrong,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: PixelCatWidget(
                            breed: profile.catBreed,
                            size: 82,
                            hat: profile.catHat,
                            glasses: profile.catGlasses,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile.catName} • ${catState.emotion}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              catState.room,
                              style: const TextStyle(fontSize: 12, color: AppColors.muted),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                catState.dialogue,
                                style: const TextStyle(fontSize: 12, height: 1.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'AI Insights'),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: AppColors.ai, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'At this rate, you may exceed your food budget in 2 days.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(child: _InsightStat(label: 'Risk level', value: 'High', color: AppColors.risk)),
                    SizedBox(width: 8),
                    Expanded(child: _InsightStat(label: 'Prediction', value: 'Overspend', color: AppColors.gold)),
                    SizedBox(width: 8),
                    Expanded(child: _InsightStat(label: 'Behavior', value: 'Late-night food', color: AppColors.ai)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 60,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 18),
                            const FlSpot(1, 26),
                            const FlSpot(2, 22),
                            const FlSpot(3, 35),
                            const FlSpot(4, 44),
                            const FlSpot(5, 48),
                            const FlSpot(6, 54),
                          ],
                          isCurved: true,
                          color: AppColors.risk,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.risk.withValues(alpha: 0.14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Suggested action: Save RM10 now to maintain your streak.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Quick Actions'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.98,
            children: [
              _ActionTile(
                icon: Icons.savings_rounded,
                label: 'Save RM10 Now',
                gradient: AppColors.emeraldGradient,
                onTap: () => controller.setTab(7),
              ),
              _ActionTile(
                icon: Icons.radar_rounded,
                label: 'Open Smart Radar',
                gradient: AppColors.aiGradient,
                onTap: () => controller.setTab(2),
              ),
              _ActionTile(
                icon: Icons.receipt_long_rounded,
                label: 'View Transactions',
                gradient: AppColors.aiGradient,
                onTap: () => controller.setTab(1),
              ),
              _ActionTile(
                icon: Icons.psychology_rounded,
                label: 'Open AI Coach',
                gradient: AppColors.aiGradient,
                onTap: () => controller.setTab(5),
              ),
              _ActionTile(
                icon: Icons.emoji_events_rounded,
                label: 'View Challenges',
                gradient: AppColors.goldGradient,
                onTap: () => controller.setTab(3),
              ),
              _ActionTile(
                icon: Icons.groups_rounded,
                label: 'Open Squad',
                gradient: AppColors.goldGradient,
                onTap: () => controller.setTab(3),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Daily Progress'),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressMetric(
                  label: 'Daily spending progress',
                  valueLabel: 'RM$dailyBudgetUsed / RM$dailyBudgetTotal',
                  progress: dailyBudgetUsed / dailyBudgetTotal,
                  color: AppColors.ai,
                ),
                const SizedBox(height: 14),
                _ProgressMetric(
                  label: 'Savings target progress',
                  valueLabel: 'RM$monthlySavings / RM$monthlySavingsTarget',
                  progress: monthlySavings / monthlySavingsTarget,
                  color: AppColors.emerald,
                ),
                const SizedBox(height: 14),
                _ProgressMetric(
                  label: 'Budget utilization',
                  valueLabel: '${((dailyBudgetUsed / dailyBudgetTotal) * 100).round()}%',
                  progress: dailyBudgetUsed / dailyBudgetTotal,
                  color: AppColors.gold,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Weekly spending trend',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              return Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 9, color: AppColors.muted),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < weeklyTrend.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: weeklyTrend[i],
                                width: 14,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                color: i == weeklyTrend.length - 1 ? AppColors.emerald : const Color(0xFF3A445C),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Gamification'),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Expanded(child: _GameStat(label: 'XP today', value: '+25')),
                    SizedBox(width: 8),
                    Expanded(child: _GameStat(label: 'Current level', value: 'Lvl 4')),
                    SizedBox(width: 8),
                    Expanded(child: _GameStat(label: 'Rewards', value: '3 waiting')),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  'Mission: Avoid impulse spending today',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Rewards preview: Crown upgrade, 120 coins, and a rare room light.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _BadgePreview(label: 'Saver')),
                    SizedBox(width: 8),
                    Expanded(child: _BadgePreview(label: 'Radar Pro')),
                    SizedBox(width: 8),
                    Expanded(child: _BadgePreview(label: 'Streaker')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Smart Savings Radar Preview'),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.ai.withValues(alpha: 0.18),
                        AppColors.emerald.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: const [
                      Positioned(
                        left: 26,
                        top: 38,
                        child: _MapPin(),
                      ),
                      Positioned(
                        right: 42,
                        top: 24,
                        child: _MapPin(),
                      ),
                      Positioned(
                        right: 68,
                        bottom: 26,
                        child: _MapPin(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Nearby Deal: RM5 Lunch @ UM Campus',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Potential savings today: RM14',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Cheapest route shortcut',
                  gradient: AppColors.emeraldGradient,
                  onTap: () => controller.setTab(2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Squad / Social'),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Your squad saved RM250 this week',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12),
                _SquadRow(name: 'Aiman', detail: '7-day streak', rank: '#1'),
                SizedBox(height: 10),
                _SquadRow(name: 'Sara', detail: 'Saved RM84 today', rank: '#2'),
                SizedBox(height: 10),
                _SquadRow(name: 'Irfan', detail: 'Hit resilience 69', rank: '#3'),
                SizedBox(height: 12),
                Text(
                  'Community update: UM squad just unlocked the Smart Saver badge.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Live Transaction Feed'),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < transactions.length; i++) ...[
                  _TransactionRow(transaction: transactions[i]),
                  if (i < transactions.length - 1)
                    const Divider(height: 1, color: AppColors.border),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Real-Time Alerts'),
          const SizedBox(height: 10),
          if (nudges.isEmpty)
            GlassCard(
              strong: true,
              radius: 28,
              child: const Text(
                'No active interventions right now.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < nudges.take(2).length; i++) ...[
                  _AlertCard(
                    title: nudges[i].title,
                    message: nudges[i].message,
                    riskLevel: nudges[i].riskLevel,
                    onTap: () => controller.setTab(7),
                  ),
                  if (i < nudges.take(2).length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ResilienceRing extends StatelessWidget {
  const _ResilienceRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 9,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'RES',
                  style: TextStyle(fontSize: 10, color: Color(0xD9FFFFFF)),
                ),
                Text(
                  '$score',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassStatPill extends StatelessWidget {
  const _GlassStatPill({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xD9FFFFFF)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _InsightStat extends StatelessWidget {
  const _InsightStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: GlassCard(
        strong: true,
        radius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.valueLabel,
    required this.progress,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              valueLabel,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _GameStat extends StatelessWidget {
  const _GameStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _BadgePreview extends StatelessWidget {
  const _BadgePreview({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: AppColors.emerald,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SquadRow extends StatelessWidget {
  const _SquadRow({
    required this.name,
    required this.detail,
    required this.rank,
  });

  final String name;
  final String detail;
  final String rank;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceStrong,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.characters.first,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(detail, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
        Text(rank, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ai)),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.message,
    required this.riskLevel,
    required this.onTap,
  });

  final String title;
  final String message;
  final String riskLevel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (riskLevel) {
      'High' => AppColors.risk,
      'Medium' => AppColors.gold,
      _ => AppColors.ai,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceStrong.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.16),
              blurRadius: 22,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notifications_active_rounded, color: borderColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final AppTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0;
    final iconGradient = isPositive
        ? AppColors.emeraldGradient
        : (transaction.isRisk ? AppColors.riskGradient : [AppColors.surfaceStrong, AppColors.surfaceStrong]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: iconGradient),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(transaction.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.category} - ${transaction.time}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}RM${transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isPositive
                  ? AppColors.emerald
                  : transaction.isRisk
                      ? AppColors.risk
                      : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
