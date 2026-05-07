import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appStateProvider.notifier);
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final bars = List.generate(
      12,
      (i) => 50 + (i * 8) + ((i.isEven ? 1 : -1) * 20),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => controller.setTab(4),
            icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.muted),
            label: const Text('Back', style: TextStyle(color: AppColors.muted)),
          ),
          const Text(
            'Insights',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _MetricCard(label: 'Saved YTD', value: 'RM 1,240', delta: '+22%', tone: AppColors.emerald)),
              SizedBox(width: 10),
              Expanded(child: _MetricCard(label: 'Spent YTD', value: 'RM 9,847', delta: '-8%', tone: AppColors.ai)),
            ],
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionTitle(
                  'Savings growth',
                  trailing: Text(
                    '12 months',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 180,
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
                              return Text(
                                months[value.toInt()],
                                style: const TextStyle(fontSize: 9, color: AppColors.muted),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < bars.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: bars[i].toDouble(),
                                width: 14,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                color: i == 11 ? AppColors.emerald : const Color(0xFF323B52),
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
          GlassCard(
            gradient: const LinearGradient(colors: AppColors.aiGradient),
            radius: 30,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'YOUR MONEY PERSONALITY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xD9FFFFFF)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'The Mindful Strategist',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 10),
                Text(
                  "You spend with intent on coffee and books, but auto-save aggressively. You're 73% more disciplined than peers in your income bracket.",
                  style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xE6FFFFFF)),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _PersonaStat(label: 'Discipline', value: '86')),
                    SizedBox(width: 8),
                    Expanded(child: _PersonaStat(label: 'Frugality', value: '64')),
                    SizedBox(width: 8),
                    Expanded(child: _PersonaStat(label: 'Resilience', value: '72')),
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
              children: const [
                Text('Smart decision score', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 14),
                _ProgressRow(label: 'Skipped impulse buys', value: 14, max: 18),
                SizedBox(height: 10),
                _ProgressRow(label: 'Took cheaper alternative', value: 9, max: 12),
                SizedBox(height: 10),
                _ProgressRow(label: 'Auto-saved instead of spent', value: 22, max: 22),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            radius: 22,
            child: Row(
              children: [
                const Text('R', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly report ready', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('12 insights - 3 wins - 1 risk', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
                GradientButton(
                  label: 'View',
                  gradient: AppColors.aiGradient,
                  textColor: Colors.white,
                  onTap: _noop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.tone,
  });

  final String label;
  final String value;
  final String delta;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      strong: true,
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                delta.startsWith('+') ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 14,
                color: tone,
              ),
              const SizedBox(width: 6),
              Text(
                '$delta vs last year',
                style: TextStyle(fontSize: 11, color: tone, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonaStat extends StatelessWidget {
  const _PersonaStat({required this.label, required this.value});

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
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xD9FFFFFF))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.max,
  });

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
            Text('$value/$max', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value / max,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
          ),
        ),
      ],
    );
  }
}
