import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(mockRepositoryProvider).loadTransactions();
    final pieData = [
      _PieDatum('Food', 220, AppColors.ai),
      _PieDatum('Shop', 140, AppColors.gold),
      _PieDatum('Transport', 88, AppColors.emerald),
      _PieDatum('Fun', 60, AppColors.risk),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Activity',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
              _IconButton(icon: Icons.search_rounded),
              const SizedBox(width: 8),
              _IconButton(icon: Icons.tune_rounded),
            ],
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 30,
            child: Row(
              children: [
                SizedBox(
                  width: 116,
                  height: 116,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 28,
                          sectionsSpace: 0,
                          borderData: FlBorderData(show: false),
                          sections: [
                            for (final item in pieData)
                              PieChartSectionData(
                                value: item.value.toDouble(),
                                color: item.color,
                                radius: 18,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('This week', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                          SizedBox(height: 4),
                          Text('RM508', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      for (final item in pieData) ...[
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item.label, style: const TextStyle(fontSize: 12))),
                            Text(
                              'RM${item.value}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterPill(label: 'All', active: true),
              _FilterPill(label: 'Income'),
              _FilterPill(label: 'Saves'),
              _FilterPill(label: 'Risk'),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'TODAY',
            style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  _TransactionListRow(transaction: transactions[i]),
                  if (i < 3) const Divider(height: 1, color: AppColors.border),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'YESTERDAY',
            style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 4; i < transactions.length; i++) ...[
                  _TransactionListRow(transaction: transactions[i]),
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

class _PieDatum {
  const _PieDatum(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 14,
      padding: const EdgeInsets.all(10),
      child: Icon(icon, size: 18),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: active ? const LinearGradient(colors: AppColors.aiGradient) : null,
        color: active ? null : AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: active ? Colors.white : AppColors.text,
        ),
      ),
    );
  }
}

class _TransactionListRow extends StatelessWidget {
  const _TransactionListRow({required this.transaction});

  final AppTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0;
    final iconGradient = transaction.isRisk
        ? AppColors.riskGradient
        : (isPositive ? AppColors.emeraldGradient : [AppColors.surfaceStrong, AppColors.surfaceStrong]);

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
            child: Icon(transaction.icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(transaction.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    if (transaction.isRisk) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.risk.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'RISK',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.risk),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.category} · ${transaction.time}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}RM${transaction.amount.abs().toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
