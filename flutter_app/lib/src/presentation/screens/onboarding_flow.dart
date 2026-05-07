import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/app_models.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({
    required this.state,
    required this.onContinue,
    required this.onBack,
    required this.onSetIncome,
    required this.onSetHabit,
    required this.onToggleGoal,
    required this.onToggleConcern,
    required this.onSetDailyBudget,
    required this.onSetAutoSaveRate,
    required this.onToggleAlerts,
    required this.onSetBreed,
    required this.onSetHat,
    required this.onToggleGlasses,
    required this.onSetCatName,
    required this.onSkipToDemo,
    super.key,
  });

  final AppState state;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final ValueChanged<String> onSetIncome;
  final ValueChanged<String> onSetHabit;
  final ValueChanged<String> onToggleGoal;
  final ValueChanged<String> onToggleConcern;
  final ValueChanged<double> onSetDailyBudget;
  final ValueChanged<double> onSetAutoSaveRate;
  final ValueChanged<bool> onToggleAlerts;
  final ValueChanged<CatBreed> onSetBreed;
  final ValueChanged<CatHat> onSetHat;
  final VoidCallback onToggleGlasses;
  final ValueChanged<String> onSetCatName;
  final VoidCallback onSkipToDemo;

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: switch (state.onboardingStep) {
          0 => SplashScreen(
              key: const ValueKey('splash'),
              onContinue: onContinue,
              onSkipToDemo: onSkipToDemo,
            ),
          1 => WelcomeScreen(
              key: const ValueKey('welcome'),
              onContinue: onContinue,
            ),
          2 => ProfileSetupScreen(
              key: const ValueKey('profile'),
              profile: state.profile,
              onBack: onBack,
              onContinue: onContinue,
              onSetIncome: onSetIncome,
              onSetHabit: onSetHabit,
              onToggleGoal: onToggleGoal,
              onToggleConcern: onToggleConcern,
            ),
          3 => BudgetSetupScreen(
              key: const ValueKey('budget'),
              profile: state.profile,
              onBack: onBack,
              onContinue: onContinue,
              onSetDailyBudget: onSetDailyBudget,
              onSetAutoSaveRate: onSetAutoSaveRate,
              onToggleAlerts: onToggleAlerts,
            ),
          4 => AvatarCreationScreen(
              key: const ValueKey('avatar'),
              profile: state.profile,
              onBack: onBack,
              onContinue: onContinue,
              onSetBreed: onSetBreed,
              onSetHat: onSetHat,
              onToggleGlasses: onToggleGlasses,
              onSetCatName: onSetCatName,
            ),
          _ => InitScreen(
              key: const ValueKey('init'),
              onFinished: onContinue,
              catBreed: state.profile.catBreed,
            ),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.onContinue,
    required this.onSkipToDemo,
    super.key,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkipToDemo;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const _PulseRing(delay: 0),
                const _PulseRing(delay: 800),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(colors: AppColors.aiGradient),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ai.withValues(alpha: 0.36),
                        blurRadius: 36,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
              children: [
                TextSpan(text: 'Think'),
                TextSpan(text: 'Twice', style: TextStyle(color: AppColors.ai)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Financial resilience by design.',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const Spacer(),
          if (_ready)
            Column(
              children: [
                GradientButton(
                  label: 'Get Started',
                  gradient: AppColors.aiGradient,
                  textColor: Colors.white,
                  onTap: widget.onContinue,
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: widget.onSkipToDemo,
                  child: const Text(
                    'Skip to demo',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ],
            )
          else
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.surfaceStrong,
                borderRadius: BorderRadius.circular(99),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.33,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.aiGradient),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final features = const [
      (
        icon: Icons.account_balance_wallet_rounded,
        title: 'Real-time spending intelligence',
        detail: 'Predicts overspending before it happens',
      ),
      (
        icon: Icons.shield_rounded,
        title: 'Autonomous savings protection',
        detail: 'AI moves money to your vault when risk spikes',
      ),
      (
        icon: Icons.fingerprint_rounded,
        title: 'Habit-building rewards',
        detail: 'Streaks, squads, and a pixel cat that grows with you',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          Align(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              radius: 999,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 14, color: AppColors.ai),
                  SizedBox(width: 8),
                  Text(
                    'Bank-grade security',
                    style: TextStyle(fontSize: 12, color: AppColors.ai),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Your AI financial\nguardian awaits.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 12),
          const Text(
            'Connect GXBank in 30 seconds. ThinkTwice handles the rest.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 28),
          for (final feature in features) ...[
            GlassCard(
              padding: const EdgeInsets.all(16),
              radius: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.aiGradient),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(feature.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.detail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          GradientButton(
            label: 'Sign in with GXBank',
            gradient: AppColors.emeraldGradient,
            onTap: onContinue,
          ),
          const SizedBox(height: 12),
          GlassCard(
            strong: true,
            radius: 22,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint_rounded, size: 18, color: AppColors.ai),
                SizedBox(width: 10),
                Text(
                  'Use Face ID',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'By continuing you agree to our Terms · 256-bit encrypted',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({
    required this.profile,
    required this.onBack,
    required this.onContinue,
    required this.onSetIncome,
    required this.onSetHabit,
    required this.onToggleGoal,
    required this.onToggleConcern,
    super.key,
  });

  final UserProfileModel profile;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final ValueChanged<String> onSetIncome;
  final ValueChanged<String> onSetHabit;
  final ValueChanged<String> onToggleGoal;
  final ValueChanged<String> onToggleConcern;

  @override
  Widget build(BuildContext context) {
    const incomes = ['< RM500', 'RM500 – 1,500', 'RM1,500 – 3,000', 'RM3,000+'];
    const habits = ['Saver', 'Balanced', 'Spender', 'YOLO'];
    const goals = ['Emergency fund', 'First car', 'Travel', 'Tech gear', 'Investment'];
    const concerns = ['Late-night food', 'Online shopping', 'Subscriptions', 'Cafés', 'Grab rides'];

    return _OnboardingScaffold(
      title: 'Financial profile',
      step: 1,
      onBack: onBack,
      onContinue: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabelledWrap(
            label: 'Monthly income',
            children: [
              for (final item in incomes)
                AppChipToggle(
                  label: item,
                  active: profile.income == item,
                  onTap: () => onSetIncome(item),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _LabelledWrap(
            label: 'Spending habit',
            children: [
              for (final item in habits)
                AppChipToggle(
                  label: item,
                  active: profile.habit == item,
                  onTap: () => onSetHabit(item),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _LabelledWrap(
            label: 'Top savings goals',
            children: [
              for (final item in goals)
                AppChipToggle(
                  label: item,
                  active: profile.goals.contains(item),
                  onTap: () => onToggleGoal(item),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _LabelledWrap(
            label: 'Biggest spending concerns',
            children: [
              for (final item in concerns)
                AppChipToggle(
                  label: item,
                  active: profile.concerns.contains(item),
                  onTap: () => onToggleConcern(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class BudgetSetupScreen extends StatelessWidget {
  const BudgetSetupScreen({
    required this.profile,
    required this.onBack,
    required this.onContinue,
    required this.onSetDailyBudget,
    required this.onSetAutoSaveRate,
    required this.onToggleAlerts,
    super.key,
  });

  final UserProfileModel profile;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final ValueChanged<double> onSetDailyBudget;
  final ValueChanged<double> onSetAutoSaveRate;
  final ValueChanged<bool> onToggleAlerts;

  @override
  Widget build(BuildContext context) {
    final categories = const [
      (icon: Icons.local_cafe_rounded, name: 'Food & Drinks', value: 18),
      (icon: Icons.shopping_bag_rounded, name: 'Shopping', value: 10),
      (icon: Icons.directions_bus_rounded, name: 'Transport', value: 8),
      (icon: Icons.movie_creation_outlined, name: 'Entertainment', value: 5),
      (icon: Icons.menu_book_rounded, name: 'Study', value: 4),
    ];

    return _OnboardingScaffold(
      title: 'Budget preferences',
      step: 2,
      onBack: onBack,
      onContinue: onContinue,
      child: Column(
        children: [
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Daily budget',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'RM${profile.dailyBudget.toInt()}',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Slider(
                  min: 10,
                  max: 150,
                  value: profile.dailyBudget,
                  onChanged: onSetDailyBudget,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Auto-save % of income',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${profile.autoSaveRate.toInt()}%',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
                Slider(
                  min: 5,
                  max: 50,
                  value: profile.autoSaveRate,
                  onChanged: onSetAutoSaveRate,
                ),
                Text(
                  '≈ RM${(2000 * profile.autoSaveRate / 100).round()} saved every payday',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'CATEGORY LIMITS / DAY',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final category in categories) ...[
            GlassCard(
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(category.icon, color: AppColors.ai),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    'RM${category.value}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          GlassCard(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending alerts',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Real-time risk nudges',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: profile.spendingAlerts,
                  onChanged: onToggleAlerts,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.emerald,
                  inactiveTrackColor: AppColors.surfaceStrong,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarCreationScreen extends StatelessWidget {
  const AvatarCreationScreen({
    required this.profile,
    required this.onBack,
    required this.onContinue,
    required this.onSetBreed,
    required this.onSetHat,
    required this.onToggleGlasses,
    required this.onSetCatName,
    super.key,
  });

  final UserProfileModel profile;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final ValueChanged<CatBreed> onSetBreed;
  final ValueChanged<CatHat> onSetHat;
  final VoidCallback onToggleGlasses;
  final ValueChanged<String> onSetCatName;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Meet your money cat',
      step: 3,
      onBack: onBack,
      onContinue: onContinue,
      continueLabel: 'Hatch my cat',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            strong: true,
            radius: 28,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.ai.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    PixelCatWidget(
                      breed: profile.catBreed,
                      size: 180,
                      hat: profile.catHat,
                      glasses: profile.catGlasses,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'LVL 1 · STARTER',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: profile.catName,
                  onChanged: onSetCatName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: const InputDecoration(
                    filled: false,
                    hintText: 'Cat name',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'BREED',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CatBreed.values.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final breed = CatBreed.values[index];
                return InkWell(
                  onTap: () => onSetBreed(breed),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 88,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: breed == profile.catBreed
                          ? const LinearGradient(colors: AppColors.aiGradient)
                          : null,
                      color: breed == profile.catBreed
                          ? null
                          : AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PixelCatWidget(breed: breed, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          _breedLabel(breed),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: breed == profile.catBreed
                                ? Colors.white
                                : AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'HAT',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final hat in CatHat.values)
                AppChipToggle(
                  label: switch (hat) {
                    CatHat.none => 'None',
                    CatHat.cap => 'Cap',
                    CatHat.crown => 'Crown',
                  },
                  active: profile.catHat == hat,
                  onTap: () => onSetHat(hat),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'ACCESSORY',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          AppChipToggle(
            label: profile.catGlasses ? 'Pixel Glasses ✓' : 'Pixel Glasses',
            active: profile.catGlasses,
            onTap: onToggleGlasses,
          ),
        ],
      ),
    );
  }

  String _breedLabel(CatBreed breed) {
    switch (breed) {
      case CatBreed.orangeTabby:
        return 'Orange Tabby';
      case CatBreed.britishShorthair:
        return 'British Shorthair';
      case CatBreed.siamese:
        return 'Siamese';
      case CatBreed.persian:
        return 'Persian';
      case CatBreed.calico:
        return 'Calico';
      case CatBreed.tuxedo:
        return 'Tuxedo';
      case CatBreed.ragdoll:
        return 'Ragdoll';
    }
  }
}

class InitScreen extends StatefulWidget {
  const InitScreen({
    required this.onFinished,
    required this.catBreed,
    super.key,
  });

  final VoidCallback onFinished;
  final CatBreed catBreed;

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  static const _steps = [
    'Encrypting GXBank link…',
    'Analyzing 90 days of transactions…',
    'Training behavioral model…',
    'Calibrating Resilience Score…',
    'Waking up your money cat…',
  ];

  late Timer _timer;
  int _done = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (_done >= _steps.length) {
        timer.cancel();
        return;
      }
      setState(() => _done += 1);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _done >= _steps.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (!ready) const _PulseRing(delay: 0),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.aiGradient),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ready
                    ? Center(
                        child: PixelCatWidget(
                          breed: widget.catBreed,
                          size: 64,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            ready ? "You're all set" : 'Initializing your guardian',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            ready
                ? 'Mochi is ready to protect your wallet.'
                : 'This takes about 3 seconds.',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 26),
          for (var i = 0; i < _steps.length; i++) ...[
            GlassCard(
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: i < _done ? AppColors.emerald : AppColors.surfaceStrong,
                      shape: BoxShape.circle,
                    ),
                    child: i < _done
                        ? const Icon(Icons.check_rounded, size: 16, color: AppColors.background)
                        : Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.muted,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _steps[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: i < _done ? AppColors.text : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (ready) ...[
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: _InitStat(label: 'Resilience', value: '50')),
                SizedBox(width: 10),
                Expanded(child: _InitStat(label: 'Streak', value: '0d')),
                SizedBox(width: 10),
                Expanded(child: _InitStat(label: 'Vault', value: 'RM0')),
              ],
            ),
            const Spacer(),
            GradientButton(
              label: 'Enter ThinkTwice',
              gradient: AppColors.emeraldGradient,
              icon: Icons.arrow_forward_rounded,
              onTap: widget.onFinished,
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.title,
    required this.step,
    required this.onBack,
    required this.onContinue,
    required this.child,
    this.continueLabel = 'Continue',
  });

  final String title;
  final int step;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final Widget child;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(14),
                child: GlassCard(
                  padding: const EdgeInsets.all(10),
                  radius: 14,
                  child: const Icon(Icons.chevron_left_rounded, size: 20),
                ),
              ),
              const Spacer(),
              Text(
                'Step $step of 4',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const Spacer(),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: step / 4,
              minHeight: 6,
              backgroundColor: AppColors.surfaceStrong,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.ai),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(child: child),
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: continueLabel,
            gradient: AppColors.emeraldGradient,
            icon: Icons.arrow_forward_rounded,
            onTap: onContinue,
          ),
        ],
      ),
    );
  }
}

class _LabelledWrap extends StatelessWidget {
  const _LabelledWrap({
    required this.label,
    required this.children,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: children),
      ],
    );
  }
}

class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.delay});

  final int delay;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = Curves.easeOut.transform(_controller.value);
        final scale = lerpDouble(0.8, 2.4, value)!;
        final opacity = lerpDouble(0.8, 0, value)!;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ai.withValues(alpha: opacity * 0.35),
            ),
          ),
        );
      },
    );
  }
}

class _InitStat extends StatelessWidget {
  const _InitStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      strong: true,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.1,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
