import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'src/core/app_theme.dart';
import 'src/core/models.dart';
import 'src/core/seed_data.dart';
import 'src/screens/auth_screens.dart';
import 'src/screens/challenges_screen.dart';
import 'src/screens/home_page.dart';
import 'src/screens/insights_page.dart';
import 'src/screens/profile_screen.dart';
import 'src/screens/radar_screen.dart';
import 'src/services/auth_service.dart';
import 'src/services/backend_api_service.dart';
import 'src/widgets/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  static const _avatarProfileKey = 'avatar_profile';
  static const _ownedRewardIdsKey = 'owned_reward_ids';
  static const _totalPointsKey = 'total_points';
  static const _resilienceScoreKey = 'resilience_score';
  static const _smartDecisionScoreKey = 'smart_decision_score';
  static const _currentStreakKey = 'current_streak';

  String _userId = '';
  String _userName = 'Friend';

  bool _showSplash = true;
  bool _isAuthed = false;
  int _tabIndex = 0;
  bool _showHomeAlert = false;
  bool _gxBankConnected = true;
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  double _autoSavePercent = 0.1;
  int _onboardingStep = 0;
  int _resilienceScore = 50;
  int _smartDecisionScore = 0;
  int _currentStreak = 0;
  int _totalPoints = 1180;
  double _savingsPocket = 0;
  double _balance = 1284.50;

  // Live AI data
  List<String> _aiInsights = [];
  String _lastNudgeText = '';
  String _lastRiskLevel = 'low';
  bool _triggerSmartRadar = false;
  String? _radarCategory;

  // Live nudge history for insights page
  List<Map<String, dynamic>> _nudgeHistory = [];

  CatAvatarProfile _avatarProfile = const CatAvatarProfile(
    breed: 'siamese',
    expression: 'proud',
    accessory: 'ribbon',
    effect: 'none',
  );
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
    unawaited(_loadPersistedState());
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _showSplash = false);
    });
    // If user is already signed in (e.g. page refresh), skip login
    final existing = AuthService.currentUser;
    if (existing != null) {
      setState(() {
        _userId = existing.uid;
        _userName = existing.displayName?.isNotEmpty == true
            ? existing.displayName!
            : existing.email?.split('@')[0] ?? 'Friend';
      });
      unawaited(_refreshFromBackend());
    }
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final rawAvatar = prefs.getString(_avatarProfileKey);
    final ownedIds = prefs.getStringList(_ownedRewardIdsKey) ?? const <String>[];

    CatAvatarProfile avatarProfile = _avatarProfile;
    if (rawAvatar != null) {
      final decoded = jsonDecode(rawAvatar);
      if (decoded is Map<String, dynamic>) {
        avatarProfile = CatAvatarProfile(
          breed: decoded['breed'] as String? ?? avatarProfile.breed,
          expression: decoded['expression'] as String? ?? avatarProfile.expression,
          accessory: decoded['accessory'] as String? ?? avatarProfile.accessory,
          effect: (decoded['effect'] as String?) ??
              (decoded['cosmetic'] as String?)?.replaceAll('sparkle', 'sparkle_aura').replaceAll('coins', 'glow_outline') ??
              avatarProfile.effect,
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _avatarProfile = avatarProfile;
      _totalPoints = prefs.getInt(_totalPointsKey) ?? _totalPoints;
      _resilienceScore = prefs.getInt(_resilienceScoreKey) ?? _resilienceScore;
      _smartDecisionScore = prefs.getInt(_smartDecisionScoreKey) ?? _smartDecisionScore;
      _currentStreak = prefs.getInt(_currentStreakKey) ?? _currentStreak;
      _rewardShopItems = _rewardShopItems
          .map((item) => ownedIds.contains(item.id) ? item.copyWith(owned: true) : item)
          .toList();
    });
  }

  // Fetch live data from backend after login
  Future<bool> _refreshFromBackend() async {
    if (_userId.isEmpty) return false;
    try {
      final profile = await BackendApiService.getUserProfile(_userId);
      final rawTransactions = await BackendApiService.getTransactions(_userId);
      final nudgeHistory = await BackendApiService.getNudgeHistory(_userId);

      final liveTransactions = rawTransactions.map((t) {
        final category = t['category'] as String? ?? 'General';
        final amount = (t['amount'] as num?)?.toDouble() ?? 0;
        final merchant = t['merchant'] as String? ?? 'Unknown';
        return TransactionRecord(
          id: t['id'] as String? ?? UniqueKey().toString(),
          merchant: merchant,
          amount: -amount.abs(),
          icon: _iconForCategory(category),
          timestampLabel: _formatTimestamp(t['timestamp']),
          category: category,
        );
      }).toList();

      if (!mounted) return true;
      setState(() {
        _resilienceScore = profile.resilienceScore;
        _smartDecisionScore = profile.smartDecisionScore;
        _savingsPocket = profile.savingsPocket;
        if (profile.currentBalance > 0) _balance = profile.currentBalance;
        if (profile.displayName.isNotEmpty) _userName = profile.displayName;
        if (liveTransactions.isNotEmpty) {
          _transactions = liveTransactions;
        }
        _nudgeHistory = nudgeHistory;
        _isAuthed = true; // User exists, skip login/onboarding
      });
      unawaited(_persistAppState());
      return true;
    } catch (e) {
      debugPrint('Backend refresh failed: $e');
      return false;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'savings': return Icons.savings_rounded;
      default: return Icons.receipt_rounded;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      DateTime dt;
      if (timestamp is String) {
        dt = DateTime.parse(timestamp);
      } else {
        return 'Recently';
      }
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Recently';
    }
  }

  Future<void> _persistAppState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _avatarProfileKey,
      jsonEncode({
        'breed': _avatarProfile.breed,
        'expression': _avatarProfile.expression,
        'accessory': _avatarProfile.accessory,
        'effect': _avatarProfile.effect,
      }),
    );
    await prefs.setStringList(
      _ownedRewardIdsKey,
      _rewardShopItems.where((item) => item.owned).map((item) => item.id).toList(),
    );
    await prefs.setInt(_totalPointsKey, _totalPoints);
    await prefs.setInt(_resilienceScoreKey, _resilienceScore);
    await prefs.setInt(_smartDecisionScoreKey, _smartDecisionScore);
    await prefs.setInt(_currentStreakKey, _currentStreak);
  }

  void _updateAvatarProfile(CatAvatarProfile nextProfile) {
    setState(() => _avatarProfile = nextProfile);
    unawaited(_persistAppState());
  }

  /// Called by LoginPage after Firebase Auth succeeds.
  Future<void> _onAuthSuccess(String uid, String displayName) async {
    setState(() {
      _userId = uid;
      _userName = displayName;
    });

    // Check if user exists in backend
    final exists = await _refreshFromBackend();

    if (!mounted) return;
    if (!exists) {
      // New user -> show onboarding
      setState(() {
        _isAuthed = false;
        _onboardingStep = 1;
      });
    }
  }

  void _resetSessionState() {
    unawaited(AuthService.signOut());
    setState(() {
      _isAuthed = false;
      _onboardingStep = 0;
      _tabIndex = 0;
      _showHomeAlert = false;
      _gxBankConnected = true;
      _totalPoints = 1180;
      _resilienceScore = 50;
      _smartDecisionScore = 0;
      _currentStreak = 0;
      _savingsPocket = 0;
      _balance = 1284.50;
      _userId = '';
      _userName = 'Friend';
      _aiInsights = [];
      _nudgeHistory = [];
      _lastNudgeText = '';
      _lastRiskLevel = 'low';
      _triggerSmartRadar = false;
      _radarCategory = null;
      _avatarProfile = const CatAvatarProfile(
        breed: 'tabby',
        expression: 'proud',
        accessory: 'ribbon',
        effect: 'none',
      );
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
    });
    unawaited(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_avatarProfileKey);
      await prefs.remove(_ownedRewardIdsKey);
      await prefs.remove(_totalPointsKey);
      await prefs.remove(_resilienceScoreKey);
      await prefs.remove(_smartDecisionScoreKey);
      await prefs.remove(_currentStreakKey);
    }());
  }

  void _awardPoints(String label, int points, IconData icon) {
    setState(() {
      _totalPoints += points;
      _recentPoints.insert(0, PointsEvent(label: label, points: points, icon: icon));
      if (_recentPoints.length > 5) _recentPoints.removeLast();
    });
    unawaited(_persistAppState());
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
    unawaited(_persistAppState());
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
    unawaited(_persistAppState());
    _awardPoints('${quest.title} reward claimed', quest.rewardPoints, Icons.emoji_events_rounded);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reward claimed! You earned +${quest.rewardPoints} pts.')),
    );
    showCelebrationDialog(
      context,
      title: 'Reward Claimed',
      body: 'Your cat companion just banked +${quest.rewardPoints} pts. Keep the streak glowing.',
      icon: Icons.emoji_events_rounded,
      color: context.colors.accentForeground,
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
      switch (item.category) {
        case 'accessories':
          _avatarProfile = _avatarProfile.copyWith(accessory: item.value);
          break;
        case 'breeds':
          _avatarProfile = _avatarProfile.copyWith(breed: item.value);
          break;
        case 'effects':
          _avatarProfile = _avatarProfile.copyWith(effect: item.value);
          break;
      }
    });
    unawaited(_persistAppState());

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reward Shop'),
        content: const Text('Redeemed and equipped successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // UPDATED — calls backend, shows AI nudge modal if risk detected
  void _saveFromIntervention(BuildContext context) async {
    setState(() => _showHomeAlert = false);

    try {
      final result = await BackendApiService.approveAutoSave(
        userId: _userId,
        amount: 8,
      );

      setState(() {
        _resilienceScore = (_resilienceScore + (result['resilienceDelta'] as int? ?? 5)).clamp(0, 100);
        _smartDecisionScore = (_smartDecisionScore + 10).clamp(0, 100);
        _savingsPocket += 8;
        _currentStreak += 1;
        _avatarProfile = _avatarProfile.copyWith(expression: 'happy');
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
      unawaited(_persistAppState());
      _awardPoints('Protected your streak with a quick save', 40, Icons.savings_rounded);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RM8 moved to savings. Your dashboard has been updated.')),
      );
      showCelebrationDialog(
        context,
        title: 'Nice Save',
        body: 'RM8 is tucked away and your streak just got stronger.',
        icon: Icons.savings_rounded,
        color: context.colors.success,
      );
    } catch (e) {
      setState(() {
        _resilienceScore = (_resilienceScore + 6).clamp(0, 100);
        _smartDecisionScore = (_smartDecisionScore + 10).clamp(0, 100);
        _currentStreak += 1;
        _avatarProfile = _avatarProfile.copyWith(expression: 'happy');
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
      unawaited(_persistAppState());
      _awardPoints('Protected your streak with a quick save', 40, Icons.savings_rounded);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RM8 moved to savings. Your dashboard has been updated.')),
      );
    }
  }

  void _openRadarFromIntervention() {
    setState(() {
      _showHomeAlert = false;
      _tabIndex = 1;
    });
  }

  // UPDATED — calls backend reject
  void _ignoreIntervention() async {
    setState(() {
      _showHomeAlert = false;
      _resilienceScore = (_resilienceScore - 2).clamp(0, 100).toInt();
      _avatarProfile = _avatarProfile.copyWith(expression: 'sad');
    });
    unawaited(_persistAppState());
    try {
      await BackendApiService.rejectAutoSave(userId: _userId);
    } catch (_) {}
  }

  Future<void> _openAvatarCustomization(BuildContext context) async {
    final result = await showModalBottomSheet<AvatarCustomizationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarCustomizationSheet(
        totalPoints: _totalPoints,
        rewardShopItems: _rewardShopItems,
        breed: _avatarProfile.breed,
        accessory: _avatarProfile.accessory,
        effect: _avatarProfile.effect,
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
      _avatarProfile = _avatarProfile.copyWith(
        breed: result.breed,
        accessory: result.accessory,
        effect: result.effect,
      );
    });
    unawaited(_persistAppState());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar updated!')),
    );
  }

  // UPDATED — setup user in backend + fetch live scores
  Future<void> _completeOnboarding() async {
    try {
      await BackendApiService.setupUser(
        userId: _userId,
        dailyBudget: _budget / 30,
        savingsGoal: _goal,
        displayName: _userName,
      );
      final profile = await BackendApiService.getUserProfile(_userId);
      setState(() {
        _resilienceScore = profile.resilienceScore;
        _smartDecisionScore = profile.smartDecisionScore;
        _savingsPocket = profile.savingsPocket;
        if (profile.currentBalance > 0) _balance = profile.currentBalance;
        if (profile.displayName.isNotEmpty) _userName = profile.displayName;
        _isAuthed = true;
        _tabIndex = 0;
      });
      // Fetch live data after login
      unawaited(_refreshFromBackend());
    } catch (e) {
      setState(() {
        _isAuthed = true;
        _tabIndex = 0;
      });
      unawaited(_refreshFromBackend());
    }
  }

  // Called when a new transaction triggers an AI nudge
  void _handleAiNudge(AiNudge nudge, double? newBalance) {
    setState(() {
      _lastNudgeText = nudge.nudgeText ?? '';
      _lastRiskLevel = nudge.riskLevel;
      _aiInsights = nudge.aiExplanation;
      _triggerSmartRadar = nudge.triggerSmartRadar;
      _radarCategory = nudge.radarCategory;

      // Update balance immediately from backend response
      if (newBalance != null && newBalance >= 0) _balance = newBalance;

      if (nudge.riskLevel == 'high' || nudge.riskLevel == 'medium') {
        _showHomeAlert = true;
      }

      // Update scores from AI
      if (nudge.resilienceImpact > 0) {
        _resilienceScore = nudge.resilienceImpact.clamp(0, 100);
      }
    });
    unawaited(_persistAppState());
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
          onAuthSuccess: _onAuthSuccess,
        );
      }

      return OnboardingPage(
        step: _onboardingStep - 1,
        breed: _avatarProfile.breed,
        expression: _avatarProfile.expression,
        accessory: _avatarProfile.accessory,
        effect: _avatarProfile.effect,
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
        onSetBreed: (v) => _updateAvatarProfile(_avatarProfile.copyWith(breed: v)),
        onSetExpression: (v) => _updateAvatarProfile(_avatarProfile.copyWith(expression: v)),
        onSetAccessory: (v) => _updateAvatarProfile(_avatarProfile.copyWith(accessory: v)),
        onSetEffect: (v) => _updateAvatarProfile(_avatarProfile.copyWith(effect: v)),
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
        onNext: () {
          if (_onboardingStep < 3) {
            setState(() => _onboardingStep += 1);
          } else {
            unawaited(_completeOnboarding());
          }
        },
      );
    }

    return MainShell(
      tabIndex: _tabIndex,
      onTabChanged: (index) {
      setState(() => _tabIndex = index);
      if (index == 0) unawaited(_refreshFromBackend());
    },
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
            breed: _avatarProfile.breed,
            accessory: _avatarProfile.accessory,
            effect: _avatarProfile.effect,
            showAlert: _showHomeAlert,
            onSaveAlert: () => _saveFromIntervention(context),
            onOpenAlternatives: _openRadarFromIntervention,
            onDismissAlert: _ignoreIntervention,
            onNavigate: (index) => setState(() => _tabIndex = index),
            userName: _userName,
            balance: _balance,
            savingsPocket: _savingsPocket,
            aiInsights: _aiInsights,
            lastNudgeText: _lastNudgeText,
            lastRiskLevel: _lastRiskLevel,
            userId: _userId,
            onAiNudge: _handleAiNudge,
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
            breed: _avatarProfile.breed,
            expression: _avatarProfile.expression,
            accessory: _avatarProfile.accessory,
            effect: _avatarProfile.effect,
            onClaimReward: (questId) => _claimQuestReward(context, questId),
            onRedeemItem: (itemId) => _redeemRewardShopItem(context, itemId),
            onCustomizeAvatar: () => _openAvatarCustomization(context),
          ),
          InsightsPage(
            plan: plan,
            goal: _goal,
            aiInsights: _aiInsights,
            nudgeHistory: _nudgeHistory,
            savingsPocket: _savingsPocket,
            transactions: _transactions,
          ),
          ProfilePage(
            budget: _budget,
            goal: _goal,
            plan: plan,
            totalPoints: _totalPoints,
            transactions: _transactions,
            breed: _avatarProfile.breed,
            expression: _avatarProfile.expression,
            accessory: _avatarProfile.accessory,
            effect: _avatarProfile.effect,
            notificationsEnabled: _notificationsEnabled,
            autoSaveEnabled: _autoSaveEnabled,
            onNotificationsChanged: (value) => setState(() => _notificationsEnabled = value),
            onAutoSaveChanged: (value) => setState(() => _autoSaveEnabled = value),
            onSignOut: _resetSessionState,
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(tabIndex),
                      child: child,
                    ),
                  ),
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