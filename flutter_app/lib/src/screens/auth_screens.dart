import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
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
    required this.onSetColor,
    required this.onSetAccessory,
    required this.onSetOutfit,
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
  final String color;
  final String accessory;
  final String outfit;
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
  final ValueChanged<String> onSetColor;
  final ValueChanged<String> onSetAccessory;
  final ValueChanged<String> onSetOutfit;
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
                              const Text('Set goals and preferences', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                'Choose your priorities, budget setup, and intervention preferences. ThinkTwice will build your first baseline from this.',
                                style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                              ),
                              const SizedBox(height: 16),
                              WhiteCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: context.colors.primary.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(Icons.account_balance_rounded, color: context.colors.primary),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('GXBank account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                              Text(
                                                gxBankConnected ? 'Connected securely for transaction streaming' : 'Not connected yet',
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
                                            gxBankConnected ? 'Connected' : 'Pending',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: gxBankConnected ? context.colors.success : context.colors.accentForeground,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _sectionLabel('Priority goals', context),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: priorities.map((item) {
                                  final selected = selectedPriorities.contains(item);
                                  return GestureDetector(
                                    onTap: () => onTogglePriority(item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: selected ? context.colors.primary.withOpacity(0.12) : context.colors.card,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: selected ? context.colors.primary : Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: selected ? context.colors.primary : context.colors.foreground,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
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
                              WhiteCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Automation preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Auto-save approval',
                                            style: TextStyle(fontSize: 13, color: context.colors.foreground),
                                          ),
                                        ),
                                        Switch.adaptive(value: autoSaveEnabled, onChanged: onToggleAutoSave),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Micro-saving amount: ${formatRm(autoSavePercent * 100)}%',
                                      style: TextStyle(fontSize: 12, color: context.colors.mutedForeground),
                                    ),
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
                                        Expanded(
                                          child: Text(
                                            'Spending alerts',
                                            style: TextStyle(fontSize: 13, color: context.colors.foreground),
                                          ),
                                        ),
                                        Switch.adaptive(value: notificationsEnabled, onChanged: onToggleNotifications),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        _ => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Baseline and behaviour setup', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                'These inputs shape your AI baseline, first resilience score, and the interventions you will see after transactions stream in.',
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
                                    const SizedBox(height: 10),
                                    Text(
                                      'Once your GXBank transactions stream in, ThinkTwice will analyze spending velocity, risk, time patterns, and intervention outcomes daily.',
                                      style: TextStyle(fontSize: 12, height: 1.35, color: context.colors.mutedForeground),
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




