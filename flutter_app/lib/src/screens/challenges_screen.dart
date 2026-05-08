import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
class ChallengesPage extends StatefulWidget {
  const ChallengesPage({
    super.key,
    required this.totalPoints,
    required this.quests,
    required this.rewardShopItems,
    required this.breed,
    required this.color,
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
    required this.onClaimReward,
    required this.onRedeemItem,
    required this.onCustomizeAvatar,
  });

  final int totalPoints;
  final List<QuestProgress> quests;
  final List<RewardShopItem> rewardShopItems;
  final String breed;
  final String color;
  final String accessory;
  final String outfit;
  final String cosmetic;
  final ValueChanged<String> onClaimReward;
  final ValueChanged<String> onRedeemItem;
  final VoidCallback onCustomizeAvatar;

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  int _sectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final badgeIcons = [
      Icons.workspace_premium_rounded,
      Icons.local_fire_department_rounded,
      Icons.track_changes_rounded,
      Icons.diamond_rounded,
      Icons.emoji_events_rounded,
      Icons.star_rounded,
      Icons.park_rounded,
      Icons.lock_rounded,
    ];
    final squad = [
      (1, 'Mira', 1240, Icons.workspace_premium_rounded),
      (2, 'You', widget.totalPoints, Icons.pets_rounded),
      (3, 'Hafiz', 980, Icons.auto_awesome_rounded),
      (4, 'Lina', 760, Icons.favorite_rounded),
    ];
    final streakQuest = widget.quests.firstWhere(
      (quest) => quest.id == 'quest-savings-streak',
      orElse: () => const QuestProgress(
        id: 'fallback-streak',
        title: 'Current Save Streak',
        progress: 0,
        progressLabel: '0/7 days',
        rewardLabel: '+0 pts',
        rewardPoints: 0,
        isCompleted: false,
      ),
    );
    final currentSaveStreak = '${streakQuest.progressLabel.split('/').first} days';
    final level = 1 + (widget.totalPoints ~/ 300);
    final pointsIntoLevel = widget.totalPoints % 300;
    final pointsToNextLevel = 300 - pointsIntoLevel;
    final levelProgress = (pointsIntoLevel / 300).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Challenges', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Streaks, rewards, squads, and unlockables', style: TextStyle(fontSize: 14, color: context.colors.mutedForeground)),
          const SizedBox(height: 16),
          Center(
            child: avatarPreview(
              context,
              breed: widget.breed,
              color: widget.color,
              accessory: widget.accessory,
              outfit: widget.outfit,
              cosmetic: widget.cosmetic,
              size: 120,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientCard(
                  gradient: context.colors.warmGradient,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
                      const SizedBox(height: 8),
                      Text(currentSaveStreak, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Text('Current Save Streak', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                      const SizedBox(height: 8),
                      Text('${widget.totalPoints}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Text('Current points', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Streaks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: progressStat(context, 'Risk avoidance', currentSaveStreak)),
                    const SizedBox(width: 10),
                    Expanded(child: progressStat(context, 'Smart spending', '5 days')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Level progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('Level $level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: levelProgress,
                    minHeight: 10,
                    backgroundColor: context.colors.muted,
                    valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text('$pointsToNextLevel pts to the next level', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _questSectionToggle(context, 'Challenges', 0)),
              const SizedBox(width: 10),
              Expanded(child: _questSectionToggle(context, 'Rewards', 1)),
            ],
          ),
          const SizedBox(height: 16),
          if (_sectionIndex == 0) ...[
            const Text('Challenge cards', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...widget.quests.map((quest) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WhiteCard(
                    padding: const EdgeInsets.all(16),
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
                                  Row(
                                    children: [
                                      if (quest.isCompleted) Icon(Icons.check_circle_rounded, size: 16, color: context.colors.success),
                                      if (quest.isCompleted) const SizedBox(width: 6),
                                      Expanded(child: Text(quest.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(quest.progressLabel, style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: quest.isClaimed ? context.colors.success.withOpacity(0.18) : context.colors.accent.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                quest.isClaimed ? 'Claimed' : quest.rewardLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: quest.isClaimed ? context.colors.success : context.colors.accentForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: quest.progress,
                            minHeight: 8,
                            backgroundColor: context.colors.muted,
                            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
                          ),
                        ),
                        if (quest.isCompleted && !quest.isClaimed) ...[
                          const SizedBox(height: 12),
                          GradientButton(
                            text: 'Claim reward',
                            compact: true,
                            onPressed: () => widget.onClaimReward(quest.id),
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
          ] else ...[
            WhiteCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Rewards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      PointsChip(totalPoints: widget.totalPoints),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Redeem points for badges, avatar upgrades, and unlockables.', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                  const SizedBox(height: 14),
                  ...widget.rewardShopItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _rewardShopRow(
                          context,
                          item,
                          totalPoints: widget.totalPoints,
                          onRedeem: () => widget.onRedeemItem(item.id),
                        ),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 16, color: context.colors.primary),
                    const SizedBox(width: 8),
                    const Text('Badges', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: badgeIcons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final active = index < 5;
                    return Container(
                      decoration: BoxDecoration(
                        color: active ? context.colors.accent.withOpacity(0.3) : context.colors.muted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: active ? 1 : 0.4,
                        child: Icon(
                          badgeIcons[index],
                          size: 24,
                          color: active ? context.colors.accentForeground : context.colors.mutedForeground,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                avatarPreview(
                  context,
                  breed: widget.breed,
                  color: widget.color,
                  accessory: widget.accessory,
                  outfit: widget.outfit,
                  cosmetic: widget.cosmetic,
                  size: 92,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Avatar loadout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${formatAccessoryLabel(widget.accessory)} · ${widget.outfit}',
                        style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.cosmetic == 'none' ? 'No cosmetic equipped' : '${formatCosmeticLabel(widget.cosmetic)} equipped',
                        style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                      ),
                    ],
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
                    Icon(Icons.group_rounded, size: 16, color: context.colors.primary),
                    const SizedBox(width: 8),
                    const Text('Squad leaderboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...squad.map((item) {
                  final you = item.$2 == 'You';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: you ? context.colors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: context.colors.muted, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('${item.$1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Icon(item.$4, size: 20, color: context.colors.foreground),
                        const SizedBox(width: 10),
                        Expanded(child: Text(item.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                        Row(
                          children: [
                            Icon(Icons.emoji_events_rounded, size: 14, color: context.colors.primary),
                            const SizedBox(width: 4),
                            Text('${item.$3}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.primary)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.onCustomizeAvatar,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Customize avatar'),
          ),
        ],
      ),
    );
  }

  Widget _questSectionToggle(BuildContext context, String label, int index) {
    final active = _sectionIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _sectionIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? context.colors.primary.withOpacity(0.12) : context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? context.colors.primary : Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? context.colors.primary : context.colors.foreground,
          ),
        ),
      ),
    );
  }

  Widget _rewardShopRow(
    BuildContext context,
    RewardShopItem item, {
    required int totalPoints,
    required VoidCallback onRedeem,
  }) {
    final canAfford = totalPoints >= item.price;
    final unlocked = item.owned;

    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.accent.withOpacity(0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 22, color: context.colors.accentForeground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${formatShopCategory(item.category)} • ${unlocked ? 'Unlocked' : 'Locked'}',
                  style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(unlocked ? 'Owned' : '${item.price} pts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: unlocked ? context.colors.success : context.colors.primary)),
              const SizedBox(height: 6),
              if (!unlocked)
                SizedBox(
                  height: 32,
                  child: FilledButton.tonal(
                    onPressed: onRedeem,
                    style: FilledButton.styleFrom(
                      backgroundColor: canAfford ? context.colors.primary.withOpacity(0.12) : context.colors.muted,
                      foregroundColor: canAfford ? context.colors.primary : context.colors.mutedForeground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Redeem', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}




