import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/app_models.dart';

class MockRepository {
  UserProfileModel loadProfile() {
    return UserProfileModel.fromJson(const {
      'name': 'Aiman Hakim',
      'school': 'Universiti Malaya · Y3',
      'level': 4,
      'rank': 'Builder',
      'resilience': 68,
      'streak': 14,
      'badges': 9,
      'income': 'RM500 – 1,500',
      'habit': 'Balanced',
      'goals': ['Emergency fund'],
      'concerns': ['Late-night food'],
      'dailyBudget': 45.0,
      'autoSaveRate': 20.0,
      'spendingAlerts': true,
      'catName': 'Mochi',
      'catBreed': 'orangeTabby',
      'catHat': 'cap',
      'catGlasses': true,
    });
  }

  List<NudgeModel> loadNudges() {
    return const [
      NudgeModel(
        title: 'Food spend risk is high',
        message:
            'You are already 35% above your food budget today. Save RM10 now to protect your streak.',
        riskLevel: 'High',
        primaryActionLabel: 'Save RM10 now',
        secondaryActionLabel: 'Find cheaper options',
        impactLabel: '+4 resilience if you act now',
      ),
      NudgeModel(
        title: 'Late-night pattern detected',
        message:
            'Most overspending happens after 9:30 PM near Mid Valley. Switching to a cheaper stop could save RM13.',
        riskLevel: 'Medium',
        primaryActionLabel: 'Open Smart Radar',
        secondaryActionLabel: 'Continue anyway',
        impactLabel: 'Learning loop updates based on your choice',
      ),
    ];
  }

  List<InsightCardModel> loadInsights() {
    return const [
      InsightCardModel(
        title: 'You avoided RM120 overspending this month.',
        subtitle: 'Mostly skipped late-night Grab orders.',
        gradient: AppColors.emeraldGradient,
      ),
      InsightCardModel(
        title: 'Food spending down 18% this week.',
        subtitle: "Keep this rhythm to unlock 'Cafe Hermit' badge.",
        gradient: AppColors.aiGradient,
      ),
      InsightCardModel(
        title: 'Subscription leak detected.',
        subtitle: 'Spotify Duo unused for 23 days. RM14.90/mo.',
        gradient: AppColors.riskGradient,
      ),
    ];
  }

  List<AppTransaction> loadTransactions() {
    return const [
      AppTransaction(
        icon: Icons.local_cafe_rounded,
        name: 'Starbucks',
        category: 'Food · Mid Valley',
        time: '10:32 PM',
        amount: -12,
        isRisk: true,
      ),
      AppTransaction(
        icon: Icons.directions_car_rounded,
        name: 'Grab',
        category: 'Transport · USJ → KL',
        time: '9:14 PM',
        amount: -18,
      ),
      AppTransaction(
        icon: Icons.shopping_bag_rounded,
        name: 'Shopee',
        category: 'Shopping · Apparel',
        time: '6:02 PM',
        amount: -39,
      ),
      AppTransaction(
        icon: Icons.savings_rounded,
        name: 'Auto-save Vault',
        category: 'Round-up · 12 tx',
        time: '5:00 PM',
        amount: 8.4,
      ),
      AppTransaction(
        icon: Icons.menu_book_rounded,
        name: 'Kinokuniya',
        category: 'Books · KLCC',
        time: '1:48 PM',
        amount: -45,
      ),
      AppTransaction(
        icon: Icons.movie_creation_outlined,
        name: 'Netflix',
        category: 'Subscription',
        time: '9:00 AM',
        amount: -19.9,
      ),
    ];
  }

  List<RadarDeal> loadDeals() {
    return const [
      RadarDeal(
        label: 'Jaya Grocer',
        savings: 4,
        latitude: 3.1078,
        longitude: 101.6066,
        description: 'Rice · Eggs & Milk · Veggies',
        rating: 4.7,
      ),
      RadarDeal(
        label: 'Tesco',
        savings: 14,
        latitude: 3.1112,
        longitude: 101.6108,
        description: 'Cheapest basket combo',
        rating: 4.8,
        tag: 'Hot',
      ),
      RadarDeal(
        label: 'Mydin',
        savings: 7,
        latitude: 3.1048,
        longitude: 101.6143,
        description: 'Student value picks',
        rating: 4.5,
      ),
      RadarDeal(
        label: 'Family Mart',
        savings: 3,
        latitude: 3.1137,
        longitude: 101.6184,
        description: 'Buy 2 onigiri, free drink',
        rating: 4.8,
      ),
    ];
  }

  List<QuestModel> loadQuests() {
    return const [
      QuestModel(
        title: 'Skip 3 kopi runs',
        reward: '+150 XP',
        progress: 0.66,
        subtitle: '2 / 3 done',
      ),
      QuestModel(
        title: 'Hit RM200 in vault',
        reward: '+300 XP · Hat',
        progress: 0.85,
        subtitle: 'RM170 / 200',
      ),
      QuestModel(
        title: 'Use Smart Radar 5x',
        reward: '+80 XP',
        progress: 0.4,
        subtitle: '2 / 5',
      ),
      QuestModel(
        title: 'No late-night spending (9pm–2am)',
        reward: '+200 XP · Rare skin',
        progress: 1,
        subtitle: 'Claim now!',
        claimable: true,
      ),
    ];
  }
}
