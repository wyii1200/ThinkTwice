import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'src/core/app_theme.dart';
import 'src/core/models.dart';
import 'src/core/seed_data.dart';
import 'src/screens/auth_screens.dart';
import 'src/screens/challenges_screen.dart';
import 'src/screens/home_page.dart';
import 'src/screens/insights_page.dart';
import 'src/screens/profile_screen.dart';
import 'src/screens/radar_screen.dart';

void main() {
  runApp(const ThinkTwiceApp());
}

class ThinkTwiceApp extends StatelessWidget {
  const ThinkTwiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThinkTwice',
      theme: buildTheme(),
      home: const AppRoot(),
    );
  }
}


class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;
  bool _isAuthed = false;
  int _tabIndex = 0;
  bool _showHomeAlert = true;
  bool _isLoginMode = true;
  bool _showPassword = false;
  bool _gxBankConnected = true;
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  double _autoSavePercent = 0.1;
  int _onboardingStep = 0;
  int _resilienceScore = 50;
  int _smartDecisionScore = 0;
  int _currentStreak = 0;
  int _totalPoints = 1180;
  String _breed = 'tabby';
  String _color = 'mint';
  String _accessory = 'ribbon';
  String _outfit = 'Hoodie';
  String _cosmetic = 'none';
  double _budget = 1200;
  double _goal = 800;
  final Set<String> _selectedPriorities = <String>{'Emergency fund', 'Reduce food spending'};
  LatLng _radarUserLocation = kDefaultRadarCenter;
  Map<String, double> _categoryPercents = <String, double>{
    'Food & drinks': 0.35,
    'Transport': 0.15,
    'Entertainment': 0.12,
    'Bills': 0.23,
    'Shopping': 0.15,
  };
  List<CommunityDeal> _communityDeals = seedDeals();
  List<QuestProgress> _quests = seedQuests();
  List<RewardShopItem> _rewardShopItems = seedRewardShopItems();
  List<TransactionRecord> _transactions = seedTransactions();
  final List<PointsEvent> _recentPoints = <PointsEvent>[
    const PointsEvent(label: 'Saved under daily limit', points: 120, icon: Icons.savings_outlined),
    const PointsEvent(label: 'Quest completed', points: 80, icon: Icons.emoji_events_rounded),
    const PointsEvent(label: 'Used a smart nudge', points: 35, icon: Icons.auto_awesome_rounded),
  ];
  final Set<int> _yesAnswers = <int>{};
  final Set<int> _noAnswers = <int>{};

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  void _awardPoints(String label, int points, IconData icon) {
    setState(() {
      _totalPoints += points;
      _recentPoints.insert(0, PointsEvent(label: label, points: points, icon: icon));
      if (_recentPoints.length > 5) {
        _recentPoints.removeLast();
      }
    });
  }

  void _updateRadarLocation(LatLng location) {
    setState(() => _radarUserLocation = location);
  }

  void _postCommunityDeal(CommunityDeal deal) {
    setState(() {
      _communityDeals = [deal, ..._communityDeals];
      _smartDecisionScore += 3;
    });
    _awardPoints('Posted a community deal', 90, Icons.campaign_rounded);
  }

  void _upvoteCommunityDeal(String id) {
    setState(() {
      _communityDeals = _communityDeals
          .map((deal) => deal.id == id ? deal.copyWith(upvotes: deal.upvotes + 1) : deal)
          .toList();
    });
  }

  void _verifyCommunityDeal(String id) {
    setState(() {
      _communityDeals = _communityDeals
          .map((deal) => deal.id == id ? deal.copyWith(verifications: deal.verifications + 1) : deal)
          .toList();
      _resilienceScore = (_resilienceScore + 1).clamp(0, 100).toInt();
    });
    _awardPoints('Verified a community deal', 20, Icons.verified_rounded);
  }

  void _claimQuestReward(BuildContext context, String questId) {
    final questIndex = _quests.indexWhere((quest) => quest.id == questId);
    if (questIndex == -1) return;
    final quest = _quests[questIndex];
    if (!quest.isCompleted || quest.isClaimed) return;

    setState(() {
      _quests[questIndex] = quest.copyWith(isClaimed: true);
    });
    _awardPoints('${quest.title} reward claimed', quest.rewardPoints, Icons.emoji_events_rounded);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reward claimed! You earned +${quest.rewardPoints} pts.')),
    );
  }

  void _redeemRewardShopItem(BuildContext context, String itemId) {
    final itemIndex = _rewardShopItems.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;
    final item = _rewardShopItems[itemIndex];
    if (item.owned) return;

    if (_totalPoints < item.price) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reward Shop'),
          content: const Text('Not enough points yet.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _totalPoints -= item.price;
      _rewardShopItems[itemIndex] = item.copyWith(owned: true);
    });

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reward Shop'),
        content: const Text('Redeemed successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveFromIntervention(BuildContext context) {
    setState(() {
      _showHomeAlert = false;
      _resilienceScore = (_resilienceScore + 6).clamp(0, 100).toInt();
      _smartDecisionScore = (_smartDecisionScore + 10).clamp(0, 100).toInt();
      _currentStreak += 1;
      _transactions = [
        const TransactionRecord(
          id: 'tx-auto-save',
          merchant: 'Pocket Save',
          amount: 8,
          icon: Icons.savings_rounded,
          timestampLabel: 'Just now',
          category: 'Savings',
        ),
        ..._transactions.where((tx) => tx.id != 'tx-auto-save'),
      ];
    });
    _awardPoints('Protected your streak with a quick save', 40, Icons.savings_rounded);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('RM8 moved to savings. Your dashboard has been updated.')),
    );
  }

  void _openRadarFromIntervention() {
    setState(() {
      _showHomeAlert = false;
      _tabIndex = 1;
    });
  }

  void _ignoreIntervention() {
    setState(() {
      _showHomeAlert = false;
      _resilienceScore = (_resilienceScore - 2).clamp(0, 100).toInt();
    });
  }

  Future<void> _openAvatarCustomization(BuildContext context) async {
    final result = await showModalBottomSheet<AvatarCustomizationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarCustomizationSheet(
        totalPoints: _totalPoints,
        rewardShopItems: _rewardShopItems,
        breed: _breed,
        color: _color,
        accessory: _accessory,
        outfit: _outfit,
        cosmetic: _cosmetic,
      ),
    );

    if (result == null) return;

    final purchasedItems = _rewardShopItems.where((item) => result.purchasedItemIds.contains(item.id)).toList();
    final totalCost = purchasedItems.fold<int>(0, (sum, item) => sum + (item.owned ? 0 : item.price));
    if (_totalPoints < totalCost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Points changed before saving. Please try again.')),
      );
      return;
    }

    setState(() {
      _totalPoints -= totalCost;
      _rewardShopItems = _rewardShopItems
          .map((item) => result.purchasedItemIds.contains(item.id) ? item.copyWith(owned: true) : item)
          .toList();
      _accessory = result.accessory;
      _outfit = result.outfit;
      _cosmetic = result.cosmetic;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashPage();
    final plan = buildBudgetPlan(
      monthlyBudget: _budget,
      savingsGoal: _goal,
      categoryPercents: _categoryPercents,
      yesAnswers: _yesAnswers,
      colors: context.colors,
    );

    if (!_isAuthed) {
      if (_onboardingStep == 0) {
        return LoginPage(
          isLoginMode: _isLoginMode,
          showPassword: _showPassword,
          onToggleMode: () => setState(() => _isLoginMode = !_isLoginMode),
          onTogglePassword: () => setState(() => _showPassword = !_showPassword),
          onContinue: () => setState(() {
            _isAuthed = false;
            _onboardingStep = 1;
          }),
        );
      }

      return OnboardingPage(
        step: _onboardingStep - 1,
        breed: _breed,
        color: _color,
        accessory: _accessory,
        outfit: _outfit,
        budget: _budget,
        goal: _goal,
        gxBankConnected: _gxBankConnected,
        notificationsEnabled: _notificationsEnabled,
        autoSaveEnabled: _autoSaveEnabled,
        autoSavePercent: _autoSavePercent,
        selectedPriorities: _selectedPriorities,
        categoryPercents: _categoryPercents,
        plan: plan,
        yesAnswers: _yesAnswers,
        noAnswers: _noAnswers,
        onSetBreed: (v) => setState(() => _breed = v),
        onSetColor: (v) => setState(() => _color = v),
        onSetAccessory: (v) => setState(() => _accessory = v),
        onSetOutfit: (v) => setState(() => _outfit = v),
        onSetBudget: (v) => setState(() => _budget = v),
        onSetGoal: (v) => setState(() => _goal = v),
        onSetAutoSavePercent: (v) => setState(() => _autoSavePercent = v),
        onToggleNotifications: (value) => setState(() => _notificationsEnabled = value),
        onToggleAutoSave: (value) => setState(() => _autoSaveEnabled = value),
        onTogglePriority: (label) => setState(() {
          if (_selectedPriorities.contains(label)) {
            _selectedPriorities.remove(label);
          } else {
            _selectedPriorities.add(label);
          }
        }),
        onSetCategoryPercent: (key, value) => setState(() {
          _categoryPercents = rebalanceCategoryPercents(_categoryPercents, key, value);
        }),
        onTogglePersonality: (index, yes) {
          setState(() {
            if (yes) {
              _yesAnswers.add(index);
              _noAnswers.remove(index);
            } else {
              _noAnswers.add(index);
              _yesAnswers.remove(index);
            }
          });
        },
        onBack: () => setState(() {
          if (_onboardingStep > 1) {
            _onboardingStep -= 1;
          } else {
            _onboardingStep = 0;
          }
        }),
        onNext: () => setState(() {
          if (_onboardingStep < 3) {
            _onboardingStep += 1;
          } else {
            _isAuthed = true;
            _tabIndex = 0;
          }
        }),
      );
    }

    return MainShell(
      tabIndex: _tabIndex,
      onTabChanged: (index) => setState(() => _tabIndex = index),
      child: IndexedStack(
        index: _tabIndex,
        children: [
          HomePage(
            plan: plan,
            goal: _goal,
            totalPoints: _totalPoints,
            resilienceScore: _resilienceScore,
            smartDecisionScore: _smartDecisionScore,
            currentStreak: _currentStreak,
            recentPoints: _recentPoints,
            transactions: _transactions,
            showAlert: _showHomeAlert,
            onSaveAlert: () => _saveFromIntervention(context),
            onOpenAlternatives: _openRadarFromIntervention,
            onDismissAlert: _ignoreIntervention,
            onNavigate: (index) => setState(() => _tabIndex = index),
          ),
          RadarPage(
            deals: _communityDeals,
            userLocation: _radarUserLocation,
            onLocationChanged: _updateRadarLocation,
            onPostDeal: _postCommunityDeal,
            onUpvoteDeal: _upvoteCommunityDeal,
            onVerifyDeal: _verifyCommunityDeal,
          ),
          ChallengesPage(
            totalPoints: _totalPoints,
            quests: _quests,
            rewardShopItems: _rewardShopItems,
            breed: _breed,
            color: _color,
            accessory: _accessory,
            outfit: _outfit,
            cosmetic: _cosmetic,
            onClaimReward: (questId) => _claimQuestReward(context, questId),
            onRedeemItem: (itemId) => _redeemRewardShopItem(context, itemId),
            onCustomizeAvatar: () => _openAvatarCustomization(context),
          ),
          InsightsPage(plan: plan, goal: _goal),
          ProfilePage(
            budget: _budget,
            goal: _goal,
            plan: plan,
            totalPoints: _totalPoints,
            transactions: _transactions,
            breed: _breed,
            color: _color,
            accessory: _accessory,
            outfit: _outfit,
            cosmetic: _cosmetic,
            notificationsEnabled: _notificationsEnabled,
            autoSaveEnabled: _autoSaveEnabled,
            onNotificationsChanged: (value) => setState(() => _notificationsEnabled = value),
            onAutoSaveChanged: (value) => setState(() => _autoSaveEnabled = value),
            onSignOut: () => setState(() {
              _isAuthed = false;
              _isLoginMode = true;
              _showPassword = false;
              _onboardingStep = 0;
              _tabIndex = 0;
              _showHomeAlert = true;
              _gxBankConnected = true;
              _totalPoints = 1180;
              _resilienceScore = 50;
              _smartDecisionScore = 0;
              _currentStreak = 0;
              _breed = 'tabby';
              _color = 'mint';
              _accessory = 'ribbon';
              _outfit = 'Hoodie';
              _cosmetic = 'none';
              _communityDeals = seedDeals();
              _quests = seedQuests();
              _rewardShopItems = seedRewardShopItems();
              _transactions = seedTransactions();
              _radarUserLocation = kDefaultRadarCenter;
              _notificationsEnabled = true;
              _autoSaveEnabled = true;
              _autoSavePercent = 0.1;
              _selectedPriorities
                ..clear()
                ..addAll(const {'Emergency fund', 'Reduce food spending'});
              _yesAnswers.clear();
              _noAnswers.clear();
              _recentPoints
                ..clear()
                ..addAll(const [
                  PointsEvent(label: 'Saved under daily limit', points: 120, icon: Icons.savings_outlined),
                  PointsEvent(label: 'Quest completed', points: 80, icon: Icons.emoji_events_rounded),
                  PointsEvent(label: 'Used a smart nudge', points: 35, icon: Icons.auto_awesome_rounded),
                ]);
              _categoryPercents = <String, double>{
                'Food & drinks': 0.35,
                'Transport': 0.15,
                'Entertainment': 0.12,
                'Bills': 0.23,
                'Shopping': 0.15,
              };
            }),
          ),
        ],
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.tabIndex,
    required this.onTabChanged,
    required this.child,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _ShellTab('Home', Icons.home_rounded),
      _ShellTab('Radar', Icons.map_rounded),
      _ShellTab('Challenges', Icons.emoji_events_rounded),
      _ShellTab('Insights', Icons.bar_chart_rounded),
      _ShellTab('Profile', Icons.person_rounded),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 92),
                  child: child,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                      decoration: BoxDecoration(
                        color: context.colors.card.withOpacity(0.95),
                        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.6))),
                      ),
                      child: Row(
                        children: List.generate(tabs.length, (index) {
                          final tab = tabs[index];
                          final active = index == tabIndex;
                          return Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => onTabChanged(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: active ? context.colors.primary.withOpacity(0.15) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Transform.scale(
                                        scale: active ? 1.1 : 1,
                                        child: Icon(
                                          tab.icon,
                                          size: 20,
                                          color: active ? context.colors.primary : context.colors.mutedForeground,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tab.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: active ? context.colors.primary : context.colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.icon);

  final String label;
  final IconData icon;
}




