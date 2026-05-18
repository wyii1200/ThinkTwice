import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'app_theme.dart';
import 'models.dart';
String formatRm(num value, {int decimals = 0}) {
  return decimals == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(decimals);
}

const LatLng kDefaultRadarCenter = LatLng(3.1390, 101.6869);

List<CommunityDeal> seedDeals() {
  return [
    CommunityDeal(
      id: 'deal-1',
      title: 'RM5 Nasi Lemak',
      storeName: 'Kak Yan Stall',
      category: 'Food & drinks',
      description: 'Breakfast promo before 10AM. Includes sambal and egg.',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      latitude: 3.1412,
      longitude: 101.6892,
      originalPrice: 12,
      dealPrice: 5,
      discountLabel: 'Save RM7',
      upvotes: 42,
      verifications: 9,
      submittedBy: 'user_123',
      address: '123 Main Street', 
    ),
    CommunityDeal(
      id: 'deal-2',
      title: '20% Off Coffee',
      storeName: 'ZUS Coffee',
      category: 'Food & drinks',
      description: 'Valid for one hot or iced coffee in-app pickup orders.',
      expiryDate: DateTime.now().add(const Duration(days: 1)),
      latitude: 3.1378,
      longitude: 101.6927,
      originalPrice: 15,
      dealPrice: 12,
      discountLabel: 'Save RM3',
      upvotes: 28,
      verifications: 6,
      submittedBy: 'user_123',
      address: '123 Main Street',
    ),
    CommunityDeal(
      id: 'deal-3',
      title: 'Buy 1 Free 1 Bread',
      storeName: 'FamilyMart',
      category: 'Groceries',
      description: 'Selected bakery shelf items only, while stocks last.',
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      latitude: 3.1349,
      longitude: 101.6845,
      originalPrice: 8,
      dealPrice: 4,
      discountLabel: 'Save RM4',
      upvotes: 19,
      verifications: 4,
      submittedBy: 'user_123',
      address: '456 Market Road',
    ),
  ];
}

List<QuestProgress> seedQuests() {
  return const [
    QuestProgress(
      id: 'quest-no-overspending',
      title: '3-Day No Overspending',
      progress: 0.66,
      progressLabel: '2/3 days',
      rewardLabel: '+150 pts',
      rewardPoints: 150,
      isCompleted: false,
    ),
    QuestProgress(
      id: 'quest-savings-streak',
      title: '7-Day Savings Streak',
      progress: 1,
      progressLabel: '7/7 days',
      rewardLabel: '+50 pts',
      rewardPoints: 50,
      isCompleted: true,
    ),
    QuestProgress(
      id: 'quest-food-budget',
      title: 'Food Budget Challenge',
      progress: 0.4,
      progressLabel: 'RM80 / RM200',
      rewardLabel: 'Wizard hat',
      rewardPoints: 80,
      isCompleted: false,
    ),
  ];
}

List<RewardShopItem> seedRewardShopItems() {
  return const [
    RewardShopItem(
      id: 'accessory-ribbon',
      name: 'Mint Ribbon',
      price: 0,
      icon: Icons.sell_rounded,
      category: 'accessories',
      rarity: 'common',
      value: 'ribbon',
      owned: true,
    ),
    RewardShopItem(
      id: 'breed-siamese',
      name: 'Siamese',
      price: 0,
      icon: Icons.pets_rounded,
      category: 'breeds',
      rarity: 'common',
      value: 'siamese',
      owned: true,
    ),
    RewardShopItem(
      id: 'accessory-crown',
      name: 'Crown',
      price: 200,
      icon: Icons.workspace_premium_rounded,
      category: 'accessories',
      rarity: 'epic',
      value: 'crown',
    ),
    RewardShopItem(
      id: 'accessory-glasses',
      name: 'Smart Glasses',
      price: 140,
      icon: Icons.visibility_rounded,
      category: 'accessories',
      rarity: 'common',
      value: 'glasses',
      owned: true,
    ),
    RewardShopItem(
      id: 'accessory-flower',
      name: 'Flower',
      price: 160,
      icon: Icons.local_florist_rounded,
      category: 'accessories',
      rarity: 'rare',
      value: 'flower',
    ),
    RewardShopItem(
      id: 'accessory-headphones',
      name: 'Headphones',
      price: 260,
      icon: Icons.headphones_rounded,
      category: 'accessories',
      rarity: 'legendary',
      value: 'headphones',
    ),
    RewardShopItem(
      id: 'accessory-wizard-hat',
      name: 'Wizard Hat',
      price: 180,
      icon: Icons.auto_fix_high_rounded,
      category: 'accessories',
      rarity: 'rare',
      value: 'wizard_hat',
    ),
    RewardShopItem(
      id: 'accessory-sleeping-cap',
      name: 'Sleeping Cap',
      price: 220,
      icon: Icons.nightlight_round,
      category: 'accessories',
      rarity: 'epic',
      value: 'sleeping_cap',
    ),
    RewardShopItem(
      id: 'accessory-halo',
      name: 'Halo',
      price: 240,
      icon: Icons.trip_origin_rounded,
      category: 'accessories',
      rarity: 'epic',
      value: 'halo',
    ),
    RewardShopItem(
      id: 'accessory-coin-clip',
      name: 'Mini GXBank Coin Clip',
      price: 320,
      icon: Icons.monetization_on_rounded,
      category: 'accessories',
      rarity: 'legendary',
      value: 'coin_clip',
    ),
    RewardShopItem(
      id: 'effect-sparkle-aura',
      name: 'Sparkle Aura',
      price: 350,
      icon: Icons.auto_awesome_rounded,
      category: 'effects',
      rarity: 'epic',
      value: 'sparkle_aura',
    ),
    RewardShopItem(
      id: 'effect-glow-outline',
      name: 'Glow Outline',
      price: 280,
      icon: Icons.blur_on_rounded,
      category: 'effects',
      rarity: 'rare',
      value: 'glow_outline',
    ),
    RewardShopItem(
      id: 'effect-floating-hearts',
      name: 'Floating Hearts',
      price: 300,
      icon: Icons.favorite_rounded,
      category: 'effects',
      rarity: 'legendary',
      value: 'floating_hearts',
    ),
    RewardShopItem(
      id: 'breed-orange-tabby',
      name: 'Orange Tabby',
      price: 120,
      icon: Icons.pets_rounded,
      category: 'breeds',
      rarity: 'common',
      value: 'orange_tabby',
    ),
    RewardShopItem(
      id: 'breed-black-cat',
      name: 'Black Cat',
      price: 160,
      icon: Icons.pets_rounded,
      category: 'breeds',
      rarity: 'rare',
      value: 'black_cat',
    ),
    RewardShopItem(
      id: 'breed-british-shorthair',
      name: 'British Shorthair',
      price: 220,
      icon: Icons.pets_rounded,
      category: 'breeds',
      rarity: 'epic',
      value: 'british_shorthair',
    ),
    RewardShopItem(
      id: 'breed-calico',
      name: 'Calico',
      price: 180,
      icon: Icons.pets_rounded,
      category: 'breeds',
      rarity: 'rare',
      value: 'calico',
    ),
    RewardShopItem(
      id: 'breed-persian',
      name: 'Persian',
      price: 260,
      icon: Icons.pets_rounded,
      category: 'breeds',
      rarity: 'legendary',
      value: 'persian',
    ),
  ];
}

List<TransactionRecord> seedTransactions() {
  return const [
    TransactionRecord(
      id: 'tx-1',
      merchant: 'Starbucks',
      amount: -12,
      icon: Icons.coffee_rounded,
      timestampLabel: '2h ago',
      category: 'Food & drinks',
    ),
    TransactionRecord(
      id: 'tx-2',
      merchant: 'Tealive',
      amount: -9,
      icon: Icons.local_drink_rounded,
      timestampLabel: 'Yesterday',
      category: 'Food & drinks',
    ),
    TransactionRecord(
      id: 'tx-3',
      merchant: 'GrabFood',
      amount: -24,
      icon: Icons.lunch_dining_rounded,
      timestampLabel: 'Yesterday',
      category: 'Food & drinks',
    ),
    TransactionRecord(
      id: 'tx-4',
      merchant: 'Salary',
      amount: 2400,
      icon: Icons.payments_rounded,
      timestampLabel: '3 days ago',
      category: 'Income',
    ),
    TransactionRecord(
      id: 'tx-5',
      merchant: 'Shopee',
      amount: -45,
      icon: Icons.shopping_bag_rounded,
      timestampLabel: '4 days ago',
      category: 'Shopping',
    ),
  ];
}

BudgetPlan buildBudgetPlan({
  required double monthlyBudget,
  required double savingsGoal,
  required Map<String, double> categoryPercents,
  required Set<int> yesAnswers,
  required AppColors colors,
}) {
  final cappedGoal = math.min(savingsGoal, monthlyBudget * 0.45);
  final savingsRate = math.max(0.1, cappedGoal / monthlyBudget).clamp(0.1, 0.45);
  final savingsAmount = monthlyBudget * savingsRate;
  final flexibleSpend = math.max(0.0, monthlyBudget - savingsAmount).toDouble();
  final dailyLimit = flexibleSpend / 30;

  final adaptabilityScore = ((72 +
              (yesAnswers.contains(1) ? 4 : 0) +
              (yesAnswers.contains(3) ? 6 : 0) -
              (yesAnswers.contains(0) ? 2 : 0))
          .clamp(68, 95))
      .toInt();

  final allocationColors = <String, Color>{
    'Food & drinks': colors.warning,
    'Transport': colors.primary,
    'Bills': colors.success,
    'Entertainment': colors.accent,
    'Shopping': colors.accentForeground,
  };

  final allocations = categoryPercents.entries
      .map(
        (entry) => BudgetAllocation(
          name: entry.key,
          percent: entry.value,
          amount: flexibleSpend * entry.value,
          color: allocationColors[entry.key] ?? colors.primary,
        ),
      )
      .toList()
    ..sort((a, b) => b.percent.compareTo(a.percent));

  final recommendations = <String>[
    'Your safe daily spending limit is RM ${formatRm(dailyLimit)} after setting aside RM ${formatRm(savingsAmount)} for savings.',
    if (yesAnswers.contains(3))
      'Because you are saving for something specific, ThinkTwice will protect your savings bucket before increasing lifestyle spend.'
    else
      'ThinkTwice will keep your daily limit automatic and update category targets as your transaction history grows.',
    if (yesAnswers.contains(0))
      'If food or impulse purchases spike, ThinkTwice can lower lifestyle categories first instead of making you rebuild the whole plan.'
    else if (yesAnswers.contains(1))
      'We assume you respond well to deals, so ThinkTwice will nudge cheaper alternatives before you overspend.'
    else
      'ThinkTwice will rebalance category targets automatically as your transaction patterns become clearer.',
  ];

  return BudgetPlan(
    dailyLimit: dailyLimit,
    savingsAmount: savingsAmount,
    savingsRate: savingsRate,
    flexibleSpend: flexibleSpend,
    adaptabilityScore: adaptabilityScore,
    allocations: allocations,
    recommendations: recommendations,
  );
}

Map<String, double> rebalanceCategoryPercents(
  Map<String, double> current,
  String targetKey,
  double nextPercent,
) {
  final updated = Map<String, double>.from(current);
  final clampedTarget = nextPercent.clamp(0.05, 0.7);
  final otherKeys = updated.keys.where((key) => key != targetKey).toList();
  final otherTotal = otherKeys.fold<double>(0, (sum, key) => sum + updated[key]!);
  final remaining = 1 - clampedTarget;

  if (otherTotal <= 0) {
    final evenShare = remaining / otherKeys.length;
    for (final key in otherKeys) {
      updated[key] = evenShare;
    }
  } else {
    for (final key in otherKeys) {
      updated[key] = (updated[key]! / otherTotal) * remaining;
    }
  }

  updated[targetKey] = clampedTarget.toDouble();

  final normalizedTotal = updated.values.fold<double>(0, (sum, value) => sum + value);
  for (final key in updated.keys.toList()) {
    updated[key] = updated[key]! / normalizedTotal;
  }

  return updated;
}






