import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.budget,
    required this.goal,
    required this.plan,
    required this.totalPoints,
    required this.transactions,
    required this.breed,
    required this.color,
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
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
  final String color;
  final String accessory;
  final String outfit;
  final String cosmetic;
  final bool notificationsEnabled;
  final bool autoSaveEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onAutoSaveChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final level = 1 + (totalPoints ~/ 300);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientCard(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -24,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 30, spreadRadius: 18)],
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatarPreview(
                      context,
                      breed: breed,
                      color: color,
                      accessory: accessory,
                      outfit: outfit,
                      cosmetic: cosmetic,
                      mood: AvatarMood.proud,
                      size: 96,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wallet Guardian', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Level $level collectible companion', style: const TextStyle(fontSize: 12, color: Colors.white)),
                          const SizedBox(height: 8),
                          PointsChip(totalPoints: totalPoints),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              'Cozy fintech familiar with $outfit styling, ${formatAccessoryLabel(accessory).toLowerCase()} flair, and ${formatCosmeticLabel(cosmetic).toLowerCase()}.',
                              style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                const Text('Recent transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
                          decoration: BoxDecoration(color: context.colors.muted, borderRadius: BorderRadius.circular(16)),
                          alignment: Alignment.center,
                          child: Icon(item.icon, size: 20, color: context.colors.foreground),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.merchant, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('${item.category} • ${item.timestampLabel}', style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
                            ],
                          ),
                        ),
                        Text(
                          '${positive ? '+' : '-'}RM${formatRm(item.amount.abs())}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: positive ? context.colors.success : context.colors.foreground,
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
                _settingsRow(context, Icons.account_balance_wallet_outlined, 'Budget settings', 'RM ${formatRm(budget)}/mo', true),
                _settingsRow(context, Icons.track_changes_rounded, 'Savings goal', 'RM ${formatRm(goal)}', true),
                _settingsRow(context, Icons.today_outlined, 'Safe daily spend', 'RM ${formatRm(plan.dailyLimit)}', true),
                _toggleSettingsRow(context, Icons.notifications_none_rounded, 'Notifications', notificationsEnabled, onNotificationsChanged),
                _toggleSettingsRow(context, Icons.settings_outlined, 'Auto-save approval', autoSaveEnabled, onAutoSaveChanged),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: context.colors.destructive,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(BuildContext context, IconData icon, String label, String value, bool divider) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: context.colors.muted, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18, color: context.colors.foreground),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                Text(value, style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 18, color: context.colors.mutedForeground),
              ],
            ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: context.colors.muted, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: context.colors.foreground),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              Switch.adaptive(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ],
    );
  }
}

class AvatarCustomizationSheet extends StatefulWidget {
  const AvatarCustomizationSheet({
    super.key,
    required this.totalPoints,
    required this.rewardShopItems,
    required this.breed,
    required this.color,
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
  });

  final int totalPoints;
  final List<RewardShopItem> rewardShopItems;
  final String breed;
  final String color;
  final String accessory;
  final String outfit;
  final String cosmetic;

  @override
  State<AvatarCustomizationSheet> createState() => _AvatarCustomizationSheetState();
}

class _AvatarCustomizationSheetState extends State<AvatarCustomizationSheet> {
  late String _selectedAccessory;
  late String _selectedOutfit;
  late String _selectedCosmetic;
  late int _pointsLeft;
  late Set<String> _ownedItemIds;
  final Set<String> _purchasedItemIds = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedAccessory = widget.accessory;
    _selectedOutfit = widget.outfit;
    _selectedCosmetic = widget.cosmetic;
    _pointsLeft = widget.totalPoints;
    _ownedItemIds = widget.rewardShopItems.where((item) => item.owned).map((item) => item.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final avatarItems = widget.rewardShopItems.where((item) => item.category != 'badge').toList();
    final ownedItems = widget.rewardShopItems.where((item) => _ownedItemIds.contains(item.id)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 28, offset: const Offset(0, 14))],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Customize Avatar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                    PointsChip(totalPoints: _pointsLeft),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: avatarPreview(
                    context,
                    breed: widget.breed,
                    color: widget.color,
                    accessory: _selectedAccessory,
                    outfit: _selectedOutfit,
                    cosmetic: _selectedCosmetic,
                    mood: AvatarMood.excited,
                    size: 132,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    '${formatAccessoryLabel(_selectedAccessory)} · $_selectedOutfit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.mutedForeground),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Owned items', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ownedItems
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: rarityPalette(context, item.rarity).$1.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, size: 16, color: rarityPalette(context, item.rarity).$2),
                              const SizedBox(width: 6),
                              Text(item.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: rarityPalette(context, item.rarity).$2)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                const Text('Accessories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.74,
                  children: [
                    _noneStateCard(context, label: 'No accessory', selected: _selectedAccessory == 'none', onTap: () => setState(() => _selectedAccessory = 'none')),
                    ...avatarItems.where((item) => item.category == 'accessory').map((item) => _buildAvatarItemAction(context, item)),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Outfits', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.74,
                  children: avatarItems.where((item) => item.category == 'outfit').map((item) => _buildAvatarItemAction(context, item)).toList(),
                ),
                const SizedBox(height: 18),
                const Text('Cosmetics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.74,
                  children: [
                    _noneStateCard(context, label: 'No cosmetic', selected: _selectedCosmetic == 'none', onTap: () => setState(() => _selectedCosmetic = 'none')),
                    ...avatarItems.where((item) => item.category == 'cosmetic').map((item) => _buildAvatarItemAction(context, item)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientButton(
                        text: 'Save look',
                        icon: Icons.check_rounded,
                        onPressed: () {
                          Navigator.of(context).pop(
                            AvatarCustomizationResult(
                              accessory: _selectedAccessory,
                              outfit: _selectedOutfit,
                              cosmetic: _selectedCosmetic,
                              purchasedItemIds: _purchasedItemIds,
                            ),
                          );
                        },
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

  Widget _buildAvatarItemAction(BuildContext context, RewardShopItem item) {
    final owned = _ownedItemIds.contains(item.id);
    final canAfford = _pointsLeft >= item.price;
    final palette = rarityPalette(context, item.rarity);
    final selected = switch (item.category) {
      'accessory' => _selectedAccessory == item.value,
      'outfit' => _selectedOutfit == item.value,
      'cosmetic' => _selectedCosmetic == item.value,
      _ => false,
    };

    return SizedBox(
      child: WhiteCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.$1.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    formatRarityLabel(item.rarity),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: palette.$2),
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.success.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Equipped',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.colors.success),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: RewardItemPreview(
                item: item,
                equipped: selected,
                locked: !owned,
                size: 100,
              ),
            ),
            const SizedBox(height: 10),
            Text(item.name, textAlign: TextAlign.left, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              owned ? (selected ? 'Living on your Guardian' : 'Owned collectible') : '${item.price} pts',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: owned ? context.colors.success : context.colors.primary),
            ),
            const SizedBox(height: 8),
            if (owned)
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => setState(() {
                    switch (item.category) {
                      case 'accessory':
                        _selectedAccessory = item.value!;
                        break;
                      case 'outfit':
                        _selectedOutfit = item.value!;
                        break;
                      case 'cosmetic':
                        _selectedCosmetic = item.value!;
                        break;
                    }
                  }),
                  style: FilledButton.styleFrom(
                    backgroundColor: selected ? context.colors.primary.withOpacity(0.15) : context.colors.muted,
                    foregroundColor: selected ? context.colors.primary : context.colors.foreground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(selected ? 'Equipped' : 'Equip', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: canAfford
                      ? () => setState(() {
                            _pointsLeft -= item.price;
                            _ownedItemIds.add(item.id);
                            _purchasedItemIds.add(item.id);
                            switch (item.category) {
                              case 'accessory':
                                _selectedAccessory = item.value!;
                                break;
                              case 'outfit':
                                _selectedOutfit = item.value!;
                                break;
                              case 'cosmetic':
                                _selectedCosmetic = item.value!;
                                break;
                            }
                          })
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: canAfford ? palette.$1.withOpacity(0.18) : context.colors.muted,
                    foregroundColor: canAfford ? palette.$2 : context.colors.mutedForeground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(canAfford ? 'Unlock' : 'Locked', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _noneStateCard(BuildContext context, {required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: context.colors.softMintGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? context.colors.primary : context.colors.muted),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(Icons.block_rounded, size: 34, color: selected ? context.colors.primary : context.colors.mutedForeground),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: selected ? context.colors.primary : context.colors.foreground),
            ),
            const SizedBox(height: 4),
            Text(
              selected ? 'Equipped' : 'Use empty slot',
              style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}






