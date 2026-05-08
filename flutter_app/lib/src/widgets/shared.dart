import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/models.dart';

class PointsChip extends StatelessWidget {
  const PointsChip({required this.totalPoints});

  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.24),
            Colors.white.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
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

String formatShopCategory(String category) {
  switch (category) {
    case 'accessory':
      return 'Accessory';
    case 'outfit':
      return 'Outfit';
    case 'badge':
      return 'Badge';
    case 'cosmetic':
      return 'Cosmetic';
    default:
      return 'Reward';
  }
}

String formatAccessoryLabel(String accessory) {
  switch (accessory) {
    case 'crown':
      return 'Crown';
    case 'scarf':
      return 'Scarf';
    case 'headphones':
      return 'Headphones';
    case 'ribbon':
      return 'Ribbon';
    case 'glasses':
      return 'Glasses';
    case 'hat':
      return 'Top Hat';
    case 'none':
      return 'No accessory';
    default:
      return 'Accessory';
  }
}

String formatCosmeticLabel(String cosmetic) {
  switch (cosmetic) {
    case 'sparkle':
      return 'Sparkle Trail';
    case 'coins':
      return 'Coin Aura';
    case 'none':
      return 'No cosmetic';
    default:
      return 'Cosmetic';
  }
}

IconData _accessoryIcon(String accessory) {
  switch (accessory) {
    case 'crown':
      return Icons.workspace_premium_rounded;
    case 'scarf':
      return Icons.waves_rounded;
    case 'headphones':
      return Icons.headphones_rounded;
    case 'glasses':
      return Icons.visibility_rounded;
    case 'hat':
      return Icons.umbrella_rounded;
    case 'bag':
      return Icons.shopping_bag_rounded;
    case 'ribbon':
      return Icons.sell_rounded;
    default:
      return Icons.check_circle_outline_rounded;
  }
}

String formatRarityLabel(String rarity) {
  switch (rarity) {
    case 'legendary':
      return 'Legendary';
    case 'epic':
      return 'Epic';
    case 'rare':
      return 'Rare';
    default:
      return 'Common';
  }
}

(Color, Color, List<Color>) rarityPalette(BuildContext context, String rarity) {
  switch (rarity) {
    case 'legendary':
      return (
        const Color(0xFFF0A65D),
        const Color(0xFF7A4316),
        const [Color(0xFFFFE3B5), Color(0xFFF6B56A)],
      );
    case 'epic':
      return (
        const Color(0xFF9E79E8),
        const Color(0xFF4D2B8D),
        const [Color(0xFFE9D9FF), Color(0xFFC7AAFF)],
      );
    case 'rare':
      return (
        const Color(0xFF4DB2E6),
        const Color(0xFF185A7D),
        const [Color(0xFFD8F2FF), Color(0xFF9ADBF9)],
      );
    default:
      return (
        context.colors.primary,
        context.colors.foreground,
        [const Color(0xFFE8FFF6), const Color(0xFFCDEEE1)],
      );
  }
}

Color _avatarColor(String color) {
  switch (color) {
    case 'peach':
      return const Color(0xFFE5A36C);
    case 'sky':
      return const Color(0xFF72B5E8);
    case 'rose':
      return const Color(0xFFDD7B84);
    case 'lavender':
      return const Color(0xFFB58ADF);
    default:
      return const Color(0xFF41B89B);
  }
}

Widget avatarPreview(
  BuildContext context, {
  required String breed,
  required String color,
  required String accessory,
  required String outfit,
  required String cosmetic,
  AvatarMood mood = AvatarMood.neutral,
  double size = 96,
}) {
  return WalletGuardianPreview(
    breed: breed,
    color: color,
    accessory: accessory,
    outfit: outfit,
    cosmetic: cosmetic,
    mood: mood,
    size: size,
  );
}

class WalletGuardianPreview extends StatefulWidget {
  const WalletGuardianPreview({
    super.key,
    required this.breed,
    required this.color,
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
    required this.mood,
    this.size = 96,
  });

  final String breed;
  final String color;
  final String accessory;
  final String outfit;
  final String cosmetic;
  final AvatarMood mood;
  final double size;

  @override
  State<WalletGuardianPreview> createState() => _WalletGuardianPreviewState();
}

class _WalletGuardianPreviewState extends State<WalletGuardianPreview> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _tailController;
  late final AnimationController _blinkController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _tailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))..repeat(reverse: true);
    _sparkleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _tailController.dispose();
    _blinkController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _avatarColor(widget.color);
    final moodConfig = _guardianMoodStyle(context, widget.mood);

    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _tailController, _blinkController, _sparkleController]),
      builder: (context, child) {
        final floatY = (_floatController.value - 0.5) * 10;
        final blink = widget.mood == AvatarMood.sad ? 0.25 : 1 - (_blinkController.value > 0.92 ? 0.8 : 0.0);
        final tailTurn = (_tailController.value - 0.5) * 0.55;
        final auraScale = 0.96 + (_sparkleController.value * 0.08);
        final sparkleLift = (_sparkleController.value - 0.5) * 12;
        return Transform.translate(
          offset: Offset(0, floatY),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: Container(
              key: ValueKey('${widget.accessory}-${widget.outfit}-${widget.cosmetic}-${widget.mood}-${widget.color}'),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: widget.color == 'mint'
                    ? context.colors.guardianGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          bg.withOpacity(0.18),
                          moodConfig.tint.withOpacity(0.18),
                        ],
                      ),
                borderRadius: BorderRadius.circular(widget.size * 0.36),
                border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: moodConfig.highlight.withOpacity(0.18),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Transform.scale(
                        scale: auraScale,
                        child: Container(
                          width: widget.size * 0.72,
                          height: widget.size * 0.72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                moodConfig.highlight.withOpacity(0.28),
                                moodConfig.highlight.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: widget.size * 0.18,
                      height: widget.size * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          _guardianSparkle(
                            size: widget.size,
                            alignment: const Alignment(-0.78, -0.36),
                            color: moodConfig.highlight,
                            offsetY: sparkleLift * 0.35,
                          ),
                          _guardianSparkle(
                            size: widget.size,
                            alignment: const Alignment(0.8, -0.58),
                            color: context.colors.accent,
                            offsetY: -sparkleLift * 0.25,
                          ),
                          _guardianSparkle(
                            size: widget.size,
                            alignment: const Alignment(0.72, 0.18),
                            color: Colors.white,
                            offsetY: sparkleLift * 0.18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: widget.size * 0.04,
                    top: widget.size * 0.06,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: moodConfig.highlight.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: moodConfig.highlight.withOpacity(0.22)),
                      ),
                      child: Text(
                        moodConfig.label,
                        style: TextStyle(fontSize: widget.size * 0.072, fontWeight: FontWeight.w700, color: moodConfig.highlight),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: widget.size * 0.8,
                      height: widget.size * 0.8,
                      child: CustomPaint(
                        painter: _WalletGuardianPainter(
                          bodyColor: bg,
                          mood: widget.mood,
                          tailTurn: tailTurn,
                          blinkAmount: blink,
                          accessory: widget.accessory,
                          outfit: widget.outfit,
                          cosmetic: widget.cosmetic,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.size * 0.1,
                    bottom: widget.size * 0.18,
                    child: _GuardianBubble(
                      icon: moodConfig.icon,
                      color: moodConfig.highlight,
                      label: moodConfig.reaction,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.breed,
                        style: TextStyle(fontSize: widget.size * 0.09, fontWeight: FontWeight.w700, color: context.colors.foreground),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.colors.card.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Text(
                        '${widget.outfit} drop',
                        style: TextStyle(fontSize: widget.size * 0.092, fontWeight: FontWeight.w700, color: context.colors.foreground),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GuardianMoodStyle {
  const _GuardianMoodStyle({
    required this.highlight,
    required this.tint,
    required this.label,
    required this.reaction,
    required this.icon,
  });

  final Color highlight;
  final Color tint;
  final String label;
  final String reaction;
  final IconData icon;
}

_GuardianMoodStyle _guardianMoodStyle(BuildContext context, AvatarMood mood) {
  return switch (mood) {
    AvatarMood.happy => _GuardianMoodStyle(
        highlight: context.colors.success,
        tint: const Color(0xFFD9F7E7),
        label: 'Saving mode',
        reaction: 'Glow up',
        icon: Icons.favorite_rounded,
      ),
    AvatarMood.sad => _GuardianMoodStyle(
        highlight: context.colors.warning,
        tint: const Color(0xFFFFE7D0),
        label: 'Needs backup',
        reaction: 'Uh oh',
        icon: Icons.water_drop_rounded,
      ),
    AvatarMood.excited => _GuardianMoodStyle(
        highlight: context.colors.accentForeground,
        tint: const Color(0xFFFFECD0),
        label: 'Streak energy',
        reaction: 'Rare drop',
        icon: Icons.auto_awesome_rounded,
      ),
    AvatarMood.proud => _GuardianMoodStyle(
        highlight: context.colors.accentForeground,
        tint: const Color(0xFFFFE2C2),
        label: 'Tier up',
        reaction: 'Crowned',
        icon: Icons.workspace_premium_rounded,
      ),
    AvatarMood.neutral => _GuardianMoodStyle(
        highlight: context.colors.primary,
        tint: const Color(0xFFDFF6EF),
        label: 'Cozy idle',
        reaction: 'On watch',
        icon: Icons.shield_moon_rounded,
      ),
  };
}

Widget _guardianSparkle({
  required double size,
  required Alignment alignment,
  required Color color,
  required double offsetY,
}) {
  return Align(
    alignment: alignment,
    child: Transform.translate(
      offset: Offset(0, offsetY),
      child: Container(
        width: size * 0.08,
        height: size * 0.08,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    ),
  );
}

class _GuardianBubble extends StatelessWidget {
  const _GuardianBubble({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class AIInterventionModal extends StatelessWidget {
  const AIInterventionModal({
    super.key,
    required this.onSaveNow,
    required this.onFindAlternative,
    required this.onIgnore,
  });

  final VoidCallback onSaveNow;
  final VoidCallback onFindAlternative;
  final VoidCallback onIgnore;

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
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, 18)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WalletGuardianPreview(
                        breed: 'tabby',
                        color: 'mint',
                        accessory: 'none',
                        outfit: 'Hoodie',
                        cosmetic: 'none',
                        mood: AvatarMood.sad,
                        size: 68,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wallet Guardian', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: context.colors.accentForeground)),
                            const SizedBox(height: 2),
                            const Text('Guardian Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.favorite_rounded, size: 14, color: context.colors.warning),
                                const SizedBox(width: 5),
                                Text('Emotionally responsive nudge', style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onIgnore,
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
                      gradient: context.colors.softMintGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your guardian noticed a spend spiral starting.',
                          style: TextStyle(fontSize: 14, height: 1.45),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Move RM8 into savings now to protect your streak, calm the mascot, and stay under today\'s safe limit.',
                          style: TextStyle(fontSize: 13, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: 'Save RM8',
                    icon: Icons.savings_outlined,
                    onPressed: onSaveNow,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: onFindAlternative,
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
                    onPressed: onIgnore,
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

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bg.withOpacity(0.96),
              bg.withOpacity(0.74),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: fg.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.52),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg), textAlign: TextAlign.center),
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
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: fg.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
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

enum AvatarMood { happy, neutral, sad, excited, proud }

String moodLabel(AvatarMood mood) {
  switch (mood) {
    case AvatarMood.happy:
      return 'Happy and celebrating';
    case AvatarMood.neutral:
      return 'Calm and on track';
    case AvatarMood.sad:
      return 'Worried about overspending';
    case AvatarMood.excited:
      return 'Excited about leveling up';
    case AvatarMood.proud:
      return 'Proud of your progress';
  }
}

Widget avatarMoodBadge(BuildContext context, AvatarMood mood) {
  final moodConfig = _guardianMoodStyle(context, mood);

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          gradient: context.colors.guardianGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(6),
        child: WalletGuardianPreview(
          breed: 'tabby',
          color: 'mint',
          accessory: 'none',
          outfit: 'Hoodie',
          cosmetic: 'none',
          mood: mood,
          size: 56,
        ),
      ),
      Positioned(
        right: -4,
        top: -4,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: moodConfig.highlight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(moodConfig.icon, size: 16, color: Colors.white),
        ),
      ),
    ],
  );
}

Widget progressStat(BuildContext context, String label, String value) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.96),
          context.colors.softMintGradient.colors.last.withOpacity(0.9),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.colors.muted.withOpacity(0.75)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.94, end: 1),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, alignment: Alignment.centerLeft, child: child),
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
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
    final button = PressScale(
      onTap: onPressed,
      child: Ink(
        height: compact ? 38 : 52,
        decoration: BoxDecoration(
          gradient: context.colors.primaryGradient,
          borderRadius: BorderRadius.circular(compact ? 16 : 22),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withOpacity(0.24),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 14, fontWeight: FontWeight.w800)),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: compact ? 14 : 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
    return compact
        ? button
        : PulseGlow(
            color: context.colors.primary,
            child: button,
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
        borderRadius: BorderRadius.circular(30),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.card,
            context.colors.softMintGradient.colors.last.withOpacity(0.68),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget sectionHeader(BuildContext context, String title, {required String action, required VoidCallback onTap, bool compact = false}) {
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

class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.onTap, this.scale = 0.97});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        scale: _pressed ? widget.scale : 1,
        child: widget.child,
      ),
    );
  }
}

class StaggeredReveal extends StatefulWidget {
  const StaggeredReveal({
    super.key,
    required this.child,
    required this.index,
    this.offsetY = 14,
  });

  final Widget child;
  final int index;
  final double offsetY;

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future<void>.delayed(Duration(milliseconds: 70 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class AnimatedNumberText extends StatelessWidget {
  const AnimatedNumberText({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    required this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) {
        final number = decimals == 0 ? animated.round().toString() : animated.toStringAsFixed(decimals);
        return Text('$prefix$number$suffix', style: style);
      },
    );
  }
}

class AnimatedFillBar extends StatelessWidget {
  const AnimatedFillBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor,
    this.minHeight = 8,
  });

  final double value;
  final Color color;
  final Color? backgroundColor;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animated,
            minHeight: minHeight,
            backgroundColor: backgroundColor ?? context.colors.muted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }
}

class PulseGlow extends StatefulWidget {
  const PulseGlow({super.key, required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
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
        final glow = 8 + (_controller.value * 10);
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.10 + (_controller.value * 0.12)),
                blurRadius: glow,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

Future<void> showCelebrationDialog(
  BuildContext context, {
  required String title,
  required String body,
  required IconData icon,
  required Color color,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'celebration',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: Transform.scale(
          scale: curved.value,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: context.colors.softMintGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: context.colors.softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CelebrationBurst(color: color),
                    const SizedBox(height: 10),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(height: 14),
                    Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(body, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.45, color: context.colors.mutedForeground)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Nice'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _CelebrationBurst extends StatefulWidget {
  const _CelebrationBurst({required this.color});

  final Color color;

  @override
  State<_CelebrationBurst> createState() => _CelebrationBurstState();
}

class _CelebrationBurstState extends State<_CelebrationBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: List.generate(6, (index) {
              final progress = _controller.value;
              final dx = (index - 2.5) * 14 * progress;
              final dy = (index.isEven ? -1 : 1) * 8 * progress;
              return Positioned(
                left: 38 + dx,
                top: 10 + dy,
                child: Opacity(
                  opacity: 1 - progress,
                  child: Transform.scale(
                    scale: 0.6 + (progress * 0.7),
                    child: Icon(
                      index.isEven ? Icons.auto_awesome_rounded : Icons.circle,
                      size: index.isEven ? 12 : 8,
                      color: widget.color.withOpacity(0.9),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
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

class _WalletGuardianPainter extends CustomPainter {
  const _WalletGuardianPainter({
    required this.bodyColor,
    required this.mood,
    required this.tailTurn,
    required this.blinkAmount,
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
  });

  final Color bodyColor;
  final AvatarMood mood;
  final double tailTurn;
  final double blinkAmount;
  final String accessory;
  final String outfit;
  final String cosmetic;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bodyPaint = Paint()..color = bodyColor.withOpacity(0.9);
    final creamPaint = Paint()..color = const Color(0xFFFDF9F2);
    final linePaint = Paint()
      ..color = const Color(0xFF27443D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;
    final cheekPaint = Paint()..color = const Color(0xFFFFD7D1).withOpacity(0.75);

    final tailPath = Path()
      ..moveTo(size.width * 0.73, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * (0.97 + tailTurn * 0.1),
        size.height * 0.52,
        size.width * (0.9 + tailTurn * 0.08),
        size.height * 0.27,
      );
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = bodyColor.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.11
        ..strokeCap = StrokeCap.round,
    );

    final earLeft = Path()
      ..moveTo(size.width * 0.24, size.height * 0.36)
      ..lineTo(size.width * 0.33, size.height * 0.13)
      ..lineTo(size.width * 0.44, size.height * 0.33)
      ..close();
    final earRight = Path()
      ..moveTo(size.width * 0.76, size.height * 0.36)
      ..lineTo(size.width * 0.67, size.height * 0.13)
      ..lineTo(size.width * 0.56, size.height * 0.33)
      ..close();
    canvas.drawPath(earLeft, bodyPaint);
    canvas.drawPath(earRight, bodyPaint);
    canvas.drawCircle(center.translate(0, size.height * 0.02), size.width * 0.27, bodyPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.26),
        width: size.width * 0.42,
        height: size.height * 0.24,
      ),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.06),
        width: size.width * 0.25,
        height: size.height * 0.18,
      ),
      creamPaint,
    );
    canvas.drawOval(Rect.fromCenter(center: center.translate(-size.width * 0.12, size.height * 0.1), width: size.width * 0.08, height: size.height * 0.06), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: center.translate(size.width * 0.12, size.height * 0.1), width: size.width * 0.08, height: size.height * 0.06), cheekPaint);

    final eyeWidth = mood == AvatarMood.excited ? size.width * 0.07 : size.width * 0.06;
    final eyeHeight = size.height * 0.055 * blinkAmount.clamp(0.12, 1.0);
    final eyeY = size.height * 0.43;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.39, eyeY), width: eyeWidth, height: eyeHeight),
        Radius.circular(size.width * 0.04),
      ),
      Paint()..color = const Color(0xFF243C35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.61, eyeY), width: eyeWidth, height: eyeHeight),
        Radius.circular(size.width * 0.04),
      ),
      Paint()..color = const Color(0xFF243C35),
    );

    if (mood == AvatarMood.excited) {
      canvas.drawCircle(Offset(size.width * 0.39, eyeY), size.width * 0.012, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(size.width * 0.61, eyeY), size.width * 0.012, Paint()..color = Colors.white);
    }

    final mouthPath = Path();
    switch (mood) {
      case AvatarMood.happy:
        mouthPath.moveTo(size.width * 0.45, size.height * 0.53);
        mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.58, size.width * 0.55, size.height * 0.53);
        break;
      case AvatarMood.sad:
        mouthPath.moveTo(size.width * 0.45, size.height * 0.56);
        mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.52, size.width * 0.55, size.height * 0.56);
        break;
      case AvatarMood.excited:
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), size.width * 0.035, Paint()..color = const Color(0xFF243C35));
        break;
      case AvatarMood.neutral:
        mouthPath.moveTo(size.width * 0.46, size.height * 0.55);
        mouthPath.lineTo(size.width * 0.54, size.height * 0.55);
        break;
      case AvatarMood.proud:
        mouthPath.moveTo(size.width * 0.45, size.height * 0.54);
        mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width * 0.55, size.height * 0.54);
        break;
    }
    if (mood != AvatarMood.excited) {
      canvas.drawPath(mouthPath, linePaint);
    }

    _paintAccessory(canvas, size);
    _paintOutfit(canvas, size);
    _paintCosmetic(canvas, size);
  }

  void _paintAccessory(Canvas canvas, Size size) {
    switch (accessory) {
      case 'crown':
        final path = Path()
          ..moveTo(size.width * 0.34, size.height * 0.22)
          ..lineTo(size.width * 0.4, size.height * 0.12)
          ..lineTo(size.width * 0.5, size.height * 0.2)
          ..lineTo(size.width * 0.6, size.height * 0.12)
          ..lineTo(size.width * 0.66, size.height * 0.22)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFF2C45A));
        break;
      case 'glasses':
        final paint = Paint()
          ..color = const Color(0xFF3D505C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.025;
        canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.43), size.width * 0.055, paint);
        canvas.drawCircle(Offset(size.width * 0.61, size.height * 0.43), size.width * 0.055, paint);
        canvas.drawLine(Offset(size.width * 0.445, size.height * 0.43), Offset(size.width * 0.555, size.height * 0.43), paint);
        break;
      case 'headphones':
        final paint = Paint()
          ..color = const Color(0xFF4D4A70)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.03;
        canvas.drawArc(Rect.fromLTWH(size.width * 0.27, size.height * 0.18, size.width * 0.46, size.height * 0.38), 3.2, 2.8, false, paint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.22, size.height * 0.36, size.width * 0.08, size.height * 0.14), Radius.circular(size.width * 0.03)), Paint()..color = const Color(0xFF6A64A8));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.7, size.height * 0.36, size.width * 0.08, size.height * 0.14), Radius.circular(size.width * 0.03)), Paint()..color = const Color(0xFF6A64A8));
        break;
      case 'scarf':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.32, size.height * 0.55, size.width * 0.36, size.height * 0.07),
            Radius.circular(size.width * 0.04),
          ),
          Paint()..color = const Color(0xFFEF7B7B),
        );
        break;
      case 'bag':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.62, size.height * 0.58, size.width * 0.12, size.height * 0.12),
            Radius.circular(size.width * 0.03),
          ),
          Paint()..color = const Color(0xFF76A58A),
        );
        break;
    }
  }

  void _paintOutfit(Canvas canvas, Size size) {
    switch (outfit) {
      case 'Jacket':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.33, size.height * 0.66, size.width * 0.34, size.height * 0.12),
            Radius.circular(size.width * 0.05),
          ),
          Paint()..color = const Color(0xFF506A89),
        );
        break;
      case 'Cape':
        final path = Path()
          ..moveTo(size.width * 0.32, size.height * 0.62)
          ..lineTo(size.width * 0.68, size.height * 0.62)
          ..lineTo(size.width * 0.76, size.height * 0.84)
          ..lineTo(size.width * 0.24, size.height * 0.84)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFF5C9D8C));
        break;
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.33, size.height * 0.66, size.width * 0.34, size.height * 0.12),
            Radius.circular(size.width * 0.05),
          ),
          Paint()..color = const Color(0xFFE7C172),
        );
    }
  }

  void _paintCosmetic(Canvas canvas, Size size) {
    switch (cosmetic) {
      case 'sparkle':
        canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.26), size.width * 0.02, Paint()..color = const Color(0xFFFFF1A4));
        canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.22), size.width * 0.014, Paint()..color = const Color(0xFFFFFFFF));
        break;
      case 'coins':
        canvas.drawCircle(Offset(size.width * 0.77, size.height * 0.28), size.width * 0.03, Paint()..color = const Color(0xFFF2C45A));
        canvas.drawCircle(Offset(size.width * 0.71, size.height * 0.24), size.width * 0.02, Paint()..color = const Color(0xFFF7D87B));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _WalletGuardianPainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor ||
        oldDelegate.mood != mood ||
        oldDelegate.tailTurn != tailTurn ||
        oldDelegate.blinkAmount != blinkAmount ||
        oldDelegate.accessory != accessory ||
        oldDelegate.outfit != outfit ||
        oldDelegate.cosmetic != cosmetic;
  }
}

class RewardItemPreview extends StatelessWidget {
  const RewardItemPreview({
    super.key,
    required this.item,
    this.equipped = false,
    this.locked = false,
    this.size = 92,
  });

  final RewardShopItem item;
  final bool equipped;
  final bool locked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = rarityPalette(context, item.rarity);
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: equipped ? 1.04 : 1,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: palette.$3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.$1.withOpacity(equipped ? 0.95 : 0.55), width: equipped ? 2.4 : 1.6),
          boxShadow: [
            BoxShadow(
              color: palette.$1.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: locked ? 0.45 : 1,
                child: WalletGuardianPreview(
                  breed: 'cat',
                  color: 'mint',
                  accessory: item.category == 'accessory' ? item.value ?? 'none' : 'none',
                  outfit: item.category == 'outfit' ? item.value ?? 'Hoodie' : 'Hoodie',
                  cosmetic: item.category == 'cosmetic' ? item.value ?? 'none' : 'none',
                  mood: equipped ? AvatarMood.excited : AvatarMood.proud,
                  size: size * 0.82,
                ),
              ),
            ),
            if (locked)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.lock_rounded, size: 14, color: palette.$2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}





