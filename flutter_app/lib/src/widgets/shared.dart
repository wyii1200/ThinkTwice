import 'package:flutter/material.dart';
import '../core/app_theme.dart';
class PointsChip extends StatelessWidget {
  const PointsChip({required this.totalPoints});

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
    case 'ribbon':
      return Icons.sell_rounded;
    default:
      return Icons.check_circle_outline_rounded;
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
  double size = 96,
}) {
  final bg = _avatarColor(color);
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg.withOpacity(0.18),
      gradient: color == 'mint' ? context.colors.primaryGradient : null,
      borderRadius: BorderRadius.circular(size * 0.26),
      boxShadow: [
        BoxShadow(
          color: bg.withOpacity(0.14),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(size * 0.08),
            child: Image.asset('assets/images/cat-avatar.png', width: size * 0.82, height: size * 0.82),
          ),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              breed,
              style: TextStyle(fontSize: size * 0.09, fontWeight: FontWeight.w700, color: context.colors.foreground),
            ),
          ),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: context.colors.card,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            alignment: Alignment.center,
            child: Icon(
              _accessoryIcon(accessory),
              size: size * 0.15,
              color: accessory == 'none' ? context.colors.mutedForeground : context.colors.accentForeground,
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
              outfit,
              style: TextStyle(fontSize: size * 0.1, fontWeight: FontWeight.w700, color: context.colors.foreground),
            ),
          ),
        ),
        if (cosmetic != 'none')
          Positioned(
            right: 10,
            bottom: 10,
            child: Icon(Icons.auto_awesome_rounded, size: size * 0.18, color: context.colors.accent),
          ),
      ],
    ),
  );
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
                      color: context.colors.muted.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your food spending today is already 42% above average.',
                          style: TextStyle(fontSize: 14, height: 1.45),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Move RM8 into savings now to protect your streak and stay under today\'s safe limit.',
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

enum AvatarMood { happy, neutral, sad, excited }

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
  }
}

Widget avatarMoodBadge(BuildContext context, AvatarMood mood) {
  final moodConfig = switch (mood) {
    AvatarMood.happy => (context.colors.success, Icons.sentiment_satisfied_alt_rounded),
    AvatarMood.neutral => (context.colors.primary, Icons.sentiment_neutral_rounded),
    AvatarMood.sad => (context.colors.warning, Icons.sentiment_dissatisfied_rounded),
    AvatarMood.excited => (context.colors.accentForeground, Icons.bolt_rounded),
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

Widget progressStat(BuildContext context, String label, String value) {
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





