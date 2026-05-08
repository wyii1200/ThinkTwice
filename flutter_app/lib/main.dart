
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

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

ThemeData buildTheme() {
  const background = Color(0xFFF5FBF7);
  const foreground = Color(0xFF193C34);
  const card = Colors.white;
  const muted = Color(0xFFE9F2ED);
  const mutedForeground = Color(0xFF6B847E);
  const primary = Color(0xFF41B89B);
  const primaryGlow = Color(0xFF86D8BF);
  const accent = Color(0xFFEACB6A);
  const accentForeground = Color(0xFF66511D);
  const success = Color(0xFF54C18C);
  const warning = Color(0xFFE2B14C);
  const destructive = Color(0xFFE1604F);

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
    primary: primary,
    secondary: accent,
    surface: card,
    error: destructive,
  ).copyWith(
    surface: card,
    onSurface: foreground,
    primary: primary,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: accentForeground,
    error: destructive,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: scheme,
    textTheme: Typography.blackCupertino.apply(
      bodyColor: foreground,
      displayColor: foreground,
    ),
    dividerColor: const Color(0xFFE3ECE6),
    cardColor: card,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        background: background,
        foreground: foreground,
        card: card,
        muted: muted,
        mutedForeground: mutedForeground,
        primary: primary,
        primaryGlow: primaryGlow,
        accent: accent,
        accentForeground: accentForeground,
        success: success,
        warning: warning,
        destructive: destructive,
      ),
    ],
  );
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.muted,
    required this.mutedForeground,
    required this.primary,
    required this.primaryGlow,
    required this.accent,
    required this.accentForeground,
    required this.success,
    required this.warning,
    required this.destructive,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color muted;
  final Color mutedForeground;
  final Color primary;
  final Color primaryGlow;
  final Color accent;
  final Color accentForeground;
  final Color success;
  final Color warning;
  final Color destructive;

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryGlow],
      );

  LinearGradient get warmGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEACB6A), Color(0xFFE49A57)],
      );

  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primary.withOpacity(0.15),
          blurRadius: 20,
          spreadRadius: -4,
          offset: const Offset(0, 4),
        ),
      ];

  @override
  AppColors copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? muted,
    Color? mutedForeground,
    Color? primary,
    Color? primaryGlow,
    Color? accent,
    Color? accentForeground,
    Color? success,
    Color? warning,
    Color? destructive,
  }) {
    return AppColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      primary: primary ?? this.primary,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      destructive: destructive ?? this.destructive,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
    );
  }
}

extension ThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

class BudgetAllocation {
  const BudgetAllocation({
    required this.name,
    required this.percent,
    required this.amount,
    required this.color,
  });

  final String name;
  final double percent;
  final double amount;
  final Color color;
}

class BudgetPlan {
  const BudgetPlan({
    required this.dailyLimit,
    required this.savingsAmount,
    required this.savingsRate,
    required this.flexibleSpend,
    required this.adaptabilityScore,
    required this.allocations,
    required this.recommendations,
  });

  final double dailyLimit;
  final double savingsAmount;
  final double savingsRate;
  final double flexibleSpend;
  final int adaptabilityScore;
  final List<BudgetAllocation> allocations;
  final List<String> recommendations;
}

class CommunityDeal {
  const CommunityDeal({
    required this.id,
    required this.title,
    required this.storeName,
    required this.category,
    required this.description,
    required this.expiryDate,
    required this.latitude,
    required this.longitude,
    required this.originalPrice,
    required this.dealPrice,
    required this.discountLabel,
    required this.upvotes,
    required this.verifications,
    this.imageBytes,
    this.distanceKm,
    this.postedByUser = false,
  });

  final String id;
  final String title;
  final String storeName;
  final String category;
  final String description;
  final DateTime expiryDate;
  final double latitude;
  final double longitude;
  final double originalPrice;
  final double dealPrice;
  final String discountLabel;
  final int upvotes;
  final int verifications;
  final Uint8List? imageBytes;
  final double? distanceKm;
  final bool postedByUser;

  double get estimatedSavings => math.max(0, originalPrice - dealPrice);

  CommunityDeal copyWith({
    String? id,
    String? title,
    String? storeName,
    String? category,
    String? description,
    DateTime? expiryDate,
    double? latitude,
    double? longitude,
    double? originalPrice,
    double? dealPrice,
    String? discountLabel,
    int? upvotes,
    int? verifications,
    Uint8List? imageBytes,
    double? distanceKm,
    bool? postedByUser,
  }) {
    return CommunityDeal(
      id: id ?? this.id,
      title: title ?? this.title,
      storeName: storeName ?? this.storeName,
      category: category ?? this.category,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      originalPrice: originalPrice ?? this.originalPrice,
      dealPrice: dealPrice ?? this.dealPrice,
      discountLabel: discountLabel ?? this.discountLabel,
      upvotes: upvotes ?? this.upvotes,
      verifications: verifications ?? this.verifications,
      imageBytes: imageBytes ?? this.imageBytes,
      distanceKm: distanceKm ?? this.distanceKm,
      postedByUser: postedByUser ?? this.postedByUser,
    );
  }
}

class PointsEvent {
  const PointsEvent({
    required this.label,
    required this.points,
    required this.icon,
  });

  final String label;
  final int points;
  final IconData icon;
}

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
  int _onboardingStep = 0;
  int _totalPoints = 1180;
  String _breed = 'tabby';
  String _color = 'mint';
  String _accessory = 'ribbon';
  String _outfit = 'Hoodie';
  double _budget = 1200;
  double _goal = 800;
  LatLng _radarUserLocation = kDefaultRadarCenter;
  Map<String, double> _categoryPercents = <String, double>{
    'Food & drinks': 0.35,
    'Transport': 0.15,
    'Entertainment': 0.12,
    'Bills': 0.23,
    'Shopping': 0.15,
  };
  List<CommunityDeal> _communityDeals = seedDeals();
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
    });
    _awardPoints('Verified a community deal', 20, Icons.verified_rounded);
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
            recentPoints: _recentPoints,
            showAlert: _showHomeAlert,
            onDismissAlert: () => setState(() => _showHomeAlert = false),
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
          const ChallengesPage(),
          InsightsPage(plan: plan, goal: _goal),
          ProfilePage(
            budget: _budget,
            goal: _goal,
            plan: plan,
            totalPoints: _totalPoints,
            onSignOut: () => setState(() {
              _isAuthed = false;
              _isLoginMode = true;
              _showPassword = false;
              _onboardingStep = 0;
              _tabIndex = 0;
              _showHomeAlert = true;
              _totalPoints = 1180;
              _communityDeals = seedDeals();
              _radarUserLocation = kDefaultRadarCenter;
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
      _ShellTab('Quests', Icons.emoji_events_rounded),
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

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.colors.primaryGradient),
        child: Stack(
          children: [
            Positioned(
              left: -80,
              top: 80,
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.35, end: 0.65).animate(_controller),
                child: _blurBall(size: 256, color: Colors.white.withOpacity(0.12)),
              ),
            ),
            Positioned(
              right: -64,
              bottom: 128,
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.25, end: 0.55).animate(_controller),
                child: _blurBall(size: 288, color: context.colors.accent.withOpacity(0.35)),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1.04).animate(_controller),
                      child: Image.asset(
                        'assets/images/thinktwice-logo.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'ThinkTwice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Financial resilience becomes automatic.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.15),
                            duration: Duration(milliseconds: 550 + (index * 130)),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) => Transform.translate(
                              offset: Offset(0, -2 * math.sin(_controller.value * math.pi * 2 + index)),
                              child: Transform.scale(scale: value, child: child),
                            ),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurBall({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 12)],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.isLoginMode,
    required this.showPassword,
    required this.onToggleMode,
    required this.onTogglePassword,
    required this.onContinue,
  });

  final bool isLoginMode;
  final bool showPassword;
  final VoidCallback onToggleMode;
  final VoidCallback onTogglePassword;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: -6,
                          top: -6,
                          child: _floatingDot(context.colors.accent, 32),
                        ),
                        Positioned(
                          left: -8,
                          bottom: -6,
                          child: _floatingDot(context.colors.warning, 24),
                        ),
                        Image.asset(
                          'assets/images/thinktwice-logo.png',
                          width: 160,
                          height: 160,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isLoginMode ? 'Welcome back' : 'Get started',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLoginMode
                        ? 'Sign in to continue your savings streak'
                        : 'Build financial resilience, one tap at a time',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: context.colors.mutedForeground),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.foreground,
                      foregroundColor: context.colors.background,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: context.colors.accent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'GX',
                            style: TextStyle(
                              color: context.colors.accentForeground,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Continue with GXBank', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.colors.mutedForeground,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _inputShell(
                    context,
                    icon: Icons.mail_outline_rounded,
                    suffix: null,
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'aiman@think.co',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _inputShell(
                    context,
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: context.colors.mutedForeground,
                      ),
                    ),
                    child: TextField(
                      obscureText: !showPassword,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '........',
                        isDense: true,
                      ),
                    ),
                  ),
                  if (isLoginMode) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.primary),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  GradientButton(
                    text: isLoginMode ? 'Sign in' : 'Get started',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onContinue,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onContinue,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: context.colors.primary.withOpacity(0.4), width: 2),
                      backgroundColor: context.colors.primary.withOpacity(0.05),
                      foregroundColor: context.colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Use biometric login', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      spacing: 4,
                      children: [
                        Text(
                          isLoginMode ? 'New to ThinkTwice?' : 'Already have an account?',
                          style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                        ),
                        GestureDetector(
                          onTap: onToggleMode,
                          child: Text(
                            isLoginMode ? 'Create account' : 'Sign in',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Skip for now',
                      style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _floatingDot(Color color, double size) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -4, end: 4),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) => Transform.translate(offset: Offset(0, value), child: child),
      onEnd: () {},
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _inputShell(BuildContext context, {required IconData icon, required Widget child, Widget? suffix}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, size: 18, color: context.colors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(child: child),
          if (suffix != null) suffix,
          if (suffix == null) const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.step,
    required this.breed,
    required this.color,
    required this.accessory,
    required this.outfit,
    required this.budget,
    required this.goal,
    required this.categoryPercents,
    required this.plan,
    required this.yesAnswers,
    required this.noAnswers,
    required this.onSetBreed,
    required this.onSetColor,
    required this.onSetAccessory,
    required this.onSetOutfit,
    required this.onSetBudget,
    required this.onSetGoal,
    required this.onSetCategoryPercent,
    required this.onTogglePersonality,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final String breed;
  final String color;
  final String accessory;
  final String outfit;
  final double budget;
  final double goal;
  final Map<String, double> categoryPercents;
  final BudgetPlan plan;
  final Set<int> yesAnswers;
  final Set<int> noAnswers;
  final ValueChanged<String> onSetBreed;
  final ValueChanged<String> onSetColor;
  final ValueChanged<String> onSetAccessory;
  final ValueChanged<String> onSetOutfit;
  final ValueChanged<double> onSetBudget;
  final ValueChanged<double> onSetGoal;
  final void Function(String key, double value) onSetCategoryPercent;
  final void Function(int index, bool yes) onTogglePersonality;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final breeds = [
      ('tabby', 'Tabby', 'Cat'),
      ('calico', 'Calico', 'Calico'),
      ('black', 'Shadow', 'Shadow'),
      ('persian', 'Fluffy', 'Fluffy'),
    ];
    final colors = [
      ('mint', null, context.colors.primaryGradient),
      ('peach', const Color(0xFFE5A36C), null),
      ('sky', const Color(0xFF72B5E8), null),
      ('rose', const Color(0xFFDD7B84), null),
      ('lavender', const Color(0xFFB58ADF), null),
    ];
    final accessories = ['Top Hat', 'Crown', 'Ribbon', 'Glasses', 'Scarf', 'Headphones'];
    final accessoryIcons = ['??', '??', '??', '???', '??', '??'];
    final outfits = ['Hoodie', 'Sweater', 'Jacket', 'T-shirt'];
    final personality = [
      "I overspend when I'm stressed",
      'I love a good deal hunt',
      'I forget to track expenses',
      'I want to save for something specific',
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      final active = index <= step;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? null : context.colors.muted,
                            gradient: active ? context.colors.primaryGradient : null,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            gradient: color == 'mint' ? context.colors.primaryGradient : null,
                            color: switch (color) {
                              'peach' => const Color(0xFFE5A36C),
                              'sky' => const Color(0xFF72B5E8),
                              'rose' => const Color(0xFFDD7B84),
                              'lavender' => const Color(0xFFB58ADF),
                              _ => null,
                            },
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset('assets/images/cat-avatar.png', width: 112, height: 112),
                                ),
                              ),
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: context.colors.card,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    switch (accessory) {
                                      'hat' => '??',
                                      'crown' => '??',
                                      'ribbon' => '??',
                                      'glasses' => '???',
                                      'scarf' => '??',
                                      _ => '??',
                                    },
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${breeds.firstWhere((item) => item.$1 == breed).$2} · $outfit',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: switch (step) {
                        0 => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pick your cat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                'Your finance buddy for the journey',
                                style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                              ),
                              const SizedBox(height: 20),
                              _sectionLabel('Breed', context),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.9,
                                children: List.generate(breeds.length, (index) {
                                  final item = breeds[index];
                                  final selected = breed == item.$1;
                                  return GestureDetector(
                                    onTap: () => onSetBreed(item.$1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selected ? context.colors.primary.withOpacity(0.15) : context.colors.card,
                                        borderRadius: BorderRadius.circular(16),
                                        border: selected ? Border.all(color: context.colors.primary, width: 2) : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/images/cat-avatar.png', width: 38, height: 38),
                                          const SizedBox(height: 6),
                                          Text(item.$2, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              _sectionLabel('Fur color', context),
                              Row(
                                children: colors.map((item) {
                                  final selected = color == item.$1;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () => onSetColor(item.$1),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item.$2,
                                          gradient: item.$3,
                                          border: selected ? Border.all(color: context.colors.foreground, width: 2) : null,
                                          boxShadow: selected ? [BoxShadow(color: context.colors.foreground.withOpacity(0.1), blurRadius: 0, spreadRadius: 4)] : null,
                                        ),
                                        child: selected ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              _sectionLabel('Accessory', context),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 6,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                                children: List.generate(accessories.length, (index) {
                                  final ids = ['hat', 'crown', 'ribbon', 'glasses', 'scarf', 'headphones'];
                                  final selected = accessory == ids[index];
                                  return GestureDetector(
                                    onTap: () => onSetAccessory(ids[index]),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selected ? context.colors.primary.withOpacity(0.15) : context.colors.card,
                                        borderRadius: BorderRadius.circular(16),
                                        border: selected ? Border.all(color: context.colors.primary, width: 2) : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(accessoryIcons[index], style: const TextStyle(fontSize: 24)),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                              _sectionLabel('Starter outfit', context),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 2.5,
                                children: outfits.map((item) {
                                  final selected = outfit == item;
                                  return GestureDetector(
                                    onTap: () => onSetOutfit(item),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: selected ? context.colors.primary.withOpacity(0.15) : context.colors.card,
                                        borderRadius: BorderRadius.circular(16),
                                        border: selected ? Border.all(color: context.colors.primary, width: 2) : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: selected ? context.colors.primary : context.colors.foreground,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        1 => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tell us your money style', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                'Set your monthly income and savings goal. We will calculate your safe daily spending limit automatically.',
                                style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                              ),
                              const SizedBox(height: 20),
                              AmountSliderCard(
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'Monthly income / budget',
                                value: budget,
                                min: 300,
                                max: 5000,
                                step: 100,
                                color: context.colors.primary,
                                fg: Colors.white,
                                onChanged: onSetBudget,
                              ),
                              const SizedBox(height: 12),
                              AmountSliderCard(
                                icon: Icons.track_changes_rounded,
                                label: 'Savings goal',
                                value: goal,
                                min: 100,
                                max: 3000,
                                step: 50,
                                color: context.colors.success,
                                fg: Colors.white,
                                onChanged: onSetGoal,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: context.colors.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estimated safe daily spending limit',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'RM ${formatRm(plan.dailyLimit)} / day',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '(RM ${formatRm(budget)} - RM ${formatRm(goal)}) ÷ 30 days',
                                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.88)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              _sectionLabel('Spending categories', context),
                              Text(
                                'Adjust how your spending pool is split across categories.',
                                style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                              ),
                              const SizedBox(height: 10),
                              ...categoryPercents.entries.map((entry) {
                                final colorMap = <String, Color>{
                                  'Food & drinks': context.colors.warning,
                                  'Transport': context.colors.primary,
                                  'Entertainment': context.colors.accent,
                                  'Bills': context.colors.success,
                                  'Shopping': context.colors.accentForeground,
                                };
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: AllocationSliderCard(
                                    label: entry.key,
                                    percent: entry.value,
                                    amount: plan.flexibleSpend * entry.value,
                                    color: colorMap[entry.key] ?? context.colors.primary,
                                    onChanged: (value) => onSetCategoryPercent(entry.key, value),
                                  ),
                                );
                              }),
                            ],
                          ),
                        _ => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Quick personality check', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                'Optional, but useful. These signals help ThinkTwice fine-tune your limits and rebalance categories over time.',
                                style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                              ),
                              const SizedBox(height: 12),
                              WhiteCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.psychology_alt_rounded, size: 18),
                                        const SizedBox(width: 8),
                                        const Text('Adaptive recommendations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                        const Spacer(),
                                        Text(
                                          '${plan.adaptabilityScore}/100',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...plan.recommendations.map((text) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Icon(Icons.circle, size: 6, color: context.colors.primary),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  text,
                                                  style: TextStyle(fontSize: 12, color: context.colors.foreground, height: 1.35),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(personality.length, (index) {
                                final yes = yesAnswers.contains(index);
                                final no = noAnswers.contains(index);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: context.colors.card,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            personality[index],
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        _pillChoice(
                                          context,
                                          text: 'Yes',
                                          active: yes,
                                          activeColor: context.colors.primary,
                                          activeText: Colors.white,
                                          onTap: () => onTogglePersonality(index, true),
                                        ),
                                        const SizedBox(width: 8),
                                        _pillChoice(
                                          context,
                                          text: 'No',
                                          active: no,
                                          activeColor: context.colors.foreground,
                                          activeText: context.colors.background,
                                          onTap: () => onTogglePersonality(index, false),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: step == 2 ? 'Start saving' : 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onNext,
                  ),
                  if (step > 0) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: onBack,
                        child: Text(
                          'Back',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.mutedForeground),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: context.colors.mutedForeground,
        ),
      ),
    );
  }

  Widget _pillChoice(
    BuildContext context, {
    required String text,
    required bool active,
    required Color activeColor,
    required Color activeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? activeColor : context.colors.muted,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? activeText : context.colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
class AmountSliderCard extends StatelessWidget {
  const AmountSliderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.fg,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final Color color;
  final Color fg;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Icon(icon, color: fg, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
              Text('RM ${value.round()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: context.colors.primary,
              inactiveTrackColor: context.colors.muted,
              thumbColor: context.colors.primary,
              overlayColor: context.colors.primary.withOpacity(0.15),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: ((max - min) / step).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class AllocationSliderCard extends StatelessWidget {
  const AllocationSliderCard({
    super.key,
    required this.label,
    required this.percent,
    required this.amount,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final double percent;
  final double amount;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Text(
                '${formatRm(percent * 100)}% · RM ${formatRm(amount)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: context.colors.muted,
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
            ),
            child: Slider(
              value: percent.clamp(0.05, 0.7),
              min: 0.05,
              max: 0.7,
              divisions: 13,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.plan,
    required this.goal,
    required this.totalPoints,
    required this.recentPoints,
    required this.showAlert,
    required this.onDismissAlert,
    required this.onNavigate,
  });

  final BudgetPlan plan;
  final double goal;
  final int totalPoints;
  final List<PointsEvent> recentPoints;
  final bool showAlert;
  final VoidCallback onDismissAlert;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final overspendingRisk = plan.allocations.firstWhere((item) => item.name == 'Food & drinks').percent >= 0.34;
    final challengeCompleted = true;
    final leveledUp = plan.adaptabilityScore >= 84;
    final savingsWin = plan.savingsRate >= 0.25;
    final emotion = leveledUp
        ? _AvatarMood.excited
        : (overspendingRisk && !showAlert)
            ? _AvatarMood.sad
            : (savingsWin || challengeCompleted)
                ? _AvatarMood.happy
                : _AvatarMood.neutral;
    final level = 1 + (totalPoints ~/ 300);
    final pointsIntoLevel = totalPoints % 300;
    final nextLevelPoints = 300;
    final levelProgress = (pointsIntoLevel / nextLevelPoints).clamp(0.0, 1.0);
    final insights = [
      (
        Icons.wallet_outlined,
        'primary',
        'Safe daily limit: RM ${formatRm(plan.dailyLimit)}',
        'Auto-calculated from your monthly budget and current savings target.',
      ),
      (
        Icons.restaurant_rounded,
        'warning',
        'Food budget is capped at ${formatRm((plan.allocations.firstWhere((item) => item.name == 'Food & drinks').percent) * 100)}%',
        'ThinkTwice will tighten or relax this category as it learns your spending rhythm.',
      ),
      (
        Icons.shield_outlined,
        'success',
        'Savings protected at RM ${formatRm(plan.savingsAmount)}',
        'Your plan keeps goal money aside before flexible spending kicks in.',
      ),
    ];
    final categories = plan.allocations.where((item) => item.name != 'Savings').take(4).toList();
    final trend = [30, 45, 28, 60, 35, 52, 41];
    final goalProgress = (plan.savingsAmount * 0.6 / goal).clamp(0.0, 1.0);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good evening,', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                      const SizedBox(height: 2),
                      const Text('Aiman', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/thinktwice-logo.png',
                    width: 44,
                    height: 44,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GradientCard(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Positioned(
                      right: -32,
                      top: -32,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 30, spreadRadius: 18)],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text('Current balance', style: TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('RM 1,284.50', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Savings goal', style: TextStyle(fontSize: 12, color: Colors.white)),
                            Text(
                              'RM ${formatRm(plan.savingsAmount * 0.6)} / RM ${formatRm(goal)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: goalProgress,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _heroMiniCard(
                                icon: Icons.wallet_rounded,
                                label: 'Daily safe',
                                value: 'RM ${formatRm(plan.dailyLimit)}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _heroMiniCard(
                                icon: Icons.auto_awesome_rounded,
                                label: 'Adaptive score',
                                value: '${plan.adaptabilityScore}',
                              ),
                            ),
                          ],
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
                    Row(
                      children: [
                        _avatarMoodBadge(context, emotion),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Avatar mood', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(
                                _moodLabel(emotion),
                                style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Level $level',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _progressStat(context, 'Total points', '$totalPoints pts'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _progressStat(context, 'Next level', '${nextLevelPoints - pointsIntoLevel} pts left'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('Level progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text(
                          '${formatRm(levelProgress * 100)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: levelProgress,
                        minHeight: 8,
                        backgroundColor: context.colors.muted,
                        valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Recent points earned', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...recentPoints.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Icon(item.icon, size: 18, color: context.colors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(item.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                            Text(
                              '+${item.points}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.success),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: QuickActionCard(icon: Icons.savings_outlined, label: 'Save Now', color: context.colors.primary, onTap: () {})),
                  const SizedBox(width: 10),
                  Expanded(child: QuickActionCard(icon: Icons.map_rounded, label: 'Smart Radar', color: context.colors.accent, onTap: () => onNavigate(1))),
                  const SizedBox(width: 10),
                  Expanded(child: QuickActionCard(icon: Icons.emoji_events_rounded, label: 'Quests', color: context.colors.warning, onTap: () => onNavigate(2))),
                ],
              ),
              const SizedBox(height: 20),
              _sectionHeader(context, 'AI Insights', action: 'See all', onTap: () => onNavigate(3)),
              const SizedBox(height: 8),
              ...insights.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InsightCard(
                      icon: item.$1,
                      tone: item.$2,
                      title: item.$3,
                      body: item.$4,
                    ),
                  )),
              const SizedBox(height: 12),
              WhiteCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('This week', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.colors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.trending_up_rounded, size: 12, color: context.colors.success),
                              const SizedBox(width: 4),
                              Text('-12%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.colors.success)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 96,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(trend.length, (index) {
                          final value = trend[index];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: value.toDouble(),
                                    decoration: BoxDecoration(
                                      color: index == 5 ? null : context.colors.muted,
                                      gradient: index == 5 ? context.colors.primaryGradient : null,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                                    style: TextStyle(fontSize: 9, color: context.colors.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...categories.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(item.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                const Spacer(),
                                Text(
                                  '${formatRm(item.percent * 100)}% | RM ${formatRm(item.amount)}',
                                  style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: item.percent,
                                minHeight: 6,
                                backgroundColor: context.colors.muted,
                                valueColor: AlwaysStoppedAnimation<Color>(item.color),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _sectionHeader(context, 'Squad leaderboard', action: 'View', onTap: () => onNavigate(2), compact: true),
                    const SizedBox(height: 8),
                    ...[
                      (1, 'Mira', 1240, false),
                      (2, 'You', 1180, true),
                      (3, 'Hafiz', 980, false),
                    ].map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.$4 ? context.colors.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: context.colors.muted, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text('${item.$1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                            Text('${item.$3} pts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.primary)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showAlert)
          Positioned.fill(
            child: AIInterventionModal(onClose: onDismissAlert),
          ),
      ],
    );
  }

  Widget _heroMiniCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9))),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class RadarPage extends StatefulWidget {
  const RadarPage({
    super.key,
    required this.deals,
    required this.userLocation,
    required this.onLocationChanged,
    required this.onPostDeal,
    required this.onUpvoteDeal,
    required this.onVerifyDeal,
  });

  final List<CommunityDeal> deals;
  final LatLng userLocation;
  final ValueChanged<LatLng> onLocationChanged;
  final ValueChanged<CommunityDeal> onPostDeal;
  final ValueChanged<String> onUpvoteDeal;
  final ValueChanged<String> onVerifyDeal;

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  GoogleMapController? _mapController;
  CommunityDeal? _selectedDeal;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedDeal = widget.deals.isNotEmpty ? _withDistance(widget.deals.first) : null;
    _detectLocation();
  }

  @override
  void didUpdateWidget(covariant RadarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedDeal != null) {
      final updated = widget.deals.where((deal) => deal.id == _selectedDeal!.id);
      if (updated.isNotEmpty) {
        _selectedDeal = _withDistance(updated.first);
      }
    } else if (widget.deals.isNotEmpty) {
      _selectedDeal = _withDistance(widget.deals.first);
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final current = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      widget.onLocationChanged(current);
      _mapController?.animateCamera(CameraUpdate.newLatLng(current));
      setState(() {
        if (_selectedDeal != null) {
          _selectedDeal = _withDistance(_selectedDeal!);
        }
      });
    } catch (_) {
      // Keep the default center when location is unavailable.
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  CommunityDeal _withDistance(CommunityDeal deal) {
    final meters = Geolocator.distanceBetween(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
      deal.latitude,
      deal.longitude,
    );
    return deal.copyWith(distanceKm: meters / 1000);
  }

  Set<Marker> _markers(BuildContext context) {
    return {
      Marker(
        markerId: const MarkerId('user'),
        position: widget.userLocation,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      ...widget.deals.map((deal) {
        final enhanced = _withDistance(deal);
        return Marker(
          markerId: MarkerId(deal.id),
          position: LatLng(deal.latitude, deal.longitude),
          infoWindow: InfoWindow(
            title: deal.title,
            snippet: '${deal.storeName} • Save RM ${formatRm(deal.estimatedSavings)}',
          ),
          onTap: () {
            setState(() => _selectedDeal = enhanced);
          },
        );
      }),
    };
  }

  Set<Polyline> _polylines() {
    if (_selectedDeal == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('selected-route'),
        width: 5,
        color: const Color(0xFF41B89B),
        points: [
          widget.userLocation,
          LatLng(_selectedDeal!.latitude, _selectedDeal!.longitude),
        ],
      ),
    };
  }

  Future<void> _openPostDealSheet() async {
    final newDeal = await showModalBottomSheet<CommunityDeal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDealSheet(userLocation: widget.userLocation),
    );

    if (!mounted || newDeal == null) return;
    widget.onPostDeal(newDeal);
    setState(() => _selectedDeal = _withDistance(newDeal));
    _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(newDeal.latitude, newDeal.longitude)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Deal posted! You earned points for helping others save.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF41B89B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDeals = widget.deals.map(_withDistance).toList()
      ..sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    final selected = _selectedDeal != null ? _withDistance(_selectedDeal!) : (sortedDeals.isNotEmpty ? sortedDeals.first : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Smart Radar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Deals, routes, and community savings near you', style: TextStyle(fontSize: 14, color: context.colors.mutedForeground)),
          const SizedBox(height: 20),
          GradientCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You saved this month', style: TextStyle(fontSize: 12, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'RM ${formatRm(widget.deals.fold<double>(0, (sum, deal) => sum + deal.estimatedSavings))}',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _loadingLocation ? 'Detecting your location...' : 'Live nearby deals and estimated savings',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: widget.userLocation, zoom: 14.2),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: _markers(context),
                polylines: _polylines(),
                onMapCreated: (controller) => _mapController = controller,
                onTap: (_) => setState(() => _selectedDeal = null),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selected != null)
            WhiteCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.route_rounded, color: context.colors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            Text(selected.storeName, style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _progressStat(context, 'Distance', '${selected.distanceKm?.toStringAsFixed(2) ?? '--'} km')),
                      const SizedBox(width: 10),
                      Expanded(child: _progressStat(context, 'Estimated savings', 'RM ${formatRm(selected.estimatedSavings)}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(selected.description, style: TextStyle(fontSize: 12, height: 1.4, color: context.colors.mutedForeground)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text('Deal route ready', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.success)),
                        const Spacer(),
                        Text('Save ${selected.discountLabel.replaceFirst('Save ', '')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.success)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Community deals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              FilledButton(
                onPressed: _openPostDealSheet,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14),
                    SizedBox(width: 4),
                    Text('Post Community Deal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...sortedDeals.map((deal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WhiteCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: context.colors.warning.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: deal.imageBytes != null
                              ? Image.memory(deal.imageBytes!, fit: BoxFit.cover)
                              : Icon(Icons.storefront_rounded, size: 24, color: context.colors.accentForeground),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(deal.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${deal.storeName} • ${deal.category}', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                              const SizedBox(height: 4),
                              Text(
                                '${deal.distanceKm?.toStringAsFixed(2) ?? '--'} km away • expires ${deal.expiryDate.day}/${deal.expiryDate.month}',
                                style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedDeal = deal);
                            _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(deal.latitude, deal.longitude)));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.success.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Save RM ${formatRm(deal.estimatedSavings)}',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.success),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => widget.onUpvoteDeal(deal.id),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                            label: Text('Upvote ${deal.upvotes}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => widget.onVerifyDeal(deal.id),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.verified_rounded, size: 16),
                            label: Text('Verify ${deal.verifications}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

}

class PostDealSheet extends StatefulWidget {
  const PostDealSheet({super.key, required this.userLocation});

  final LatLng userLocation;

  @override
  State<PostDealSheet> createState() => _PostDealSheetState();
}

class _PostDealSheetState extends State<PostDealSheet> {
  final _titleController = TextEditingController();
  final _storeController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Food & drinks');
  final _originalPriceController = TextEditingController();
  final _dealPriceController = TextEditingController();
  final _locationController = TextEditingController(text: 'Use current location');
  final _descriptionController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 2));
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _storeController.dispose();
    _categoryController.dispose();
    _originalPriceController.dispose();
    _dealPriceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  void _submit() {
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0;
    final dealPrice = double.tryParse(_dealPriceController.text) ?? 0;
    if (_titleController.text.trim().isEmpty ||
        _storeController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        originalPrice <= 0 ||
        dealPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the deal form before posting.')),
      );
      return;
    }

    final newDeal = CommunityDeal(
      id: 'deal-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      storeName: _storeController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? 'Community-submitted savings deal.' : _descriptionController.text.trim(),
      expiryDate: _expiryDate,
      latitude: widget.userLocation.latitude + 0.0025,
      longitude: widget.userLocation.longitude + 0.0025,
      originalPrice: originalPrice,
      dealPrice: dealPrice,
      discountLabel: 'Save RM ${formatRm(originalPrice - dealPrice)}',
      upvotes: 1,
      verifications: 0,
      imageBytes: _imageBytes,
      postedByUser: true,
    );

    Navigator.of(context).pop(newDeal);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.65,
        maxChildSize: 0.96,
        builder: (context, controller) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3ECE6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Post Community Deal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Help others save nearby and earn points for the community.', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                const SizedBox(height: 16),
                _dealField(controller: _titleController, label: 'Deal title'),
                const SizedBox(height: 10),
                _dealField(controller: _storeController, label: 'Store name'),
                const SizedBox(height: 10),
                _dealField(controller: _categoryController, label: 'Category'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _dealField(controller: _originalPriceController, label: 'Original price')),
                    const SizedBox(width: 10),
                    Expanded(child: _dealField(controller: _dealPriceController, label: 'Price / discount')),
                  ],
                ),
                const SizedBox(height: 10),
                _dealField(controller: _locationController, label: 'Location'),
                const SizedBox(height: 10),
                _dealField(controller: _descriptionController, label: 'Description', maxLines: 3),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      initialDate: _expiryDate,
                    );
                    if (picked != null) {
                      setState(() => _expiryDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE3ECE6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Expiry date: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(_imageBytes == null ? 'Upload image' : 'Image selected'),
                ),
                if (_imageBytes != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(_imageBytes!, height: 140, fit: BoxFit.cover),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF41B89B),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Submit deal'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dealField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3ECE6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3ECE6)),
        ),
      ),
    );
  }
}

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key, required this.plan, required this.goal});

  final BudgetPlan plan;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final trend = [40, 55, 38, 62, 45, 70, 48, 30, 52, 60, 35, 42];
    final savings = [10, 25, 18, 35, 42, 50, 47];
    final foodAllocation = plan.allocations.firstWhere((item) => item.name == 'Food & drinks');
    final topAllocations = plan.allocations.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Insights', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Your AI financial intelligence', style: TextStyle(fontSize: 14, color: context.colors.mutedForeground)),
          const SizedBox(height: 16),
          ...[
            (Icons.schedule_rounded, true, 'You overspend most after 10PM', '62% of impulse purchases happen late at night.'),
            (
              Icons.trending_up_rounded,
              true,
              'Food budget rebalanced to ${formatRm(foodAllocation.percent * 100)}%',
              'If food keeps trending high, ThinkTwice can tighten lifestyle categories before it touches your essentials.',
            ),
            (
              Icons.track_changes_rounded,
              false,
              'Safe daily spend is RM ${formatRm(plan.dailyLimit)}',
              'You\'re on track to save RM ${formatRm(goal)} with an auto-protected monthly savings bucket of RM ${formatRm(plan.savingsAmount)}.',
            ),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InsightCard(
                  icon: item.$1,
                  tone: item.$2 ? 'warning' : 'primary',
                  title: item.$3,
                  body: item.$4,
                ),
              )),
          const SizedBox(height: 8),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Spending trend (12 weeks)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 128,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(trend.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            height: trend[index].toDouble(),
                            decoration: BoxDecoration(
                              color: index == trend.length - 1 ? null : context.colors.muted,
                              gradient: index == trend.length - 1 ? context.colors.primaryGradient : null,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      );
                    }),
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
                const Text('Adaptive category mix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...topAllocations.map((allocation) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(allocation.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              '${formatRm(allocation.percent * 100)}% | RM ${formatRm(allocation.amount)}',
                              style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: allocation.percent,
                            minHeight: 6,
                            backgroundColor: context.colors.muted,
                            valueColor: AlwaysStoppedAnimation<Color>(allocation.color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Text(
                  plan.recommendations.last,
                  style: TextStyle(fontSize: 12, height: 1.35, color: context.colors.mutedForeground),
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
                const Text('Savings momentum', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('+RM 47', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: context.colors.success)),
                Text('vs last week', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(savings.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                            height: savings[index] + 30,
                            decoration: BoxDecoration(
                              gradient: context.colors.warmGradient,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      );
                    }),
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
                    Icon(Icons.warning_amber_rounded, size: 16, color: context.colors.accentForeground),
                    const SizedBox(width: 8),
                    const Text('Risk alert history', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  ('Today', 'High food spending risk', context.colors.warning),
                  ('Yesterday', 'Late-night impulse buy avoided', context.colors.success),
                  ('2 days ago', 'Budget threshold crossed', context.colors.warning),
                ].map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(width: 2, height: 34, color: item.$3),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text(item.$1, style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
                            ],
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
          GradientCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('AI Recommendation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  plan.recommendations.first,
                  style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = [
      ('3-Day No Overspending', 0.66, '2/3', '150 pts', false),
      ('7-Day Savings Streak', 1.0, '7/7', '500 pts', true),
      ('Food Budget Challenge', 0.4, 'RM80/200', 'Cat hat', false),
    ];
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
      (2, 'You', 1180, Icons.pets_rounded),
      (3, 'Hafiz', 980, Icons.auto_awesome_rounded),
      (4, 'Lina', 760, Icons.favorite_rounded),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quests', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Earn rewards for smart spending', style: TextStyle(fontSize: 14, color: context.colors.mutedForeground)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientCard(
                  gradient: context.colors.warmGradient,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
                      SizedBox(height: 8),
                      Text('7', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('Risk avoidance streak', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientCard(
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                      SizedBox(height: 8),
                      Text('12', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('Smart spending streak', style: TextStyle(fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Active quests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...challenges.map((item) {
            return Padding(
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
                                  if (item.$5) Icon(Icons.check_circle_rounded, size: 16, color: context.colors.success),
                                  if (item.$5) const SizedBox(width: 6),
                                  Expanded(child: Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(item.$3, style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.accent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(item.$4, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.accentForeground)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.$2,
                        minHeight: 8,
                        backgroundColor: context.colors.muted,
                        valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
                      ),
                    ),
                    if (item.$5) ...[
                      const SizedBox(height: 12),
                      const GradientButton(text: 'Claim reward', compact: true),
                    ],
                  ],
                ),
              ),
            );
          }),
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
            onPressed: () {},
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
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.budget,
    required this.goal,
    required this.plan,
    required this.totalPoints,
    required this.onSignOut,
  });

  final double budget;
  final double goal;
  final BudgetPlan plan;
  final int totalPoints;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final tx = [
      ('Starbucks', -12, Icons.coffee_rounded, '2h ago'),
      ('Tealive', -9, Icons.local_drink_rounded, 'Yesterday'),
      ('GrabFood', -24, Icons.lunch_dining_rounded, 'Yesterday'),
      ('Salary', 2400, Icons.payments_rounded, '3 days ago'),
      ('Shopee', -45, Icons.shopping_bag_rounded, '4 days ago'),
    ];

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
                  children: [
                    Image.asset(
                      'assets/images/cat-avatar.png',
                      width: 96,
                      height: 96,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aiman', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        const Text('Level 4 | Saver', style: TextStyle(fontSize: 12, color: Colors.white)),
                        const SizedBox(height: 8),
                        _PointsChip(totalPoints: totalPoints),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader(context, 'Reward shop', action: 'View all', onTap: () {}),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _shopTile(context, Icons.workspace_premium_rounded, 'Crown', '200 pts', false)),
              const SizedBox(width: 10),
              Expanded(child: _shopTile(context, Icons.checkroom_rounded, 'Hoodie', 'Owned', true)),
              const SizedBox(width: 10),
              Expanded(child: _shopTile(context, Icons.auto_awesome_rounded, 'Sparkle', '350 pts', false)),
            ],
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...tx.map((item) {
                  final positive = item.$2 > 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: context.colors.muted, borderRadius: BorderRadius.circular(16)),
                          alignment: Alignment.center,
                          child: Icon(item.$3, size: 20, color: context.colors.foreground),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text(item.$4, style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
                            ],
                          ),
                        ),
                        Text(
                          '${positive ? '+' : ''}RM${item.$2.abs()}',
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
                _settingsRow(context, Icons.notifications_none_rounded, 'Notifications', 'On', true),
                _settingsRow(context, Icons.settings_outlined, 'Auto-save approval', '${formatRm(plan.savingsRate * 100)}% auto-save', false),
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

  Widget _shopTile(BuildContext context, IconData icon, String name, String price, bool owned) {
    return WhiteCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.accent.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 24, color: context.colors.accentForeground),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            price,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: owned ? context.colors.success : context.colors.primary,
            ),
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
}

class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.totalPoints});

  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text('$totalPoints pts', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class AIInterventionModal extends StatelessWidget {
  const AIInterventionModal({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.colors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.warning_amber_rounded, size: 24, color: context.colors.accentForeground),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Risk detected', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: Color(0xFF8F6412))),
                            SizedBox(height: 2),
                            Text('High Spending Risk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: Icon(Icons.close_rounded),
                        color: Color(0xFF6B847E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.muted.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Your food spending today is already 42% above average. Save RM8 now to maintain your streak.',
                      style: TextStyle(fontSize: 14, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const GradientButton(text: 'Save RM8 now', icon: Icons.savings_outlined),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: onClose,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Find cheaper alternatives', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onClose,
                    child: Text('Ignore', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (color == context.colors.primary) {
      bg = context.colors.primary.withOpacity(0.1);
      fg = context.colors.primary;
    } else if (color == context.colors.accent) {
      bg = context.colors.accent.withOpacity(0.3);
      fg = context.colors.accentForeground;
    } else {
      bg = context.colors.warning.withOpacity(0.2);
      fg = context.colors.accentForeground;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String tone;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    switch (tone) {
      case 'warning':
        bg = context.colors.warning.withOpacity(0.15);
        fg = context.colors.accentForeground;
        break;
      case 'success':
        bg = context.colors.success.withOpacity(0.15);
        fg = context.colors.success;
        break;
      default:
        bg = context.colors.primary.withOpacity(0.15);
        fg = context.colors.primary;
    }

    return WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _AvatarMood { happy, neutral, sad, excited }

String _moodLabel(_AvatarMood mood) {
  switch (mood) {
    case _AvatarMood.happy:
      return 'Happy and celebrating';
    case _AvatarMood.neutral:
      return 'Calm and on track';
    case _AvatarMood.sad:
      return 'Worried about overspending';
    case _AvatarMood.excited:
      return 'Excited about leveling up';
  }
}

Widget _avatarMoodBadge(BuildContext context, _AvatarMood mood) {
  final moodConfig = switch (mood) {
    _AvatarMood.happy => (context.colors.success, Icons.sentiment_satisfied_alt_rounded),
    _AvatarMood.neutral => (context.colors.primary, Icons.sentiment_neutral_rounded),
    _AvatarMood.sad => (context.colors.warning, Icons.sentiment_dissatisfied_rounded),
    _AvatarMood.excited => (context.colors.accentForeground, Icons.bolt_rounded),
  };

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/images/cat-avatar.png'),
      ),
      Positioned(
        right: -4,
        top: -4,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: moodConfig.$1,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(moodConfig.$2, size: 16, color: Colors.white),
        ),
      ),
    ],
  );
}

Widget _progressStat(BuildContext context, String label, String value) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colors.muted.withOpacity(0.65),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.compact = false,
  });

  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(compact ? 12 : 16),
      onTap: onPressed,
      child: Ink(
        height: compact ? 36 : 48,
        decoration: BoxDecoration(
          gradient: context.colors.primaryGradient,
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 14, fontWeight: FontWeight.w700)),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: compact ? 14 : 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? context.colors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.colors.softShadow,
      ),
      child: child,
    );
  }
}

class WhiteCard extends StatelessWidget {
  const WhiteCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget _sectionHeader(BuildContext context, String title, {required String action, required VoidCallback onTap, bool compact = false}) {
  return Row(
    children: [
      Text(title, style: TextStyle(fontSize: compact ? 14 : 14, fontWeight: FontWeight.w700)),
      const Spacer(),
      GestureDetector(
        onTap: onTap,
        child: Text(action, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.primary)),
      ),
    ],
  );
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;

    const step = 25.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

