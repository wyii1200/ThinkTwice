import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appStateProvider).profile;
    final appController = ref.read(appStateProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
              GlassCard(
                radius: 999,
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.settings_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            strong: true,
            radius: 30,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceStrong,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: PixelCatWidget(
                        breed: profile.catBreed,
                        size: 80,
                        hat: CatHat.crown,
                        glasses: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.school,
                            style: const TextStyle(fontSize: 12, color: AppColors.muted),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'LVL ${profile.level} - ${profile.rank.toUpperCase()}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _ProfileStat(label: 'Resilience', value: '${profile.resilience}')),
                    const SizedBox(width: 8),
                    Expanded(child: _ProfileStat(label: 'Streak', value: '${profile.streak} day')),
                    const SizedBox(width: 8),
                    Expanded(child: _ProfileStat(label: 'Badges', value: '${profile.badges}')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.28,
            children: [
              const _ProfileTile(icon: Icons.account_balance_wallet_rounded, label: 'GXBank Vaults', value: 'RM 457', gradient: AppColors.emeraldGradient),
              _ProfileTile(
                icon: Icons.bar_chart_rounded,
                label: 'Insights',
                value: '12 reports',
                gradient: AppColors.aiGradient,
                onTap: () => appController.setTab(6),
              ),
              const _ProfileTile(icon: Icons.workspace_premium_rounded, label: 'Resilience', value: 'Builder', gradient: AppColors.goldGradient),
              _ProfileTile(
                icon: Icons.track_changes_rounded,
                label: 'Goals',
                value: '3 active',
                gradient: AppColors.aiGradient,
                onTap: () => appController.setTab(3),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'JOURNEY',
            style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              children: const [
                _JourneyRow(emoji: '🎉', title: 'Joined ThinkTwice', date: 'Jan 2026'),
                SizedBox(height: 12),
                _JourneyRow(emoji: '💰', title: 'First RM100 saved', date: 'Feb 2026'),
                SizedBox(height: 12),
                _JourneyRow(emoji: '🔥', title: '30-day streak unlocked', date: 'Mar 2026'),
                SizedBox(height: 12),
                _JourneyRow(emoji: '🏗️', title: "Reached 'Builder' rank", date: 'May 2026'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    profile.spendingAlerts ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.muted,
                  ),
                  title: Text(profile.spendingAlerts ? 'Dark mode' : 'Light mode'),
                  trailing: Switch(
                    value: profile.spendingAlerts,
                    onChanged: appController.toggleAlerts,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.ai,
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                const ListTile(
                  leading: Icon(Icons.settings_outlined, color: AppColors.muted),
                  title: Text('Account & security'),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ),
                const Divider(height: 1, color: AppColors.border),
                const ListTile(
                  leading: Icon(Icons.workspace_premium_outlined, color: AppColors.muted),
                  title: Text('Achievements (9)'),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Sign out',
              style: TextStyle(color: AppColors.risk, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        strong: true,
        radius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const Spacer(),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({
    required this.emoji,
    required this.title,
    required this.date,
  });

  final String emoji;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(date, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}
