import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
import '../services/ai_service.dart';
import '../services/ai_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.budget,
    required this.goal,
    required this.plan,
    required this.totalPoints,
    required this.transactions,
    required this.breed,
    required this.expression,
    required this.accessory,
    required this.effect,
    required this.notificationsEnabled,
    required this.autoSaveEnabled,
    required this.onNotificationsChanged,
    required this.onAutoSaveChanged,
    required this.onSignOut,
  });

  final double budget;
  final double goal;
  final BudgetPlan plan;
  final int totalPoints;
  final List<TransactionRecord> transactions;
  final String breed;
  final String expression;
  final String accessory;
  final String effect;
  final bool notificationsEnabled;
  final bool autoSaveEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onAutoSaveChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final aiResult = AiState.latestAiResult;

    final resilienceScore =
        aiResult != null ? AiService.extractResilienceScore(aiResult) : 50;

    final smartScore =
        aiResult != null ? AiService.extractSmartDecisionScore(aiResult) : 50;

    final riskLevel =
        aiResult != null ? AiService.extractRiskLevel(aiResult) : 'low';

    final coachingMessage = aiResult != null
        ? AiService.extractCoachingMessage(aiResult)
        : 'Run Live AI Analysis to unlock your latest money habit update.';

    final liveTotalPoints = totalPoints + smartScore;
    final level = 1 + (liveTotalPoints ~/ 300);
    final rarity = _profileRarityLabel(accessory: accessory, effect: effect);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Pocket Buddy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        rarity,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Pocket Buddy',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your friendly money sidekick with unlocks, moods, and little reward moments along the way.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.06),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: avatarPreview(
                      context,
                      breed: breed,
                      accessory: accessory,
                      effect: effect,
                      mood: avatarMoodFromId(expression),
                      size: 172,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    PointsChip(totalPoints: liveTotalPoints),
                    _premiumChip(
                      Icons.shield_moon_rounded,
                      'Level $level',
                      Colors.white,
                    ),
                    _premiumChip(
                      Icons.pets_rounded,
                      catBreedLabel(breed),
                      Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pocket Buddy style',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${catBreedLabel(breed)} with ${formatAccessoryLabel(accessory)} and ${formatEffectLabel(effect)} gives ${pocketBuddyName()} its current look.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: Colors.white.withOpacity(0.94),
                        ),
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
                    Icon(
                      Icons.psychology_alt_rounded,
                      size: 18,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Spending Habits',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: progressStat(
                        context,
                        'Spending status',
                        friendlyRiskBadge(riskLevel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: progressStat(
                        context,
                        'Money Habit Score',
                        '$resilienceScore',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: progressStat(
                        context,
                        'Smart Spending',
                        '$smartScore',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: progressStat(
                        context,
                        'Auto-save',
                        autoSaveEnabled ? 'Enabled' : 'Off',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  coachingMessage,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: context.colors.mutedForeground,
                    fontWeight: FontWeight.w600,
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
                  'Where Your Money Went',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...transactions.map((item) {
                  final positive = item.amount > 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.colors.muted,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: context.colors.foreground,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.merchant,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item.category} • ${item.timestampLabel}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${positive ? '+' : '-'}RM${formatRm(item.amount.abs())}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: positive
                                ? context.colors.success
                                : context.colors.foreground,
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
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _settingsRow(
                  context,
                  Icons.account_balance_wallet_outlined,
                  'Budget settings',
                  'RM ${formatRm(budget)}/mo',
                  true,
                ),
                _settingsRow(
                  context,
                  Icons.track_changes_rounded,
                  'Savings goal',
                  'RM ${formatRm(goal)}',
                  true,
                ),
                _settingsRow(
                  context,
                  Icons.today_outlined,
                  'Safe daily spend',
                  'RM ${formatRm(plan.dailyLimit)}',
                  true,
                ),
                _toggleSettingsRow(
                  context,
                  Icons.notifications_none_rounded,
                  'Notifications',
                  notificationsEnabled,
                  onNotificationsChanged,
                ),
                _toggleSettingsRow(
                  context,
                  Icons.settings_outlined,
                  'Auto-save approval',
                  autoSaveEnabled,
                  onAutoSaveChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: context.colors.destructive,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Widget _premiumChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _profileRarityLabel({
    required String accessory,
    required String effect,
  }) {
    if (effect == 'floating_hearts' ||
        accessory == 'coin_clip' ||
        accessory == 'headphones') {
      return 'Legendary build';
    }

    if (effect == 'sparkle_aura' ||
        accessory == 'crown' ||
        accessory == 'halo') {
      return 'Epic build';
    }

    if (effect == 'glow_outline' ||
        accessory == 'flower' ||
        accessory == 'wizard_hat') {
      return 'Rare build';
    }

    return 'Core build';
  }

  Widget _settingsRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool divider,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 18,
                  color: context.colors.foreground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        if (divider) Divider(height: 1, color: Theme.of(context).dividerColor),
      ],
    );
  }

  Widget _toggleSettingsRow(
    BuildContext context,
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colors.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: context.colors.foreground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class AvatarCustomizationSheet extends StatefulWidget {
  const AvatarCustomizationSheet({
    super.key,
    required this.totalPoints,
    required this.rewardShopItems,
    required this.breed,
    required this.accessory,
    required this.effect,
  });

  final int totalPoints;
  final List<RewardShopItem> rewardShopItems;
  final String breed;
  final String accessory;
  final String effect;

  @override
  State<AvatarCustomizationSheet> createState() =>
      _AvatarCustomizationSheetState();
}

class _AvatarCustomizationSheetState extends State<AvatarCustomizationSheet> {
  late String _selectedBreed;
  late String _selectedAccessory;
  late String _selectedEffect;
  late int _pointsLeft;
  late Set<String> _ownedItemIds;
  final Set<String> _purchasedItemIds = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedBreed = widget.breed;
    _selectedAccessory = widget.accessory;
    _selectedEffect = widget.effect;
    _pointsLeft = widget.totalPoints;
    _ownedItemIds = widget.rewardShopItems
        .where((item) => item.owned)
        .map((item) => item.id)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final avatarItems = widget.rewardShopItems.toList();
    final ownedItems = widget.rewardShopItems
        .where((item) => _ownedItemIds.contains(item.id))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          24,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              )
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Avatar Creator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    PointsChip(totalPoints: _pointsLeft),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: avatarPreview(
                    context,
                    breed: _selectedBreed,
                    accessory: _selectedAccessory,
                    effect: _selectedEffect,
                    mood: AvatarMood.excited,
                    size: 132,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    '${catBreedLabel(_selectedBreed)} · ${formatAccessoryLabel(_selectedAccessory)} · ${formatEffectLabel(_selectedEffect)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.colors.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Owned collectibles',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ownedItems.map((item) {
                    final palette = rarityPalette(context, item.rarity);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: palette.$1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 16, color: palette.$2),
                          const SizedBox(width: 6),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: palette.$2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Breeds',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _shopGrid(
                  context,
                  avatarItems
                      .where((item) => item.category == 'breeds')
                      .toList(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Accessories',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.64,
                  children: [
                    _noneStateCard(
                      context,
                      label: 'No accessory',
                      selected: _selectedAccessory == 'none',
                      onTap: () => setState(() {
                        _selectedAccessory = 'none';
                      }),
                    ),
                    ...avatarItems
                        .where((item) => item.category == 'accessories')
                        .map((item) => _buildAvatarItemAction(context, item)),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Effects',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.64,
                  children: [
                    _noneStateCard(
                      context,
                      label: 'No effect',
                      selected: _selectedEffect == 'none',
                      onTap: () => setState(() {
                        _selectedEffect = 'none';
                      }),
                    ),
                    ...avatarItems
                        .where((item) => item.category == 'effects')
                        .map((item) => _buildAvatarItemAction(context, item)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(
                            AvatarCustomizationResult(
                              breed: _selectedBreed,
                              accessory: _selectedAccessory,
                              effect: _selectedEffect,
                              purchasedItemIds: _purchasedItemIds,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: context.colors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Save avatar',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shopGrid(BuildContext context, List<RewardShopItem> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.64,
      children:
          items.map((item) => _buildAvatarItemAction(context, item)).toList(),
    );
  }

  Widget _buildAvatarItemAction(BuildContext context, RewardShopItem item) {
    final owned = _ownedItemIds.contains(item.id);
    final canAfford = _pointsLeft >= item.price;
    final palette = rarityPalette(context, item.rarity);
    final selected = switch (item.category) {
      'breeds' => _selectedBreed == item.value,
      'accessories' => _selectedAccessory == item.value,
      'effects' => _selectedEffect == item.value,
      _ => false,
    };

    return WhiteCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.$1.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  formatRarityLabel(item.rarity),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: palette.$2,
                  ),
                ),
              ),
              if (selected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.success.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Equipped',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: context.colors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: RewardItemPreview(
              item: item,
              breed: _selectedBreed,
              equipped: selected,
              locked: !owned,
              size: 94,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            owned
                ? (selected ? 'Currently active' : 'Owned collectible')
                : '${item.price} pts',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: owned ? context.colors.success : context.colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: owned
                  ? () => setState(() {
                        _equip(item);
                      })
                  : canAfford
                      ? () => setState(() {
                            _pointsLeft -= item.price;
                            _ownedItemIds.add(item.id);
                            _purchasedItemIds.add(item.id);
                            _equip(item);
                          })
                      : null,
              style: FilledButton.styleFrom(
                backgroundColor: owned
                    ? (selected
                        ? context.colors.primary.withOpacity(0.15)
                        : context.colors.muted)
                    : palette.$1.withOpacity(0.18),
                foregroundColor: owned
                    ? (selected
                        ? context.colors.primary
                        : context.colors.foreground)
                    : palette.$2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                owned
                    ? (selected ? 'Equipped' : 'Equip')
                    : (canAfford ? 'Unlock' : 'Locked'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _equip(RewardShopItem item) {
    switch (item.category) {
      case 'breeds':
        _selectedBreed = item.value ?? _selectedBreed;
        break;
      case 'accessories':
        _selectedAccessory = item.value ?? _selectedAccessory;
        break;
      case 'effects':
        _selectedEffect = item.value ?? _selectedEffect;
        break;
    }
  }

  Widget _noneStateCard(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: context.colors.softMintGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? context.colors.primary : context.colors.muted,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  Icons.block_rounded,
                  size: 34,
                  color: selected
                      ? context.colors.primary
                      : context.colors.mutedForeground,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected
                    ? context.colors.primary
                    : context.colors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selected ? 'Equipped' : 'Use empty slot',
              style: TextStyle(
                fontSize: 11,
                color: context.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
