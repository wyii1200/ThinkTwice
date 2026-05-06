import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appStateProvider.notifier);
    final points = List.generate(
      7,
      (i) => FlSpot(i.toDouble(), [22, 31, 18, 45, 52, 38, 28][i].toDouble()),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => controller.setTab(0),
            icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.muted),
            label: const Text('Back', style: TextStyle(color: AppColors.muted)),
          ),
          const Text(
            'AI Coach',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.ai),
              SizedBox(width: 6),
              Text(
                'Confidence 94%',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GlassCard(
            gradient: const LinearGradient(colors: AppColors.riskGradient),
            radius: 30,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'OVERSPEND PREDICTION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xD9FFFFFF)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'At this spending rate, you may exceed your weekly budget in 2 days.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _CoachMiniStat(label: 'Burn rate', value: 'RM34/d')),
                    SizedBox(width: 8),
                    Expanded(child: _CoachMiniStat(label: 'Budget left', value: 'RM78')),
                    SizedBox(width: 8),
                    Expanded(child: _CoachMiniStat(label: 'Days left', value: '4')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionTitle(
                  'Daily burn rate',
                  trailing: Text(
                    'Last 7 days',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 60,
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
                                style: const TextStyle(fontSize: 10, color: AppColors.muted),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: const LineTouchData(enabled: false),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 45,
                            color: AppColors.emerald,
                            dashArray: [6, 4],
                          ),
                        ],
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points,
                          isCurved: true,
                          color: AppColors.ai,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.ai.withValues(alpha: 0.42),
                                AppColors.ai.withValues(alpha: 0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
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
          const SizedBox(height: 18),
          const AppSectionTitle('Coach chat'),
          const SizedBox(height: 10),
          const _ChatBubble(
            fromCoach: true,
            text: 'I spotted a late-night spending pattern around Mid Valley. Want a safer plan for tonight?',
          ),
          const SizedBox(height: 10),
          const _ChatBubble(
            fromCoach: false,
            text: 'Yes, but keep it realistic. I still want coffee.',
          ),
          const SizedBox(height: 10),
          const _ChatBubble(
            fromCoach: true,
            text: 'Switch Starbucks to Zus and skip one Grab ride. That keeps RM13 in your budget and protects your streak.',
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: const [
              _RiskTile(icon: Icons.dark_mode_rounded, label: 'Late-night spending', value: '3 / 7 days', color: AppColors.risk),
              _RiskTile(icon: Icons.place_rounded, label: 'Mid Valley risk zone', value: 'RM 95 spent', color: AppColors.risk),
              _RiskTile(icon: Icons.local_fire_department_rounded, label: 'Streak risk', value: 'Low', color: AppColors.emerald),
              _RiskTile(icon: Icons.warning_amber_rounded, label: 'Subscription leak', value: 'RM 14.90', color: AppColors.gold),
            ],
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suggested action',
                  style: TextStyle(fontSize: 11, letterSpacing: 1.2, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reduce RM10 spending today to maintain your savings goal.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Take action',
                        gradient: AppColors.emeraldGradient,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GlassCard(
                        radius: 22,
                        strong: true,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            'Snooze',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionTitle(
                  'Spending heatmap',
                  trailing: Text(
                    'By time of day',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(42, (index) {
                    final intensity = (math.sin(index * 0.45) + 1) / 2;
                    return Container(
                      width: 38,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.risk.withValues(alpha: intensity * 0.75 + 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachMiniStat extends StatelessWidget {
  const _CoachMiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xB3FFFFFF))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.fromCoach,
    required this.text,
  });

  final bool fromCoach;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromCoach ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: fromCoach
              ? const LinearGradient(colors: AppColors.aiGradient)
              : null,
          color: fromCoach ? null : AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: fromCoach ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
