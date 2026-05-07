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
    final insights = repo.loadInsights();
    final transactions = repo.loadTransactions().take(4).toList();
    final burnPoints = List.generate(
      14,
      (index) => FlSpot(index.toDouble(), 40 + index * 1.6 + (index.isEven ? 7 : 2)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good evening, Aiman',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Mochi is watching',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.auto_awesome_rounded, color: AppColors.ai, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => controller.setTab(7),
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(
                    children: [
                      const Center(child: Icon(Icons.notifications_none_rounded, size: 18)),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.risk,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GlassCard(
            gradient: const LinearGradient(colors: AppColors.aiGradient),
            radius: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available - GXBank',
                            style: TextStyle(fontSize: 12, color: Color(0xD9FFFFFF)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'RM 1,847.22',
                            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '+RM 124 saved this month',
                            style: TextStyle(fontSize: 11, color: Color(0xC7FFFFFF)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'RESILIENCE',
                          style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Color(0xB3FFFFFF)),
                        ),
                        SizedBox(height: 4),
                        Text('68', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                        Row(
                          children: [
                            Icon(Icons.trending_up_rounded, size: 12, color: AppColors.emerald),
                            SizedBox(width: 4),
                            Text('+6', style: TextStyle(fontSize: 11, color: AppColors.emerald)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: const [
                    Expanded(child: _MiniHeroStat(label: 'Vault', value: 'RM 312')),
                    SizedBox(width: 8),
                    Expanded(child: _MiniHeroStat(label: 'Streak', value: '14 day')),
                    SizedBox(width: 8),
                    Expanded(child: _MiniHeroStat(label: 'Decision', value: '82')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            strong: true,
            radius: 28,
            child: Row(
              children: [
                PixelCatWidget(
                  breed: profile.catBreed,
                  size: 68,
                  hat: profile.catHat,
                  glasses: profile.catGlasses,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mochi - Lvl 4',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '"You saved RM10 by skipping kopi today. Proud!"',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                        child: LinearProgressIndicator(
                          value: 0.62,
                          minHeight: 6,
                          backgroundColor: AppColors.surface,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '620 / 1000 XP to Lvl 5',
                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionTitle(
                  'Financial orchestrator',
                  trailing: Text(
                    'Live',
                    style: TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'The AI layer is coordinating your next best intervention based on spending velocity, time, location, and streak risk.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.45),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _SignalStat(label: 'Risk level', value: 'High', color: AppColors.risk)),
                    SizedBox(width: 8),
                    Expanded(child: _SignalStat(label: 'Best move', value: 'Save RM10', color: AppColors.emerald)),
                    SizedBox(width: 8),
                    Expanded(child: _SignalStat(label: 'Loop', value: 'Learning', color: AppColors.ai)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const AppSectionTitle(
            'AI insights',
            trailing: Text(
              'Updated 2 min ago',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: insights.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final card = insights[index];
                return GlassCard(
                  gradient: LinearGradient(colors: card.gradient),
                  radius: 28,
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 258,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                              width: 112,
                              height: 56,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  minY: 20,
                                  lineTouchData: const LineTouchData(enabled: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      isCurved: true,
                                      color: Colors.white,
                                      barWidth: 2.5,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.white.withValues(alpha: 0.2),
                                      ),
                                      spots: burnPoints.take(7).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              card.subtitle,
                              style: const TextStyle(
                                color: Color(0xD9FFFFFF),
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionTitle(
                  'Learning loop',
                  trailing: Text(
                    'Updated daily',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _LoopPill(label: 'Accepted nudges', value: '8')),
                    SizedBox(width: 8),
                    Expanded(child: _LoopPill(label: 'Ignored', value: '2')),
                    SizedBox(width: 8),
                    Expanded(child: _LoopPill(label: 'Radar wins', value: 'RM22')),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  'ThinkTwice is learning that food overspending spikes after 9:30 PM and that cheaper alternatives are most effective near Mid Valley.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_rounded,
                  label: 'Save Now',
                  gradient: AppColors.emeraldGradient,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickAction(
                  icon: Icons.radar_rounded,
                  label: 'Smart Radar',
                  gradient: AppColors.aiGradient,
                  onTap: () => controller.setTab(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickAction(
                  icon: Icons.psychology_rounded,
                  label: 'AI Coach',
                  gradient: AppColors.aiGradient,
                  onTap: () => controller.setTab(5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickAction(
                  icon: Icons.groups_rounded,
                  label: 'Squad',
                  gradient: AppColors.goldGradient,
                  onTap: () => controller.setTab(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const AppSectionTitle(
            'Live transactions',
            trailing: Text(
              'See all',
              style: TextStyle(fontSize: 12, color: AppColors.ai, fontWeight: FontWeight.w700),
            ),
          ),
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
        ],
      ),
    );
  }
}

class _MiniHeroStat extends StatelessWidget {
  const _MiniHeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Color(0xB3FFFFFF)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SignalStat extends StatelessWidget {
  const _SignalStat({
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

class _LoopPill extends StatelessWidget {
  const _LoopPill({
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
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        strong: true,
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
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
