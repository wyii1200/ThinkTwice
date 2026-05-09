import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
import '../services/auth_service.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
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
                      child: Image.asset('assets/images/thinktwice-logo.png', width: 150, height: 150),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'ThinkTwice',
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Financial resilience becomes automatic.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
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


class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onAuthSuccess});

  /// Called with (uid, displayName) after a successful sign-in or sign-up.
  final void Function(String uid, String displayName) onAuthSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginMode = true;
  bool _showPassword = false;
  bool _loading = false;
  String? _errorMessage;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMessage = null; });

    try {
      User user;
      if (_isLoginMode) {
        user = await AuthService.signIn(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      } else {
        user = await AuthService.signUp(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text,
        );
      }
      final name = user.displayName?.isNotEmpty == true
          ? user.displayName!
          : user.email?.split('@')[0] ?? 'Friend';
      if (mounted) widget.onAuthSuccess(user.uid, name);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = AuthService.friendlyError(e));
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(right: -6, top: -6, child: _floatingDot(context.colors.accent, 32)),
                          Positioned(left: -8, bottom: -6, child: _floatingDot(context.colors.warning, 24)),
                          Image.asset('assets/images/thinktwice-logo.png', width: 160, height: 160),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isLoginMode ? 'Welcome back' : 'Get started',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoginMode
                          ? 'Sign in to continue your savings streak'
                          : 'Build financial resilience, one tap at a time',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: context.colors.mutedForeground),
                    ),
                    const SizedBox(height: 24),

                    // Error banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.colors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.colors.warning.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 16, color: context.colors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.colors.foreground),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Name field (sign-up only)
                    if (!_isLoginMode) ...[
                      _inputShell(
                        context,
                        icon: Icons.person_outline_rounded,
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Your name (e.g. Aiman)',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Email field
                    _inputShell(
                      context,
                      icon: Icons.mail_outline_rounded,
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'you@example.com',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password field
                    _inputShell(
                      context,
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: context.colors.mutedForeground,
                        ),
                      ),
                      child: TextFormField(
                        controller: _passwordCtrl,
                        obscureText: !_showPassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (!_isLoginMode && v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit button
                    _loading
                        ? Center(
                            child: SizedBox(
                              height: 48,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: context.colors.primary,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          )
                        : GradientButton(
                            text: _isLoginMode ? 'Sign in' : 'Create account',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _submit,
                          ),
                    const SizedBox(height: 16),

                    // Toggle mode
                    Center(
                      child: Wrap(
                        spacing: 4,
                        children: [
                          Text(
                            _isLoginMode ? 'New to ThinkTwice?' : 'Already have an account?',
                            style: TextStyle(fontSize: 13, color: context.colors.mutedForeground),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _isLoginMode = !_isLoginMode;
                              _errorMessage = null;
                            }),
                            child: Text(
                              _isLoginMode ? 'Create account' : 'Sign in',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
      child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }

  Widget _inputShell(BuildContext context, {required IconData icon, required Widget child, Widget? suffix}) {
    return Container(
      height: 52,
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
    required this.expression,
    required this.accessory,
    required this.effect,
    required this.budget,
    required this.goal,
    required this.gxBankConnected,
    required this.notificationsEnabled,
    required this.autoSaveEnabled,
    required this.autoSavePercent,
    required this.selectedPriorities,
    required this.categoryPercents,
    required this.plan,
    required this.yesAnswers,
    required this.noAnswers,
    required this.onSetBreed,
    required this.onSetExpression,
    required this.onSetAccessory,
    required this.onSetEffect,
    required this.onSetBudget,
    required this.onSetGoal,
    required this.onSetAutoSavePercent,
    required this.onToggleNotifications,
    required this.onToggleAutoSave,
    required this.onTogglePriority,
    required this.onSetCategoryPercent,
    required this.onTogglePersonality,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final String breed;
  final String expression;
  final String accessory;
  final String effect;
  final double budget;
  final double goal;
  final bool gxBankConnected;
  final bool notificationsEnabled;
  final bool autoSaveEnabled;
  final double autoSavePercent;
  final Set<String> selectedPriorities;
  final Map<String, double> categoryPercents;
  final BudgetPlan plan;
  final Set<int> yesAnswers;
  final Set<int> noAnswers;
  final ValueChanged<String> onSetBreed;
  final ValueChanged<String> onSetExpression;
  final ValueChanged<String> onSetAccessory;
  final ValueChanged<String> onSetEffect;
  final ValueChanged<double> onSetBudget;
  final ValueChanged<double> onSetGoal;
  final ValueChanged<double> onSetAutoSavePercent;
  final ValueChanged<bool> onToggleNotifications;
  final ValueChanged<bool> onToggleAutoSave;
  final ValueChanged<String> onTogglePriority;
  final void Function(String key, double value) onSetCategoryPercent;
  final void Function(int index, bool yes) onTogglePersonality;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final breeds = catBreedConfigs.map((item) => (item.id, item.label)).toList();
    final expressions = [
      ('happy', 'Happy'),
      ('neutral', 'Calm'),
      ('proud', 'Proud'),
      ('excited', 'Excited'),
    ];
    final accessories = [
      ('none', 'None'),
      ('ribbon', 'Ribbon'),
      ('crown', 'Crown'),
      ('headphones', 'Headphones'),
      ('glasses', 'Glasses'),
      ('flower', 'Flower'),
      ('wizard_hat', 'Wizard Hat'),
      ('sleeping_cap', 'Sleeping Cap'),
      ('halo', 'Halo'),
      ('coin_clip', 'Coin Clip'),
    ];
    final effects = [
      ('none', 'No effect'),
      ('sparkle_aura', 'Sparkle aura'),
      ('glow_outline', 'Glow outline'),
      ('floating_hearts', 'Floating hearts'),
    ];
    final personality = [
      "I overspend when I'm stressed",
      'I love a good deal hunt',
      'I forget to track expenses',
      'I want to save for something specific',
    ];
    final priorities = [
      'Emergency fund',
      'Reduce food spending',
      'Avoid overspending',
      'Build saving habit',
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
                            gradient: active ? context.colors.primaryGradient : null,
                            color: active ? null : context.colors.muted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      child: switch (step) {
                        0 => _avatarStep(context, breeds, expressions, accessories, effects),
                        1 => _financeStep(context, priorities),
                        _ => _personalityStep(context, personality),
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
                        child: Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.mutedForeground)),
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

  Widget _avatarStep(
    BuildContext context,
    List<(String, String)> breeds,
    List<(String, String)> expressions,
    List<(String, String)> accessories,
    List<(String, String)> effects,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Build your cat avatar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Choose a collectible breed, add a head accessory, and set the mood for the head-only companion that shows up everywhere in ThinkTwice.',
          style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF8F3),
                Color(0xFFEAFBF5),
                Color(0xFFFFE8EF),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.92)),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              avatarPreview(
                context,
                breed: breed,
                accessory: accessory,
                effect: effect,
                mood: avatarMoodFromId(expression),
                size: 180,
              ),
              const SizedBox(height: 12),
              Text('${catBreedLabel(breed)} · ${formatAccessoryLabel(accessory)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                effect == 'none' ? moodLabel(avatarMoodFromId(expression)) : '${formatEffectLabel(effect)} equipped',
                style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionLabel('Choose breed', context),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: breeds.map((item) {
            final selected = breed == item.$1;
            return GestureDetector(
              onTap: () => onSetBreed(item.$1),
              child: Container(
                width: 116,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected ? context.colors.primary.withOpacity(0.15) : context.colors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: selected ? context.colors.primary : Theme.of(context).dividerColor, width: selected ? 2 : 1),
                ),
                child: Column(
                  children: [
                    avatarPreview(context, breed: item.$1, accessory: accessory, effect: effect, mood: avatarMoodFromId(expression), size: 72),
                    const SizedBox(height: 8),
                    Text(item.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Choose accessory', context),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: accessories.map((item) {
            final selected = accessory == item.$1;
            return GestureDetector(
              onTap: () => onSetAccessory(item.$1),
              child: Container(
                width: 110,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? context.colors.primary.withOpacity(0.15) : context.colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? context.colors.primary : Theme.of(context).dividerColor),
                ),
                child: Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? context.colors.primary : context.colors.foreground),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Mood vibe', context),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: expressions.map((item) {
            final selected = expression == item.$1;
            return GestureDetector(
              onTap: () => onSetExpression(item.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? context.colors.primary.withOpacity(0.15) : context.colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? context.colors.primary : Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(selected ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 16, color: selected ? context.colors.primary : context.colors.foreground),
                    const SizedBox(width: 6),
                    Text(item.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? context.colors.primary : context.colors.foreground)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Optional effect', context),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: effects.map((item) {
            final selected = effect == item.$1;
            return GestureDetector(
              onTap: () => onSetEffect(item.$1),
              child: Container(
                width: 136,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? context.colors.primary.withOpacity(0.15) : context.colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? context.colors.primary : Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(effectIcon(item.$1), size: 16, color: selected ? context.colors.primary : context.colors.foreground),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? context.colors.primary : context.colors.foreground),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _financeStep(BuildContext context, List<String> priorities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Set your saving rhythm', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Dial in your budget, savings target, and automation rules so your cat can react to real spending behaviour.',
          style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
        ),
        const SizedBox(height: 12),
        WhiteCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: context.colors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.account_balance_rounded, color: context.colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GXBank sync', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      gxBankConnected ? 'Connected and ready to power live nudges.' : 'Connect GXBank to unlock adaptive recommendations.',
                      style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: gxBankConnected ? context.colors.success.withOpacity(0.14) : context.colors.warning.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  gxBankConnected ? 'Live' : 'Pending',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: gxBankConnected ? context.colors.success : context.colors.accentForeground),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AmountSliderCard(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Monthly budget',
          value: budget,
          min: 500,
          max: 6000,
          step: 50,
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
          decoration: BoxDecoration(gradient: context.colors.primaryGradient, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimated safe daily spending limit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 6),
              Text('RM ${formatRm(plan.dailyLimit)} / day', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 6),
              Text('(RM ${formatRm(budget)} - RM ${formatRm(goal)}) ÷ 30 days', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.88))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        WhiteCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Automation preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text('Auto-save approval', style: TextStyle(fontSize: 13, color: context.colors.foreground))),
                  Switch.adaptive(value: autoSaveEnabled, onChanged: onToggleAutoSave),
                ],
              ),
              const SizedBox(height: 4),
              Text('Micro-saving amount: ${formatRm(autoSavePercent * 100)}%', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: context.colors.success,
                  inactiveTrackColor: context.colors.muted,
                  thumbColor: context.colors.success,
                ),
                child: Slider(
                  value: autoSavePercent.clamp(0.05, 0.3),
                  min: 0.05,
                  max: 0.3,
                  divisions: 5,
                  onChanged: onSetAutoSavePercent,
                ),
              ),
              Row(
                children: [
                  Expanded(child: Text('Spending alerts', style: TextStyle(fontSize: 13, color: context.colors.foreground))),
                  Switch.adaptive(value: notificationsEnabled, onChanged: onToggleNotifications),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionLabel('Money priorities', context),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: priorities.map((item) {
            final selected = selectedPriorities.contains(item);
            return GestureDetector(
              onTap: () => onTogglePriority(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? context.colors.primary.withOpacity(0.12) : context.colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? context.colors.primary : Theme.of(context).dividerColor),
                ),
                child: Text(
                  item,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? context.colors.primary : context.colors.foreground),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ...plan.allocations.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AllocationSliderCard(
                label: item.name,
                percent: categoryPercents[item.name] ?? item.percent,
                amount: item.amount,
                color: item.color,
                onChanged: (value) => onSetCategoryPercent(item.name, value),
              ),
            )),
      ],
    );
  }

  Widget _personalityStep(BuildContext context, List<String> personality) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Train your money coach', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'These inputs shape your AI baseline, first resilience score, and the tone of the cat companion you will see after transactions stream in.',
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
                  Text('${plan.adaptabilityScore}/100', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.primary)),
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
                        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: context.colors.foreground, height: 1.35))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        WhiteCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Initial dashboard state', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: progressStat(context, 'Resilience', '50')),
                  const SizedBox(width: 8),
                  Expanded(child: progressStat(context, 'Streak', '0')),
                  const SizedBox(width: 8),
                  Expanded(child: progressStat(context, 'Smart decisions', '0')),
                ],
              ),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Expanded(child: Text(personality[index], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 12),
                  _pillChoice(context, text: 'Yes', active: yes, activeColor: context.colors.primary, activeText: Colors.white, onTap: () => onTogglePersonality(index, true)),
                  const SizedBox(width: 8),
                  _pillChoice(context, text: 'No', active: no, activeColor: context.colors.foreground, activeText: context.colors.background, onTap: () => onTogglePersonality(index, false)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _sectionLabel(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.colors.mutedForeground),
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
        decoration: BoxDecoration(color: active ? activeColor : context.colors.muted, borderRadius: BorderRadius.circular(999)),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? activeText : context.colors.mutedForeground)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
              Text('${formatRm(percent * 100)}% · RM ${formatRm(amount)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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
