import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({super.key});

  @override
  ConsumerState<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends ConsumerState<GamificationScreen> {
  bool showShop = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(mockRepositoryProvider);
    final profile = ref.watch(appStateProvider).profile;
    final quests = repo.loadQuests();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quests',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          GlassCard(
            strong: true,
            radius: 30,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceStrong,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: PixelCatWidget(
                        breed: profile.catBreed,
                        size: 96,
                        hat: CatHat.crown,
                        glasses: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LEVEL 4',
                            style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                          ),
                          SizedBox(height: 6),
                          Text('Mochi the Disciplined', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.risk),
                              SizedBox(width: 4),
                              Text('14-day streak', style: TextStyle(fontSize: 12, color: AppColors.risk)),
                            ],
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
                          Text('620 / 1000 XP', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(child: _QuestHeroStat(label: 'Streak', value: '14🔥')),
                    SizedBox(width: 8),
                    Expanded(child: _QuestHeroStat(label: 'Badges', value: '9')),
                    SizedBox(width: 8),
                    Expanded(child: _QuestHeroStat(label: 'Coins', value: '2,840')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            radius: 22,
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => showShop = false),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: showShop ? null : const LinearGradient(colors: AppColors.aiGradient),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Weekly quests',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: showShop ? AppColors.muted : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => showShop = true),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: showShop ? const LinearGradient(colors: AppColors.aiGradient) : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Cat shop',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: showShop ? Colors.white : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!showShop) ...[
            for (final quest in quests) ...[
              GlassCard(
                strong: true,
                radius: 22,
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
                              Text(
                                quest.title,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quest.reward,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold),
                              ),
                            ],
                          ),
                        ),
                        if (quest.claimable)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: AppColors.goldGradient),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'CLAIM',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.background),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: quest.progress,
                        minHeight: 6,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          quest.progress == 1 ? AppColors.gold : AppColors.emerald,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quest.subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            const AppSectionTitle('Recent badges'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 0.78,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: const [
                _BadgeCard(emoji: '🏦', name: 'First Save', rarity: 'Common'),
                _BadgeCard(emoji: '🌙', name: 'Night Owl Slayer', rarity: 'Rare'),
                _BadgeCard(emoji: '🛒', name: 'Smart Shopper', rarity: 'Epic'),
                _BadgeCard(emoji: '👑', name: 'Discipline', rarity: 'Legendary'),
              ],
            ),
          ] else ...[
            const Text(
              'Spend coins to dress up Mochi.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: const [
                _ShopCard(name: 'Pixel Cap', rarity: 'Common', cost: '100', hat: CatHat.cap, breed: CatBreed.orangeTabby),
                _ShopCard(name: 'Crown', rarity: 'Legendary', cost: '1500', hat: CatHat.crown, breed: CatBreed.persian),
                _ShopCard(name: 'Glasses', rarity: 'Rare', cost: '400', glasses: true, breed: CatBreed.tuxedo),
                _ShopCard(name: 'Royal Set', rarity: 'Legendary', cost: 'LOCK', hat: CatHat.crown, glasses: true, breed: CatBreed.ragdoll),
                _ShopCard(name: 'Ninja', rarity: 'Epic', cost: 'LOCK', breed: CatBreed.tuxedo),
                _ShopCard(name: 'Sushi BG', rarity: 'Rare', cost: '350', breed: CatBreed.calico),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestHeroStat extends StatelessWidget {
  const _QuestHeroStat({required this.label, required this.value});

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

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.emoji,
    required this.name,
    required this.rarity,
  });

  final String emoji;
  final String name;
  final String rarity;

  @override
  Widget build(BuildContext context) {
    Color rarityColor;
    switch (rarity) {
      case 'Legendary':
        rarityColor = AppColors.gold;
      case 'Epic':
        rarityColor = AppColors.ai;
      case 'Rare':
        rarityColor = AppColors.emerald;
      default:
        rarityColor = AppColors.muted;
    }

    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            rarity,
            style: TextStyle(fontSize: 9, color: rarityColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.name,
    required this.rarity,
    required this.cost,
    required this.breed,
    this.hat = CatHat.none,
    this.glasses = false,
  });

  final String name;
  final String rarity;
  final String cost;
  final CatBreed breed;
  final CatHat hat;
  final bool glasses;

  @override
  Widget build(BuildContext context) {
    final locked = cost == 'LOCK';
    final rarityColor = switch (rarity) {
      'Legendary' => AppColors.gold,
      'Rare' => AppColors.ai,
      'Epic' => AppColors.risk,
      _ => AppColors.muted,
    };

    return GlassCard(
      strong: true,
      radius: 18,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: PixelCatWidget(
                breed: breed,
                size: 48,
                hat: hat,
                glasses: glasses,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(rarity, style: TextStyle(fontSize: 9, color: rarityColor, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              gradient: locked ? null : const LinearGradient(colors: AppColors.goldGradient),
              color: locked ? AppColors.surfaceStrong : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                locked ? 'LOCK' : '$cost 🪙',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: locked ? AppColors.muted : AppColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
