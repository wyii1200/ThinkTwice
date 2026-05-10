import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../widgets/cat_head_avatar.dart';
import '../core/app_theme.dart';
import '../core/models.dart';

export '../../widgets/cat_head_avatar.dart'
    show AvatarMood, avatarMoodFromId, avatarMoodId, catBreedConfigs, catBreedLabel, moodLabel;

class PointsChip extends StatelessWidget {
  const PointsChip({super.key, required this.totalPoints});

  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF6D7),
            Color(0xFFFFE2A1),
            Color(0xFFF2C96B),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE1B85B).withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFF7A5622)),
          ),
          const SizedBox(width: 6),
          Text(
            '$totalPoints pts',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6C4B1C)),
          ),
        ],
      ),
    );
  }
}

String formatShopCategory(String category) {
  switch (category) {
    case 'accessories':
      return 'Head Accessory';
    case 'breeds':
      return 'Cat Breed';
    case 'effects':
      return 'Avatar Effect';
    default:
      return 'Collectible';
  }
}

String formatAccessoryLabel(String accessory) {
  switch (accessory) {
    case 'crown':
      return 'Crown';
    case 'ribbon':
      return 'Ribbon';
    case 'headphones':
      return 'Headphones';
    case 'glasses':
      return 'Glasses';
    case 'flower':
      return 'Flower';
    case 'wizard_hat':
      return 'Wizard Hat';
    case 'sleeping_cap':
      return 'Sleeping Cap';
    case 'halo':
      return 'Halo';
    case 'coin_clip':
      return 'GXBank Coin Clip';
    case 'none':
      return 'No accessory';
    default:
      return 'Accessory';
  }
}

String formatEffectLabel(String effect) {
  switch (effect) {
    case 'sparkle_aura':
      return 'Sparkle Aura';
    case 'glow_outline':
      return 'Glow Outline';
    case 'floating_hearts':
      return 'Floating Hearts';
    case 'none':
      return 'No effect';
    default:
      return 'Effect';
  }
}

IconData accessoryIcon(String accessory) {
  switch (accessory) {
    case 'crown':
      return Icons.workspace_premium_rounded;
    case 'ribbon':
      return Icons.sell_rounded;
    case 'headphones':
      return Icons.headphones_rounded;
    case 'glasses':
      return Icons.visibility_rounded;
    case 'flower':
      return Icons.local_florist_rounded;
    case 'wizard_hat':
      return Icons.auto_fix_high_rounded;
    case 'sleeping_cap':
      return Icons.nightlight_round;
    case 'halo':
      return Icons.trip_origin_rounded;
    case 'coin_clip':
      return Icons.monetization_on_rounded;
    default:
      return Icons.pets_rounded;
  }
}

IconData effectIcon(String effect) {
  switch (effect) {
    case 'sparkle_aura':
      return Icons.auto_awesome_rounded;
    case 'glow_outline':
      return Icons.blur_on_rounded;
    case 'floating_hearts':
      return Icons.favorite_rounded;
    default:
      return Icons.circle_outlined;
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
        const Color(0xFFF1AB63),
        const Color(0xFF7A4418),
        const [Color(0xFFFFECC8), Color(0xFFF8C47F)],
      );
    case 'epic':
      return (
        const Color(0xFFA78AF8),
        const Color(0xFF4D2D8E),
        const [Color(0xFFF0E7FF), Color(0xFFD7C3FF)],
      );
    case 'rare':
      return (
        const Color(0xFF68BFE7),
        const Color(0xFF1D627F),
        const [Color(0xFFDFF6FF), Color(0xFFB2E3F7)],
      );
    default:
      return (
        context.colors.primary,
        context.colors.foreground,
        [const Color(0xFFE9FFF7), const Color(0xFFD1F1E6)],
      );
  }
}

Widget avatarPreview(
  BuildContext context, {
  required String breed,
  required String accessory,
  required String effect,
  AvatarMood mood = AvatarMood.neutral,
  double size = 96,
  bool showBackground = true,
}) {
  return CatHeadAvatar(
    breed: breed,
    accessory: accessory,
    effect: effect,
    mood: mood,
    size: size,
    showBackground: showBackground,
  );
}

class WalletGuardianPreview extends StatelessWidget {
  const WalletGuardianPreview({
    super.key,
    required this.breed,
    required this.accessory,
    required this.effect,
    required this.mood,
    this.size = 96,
  });

  final String breed;
  final String accessory;
  final String effect;
  final AvatarMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return avatarPreview(
      context,
      breed: breed,
      accessory: accessory,
      effect: effect,
      mood: mood,
      size: size,
    );
  }
}

Widget avatarMoodBadge(BuildContext context, AvatarMood mood) {
  final (highlight, icon) = switch (mood) {
    AvatarMood.happy => (context.colors.success, Icons.favorite_rounded),
    AvatarMood.sad => (context.colors.warning, Icons.water_drop_rounded),
    AvatarMood.excited => (context.colors.accentForeground, Icons.auto_awesome_rounded),
    AvatarMood.proud => (context.colors.accentForeground, Icons.workspace_premium_rounded),
    AvatarMood.neutral => (context.colors.primary, Icons.shield_moon_rounded),
  };

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
          breed: 'siamese',
          accessory: 'none',
          effect: 'none',
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
          decoration: BoxDecoration(color: highlight, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    ],
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
                        breed: 'siamese',
                        accessory: 'sleeping_cap',
                        effect: 'none',
                        mood: AvatarMood.sad,
                        size: 68,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cat Companion', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: context.colors.accentForeground)),
                            const SizedBox(height: 2),
                            const Text('Gentle Money Nudge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.favorite_rounded, size: 14, color: context.colors.warning),
                                const SizedBox(width: 5),
                                Text('Emotion-aware intervention', style: TextStyle(fontSize: 11, color: context.colors.mutedForeground)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onIgnore,
                        icon: const Icon(Icons.close_rounded),
                        color: const Color(0xFF6B847E),
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
                          'Your cat noticed a spend spiral starting.',
                          style: TextStyle(fontSize: 14, height: 1.45),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Move RM8 into savings now to protect your streak, calm the avatar, and stay under today\'s safe limit.',
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
                  OutlinedButton(
                    onPressed: onFindAlternative,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: context.colors.primary, width: 2),
                      foregroundColor: context.colors.primary,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Find cheaper alternatives', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onIgnore,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.mutedForeground,
                    ),
                    child: Text('Ignore', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.mutedForeground)),
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

class RewardItemPreview extends StatelessWidget {
  const RewardItemPreview({
    super.key,
    required this.item,
    this.breed = 'siamese',
    this.equipped = false,
    this.locked = false,
    this.size = 92,
  });

  final RewardShopItem item;
  final String breed;
  final bool equipped;
  final bool locked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = rarityPalette(context, item.rarity);
    final previewBreed = item.category == 'breeds' ? (item.value ?? breed) : breed;
    final previewAccessory = item.category == 'accessories' ? (item.value ?? 'none') : 'none';
    final previewEffect = item.category == 'effects' ? (item.value ?? 'none') : 'none';

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
                child: avatarPreview(
                  context,
                  breed: previewBreed,
                  accessory: previewAccessory,
                  effect: previewEffect,
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

Widget progressStat(BuildContext context, String label, String value) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.98),
          context.colors.softMintGradient.colors.last.withOpacity(0.96),
          const Color(0xFFE3F7EF).withOpacity(0.92),
        ],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colors.primary.withOpacity(0.16)),
      boxShadow: [
        BoxShadow(
          color: context.colors.primary.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.7),
          blurRadius: 10,
          spreadRadius: -6,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.mutedForeground),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.94, end: 1),
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, alignment: Alignment.centerLeft, child: child),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: context.colors.foreground,
            ),
          ),
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
    return compact ? button : PulseGlow(color: context.colors.primary, child: button);
  }
}

class QuestRewardButton extends StatelessWidget {
  const QuestRewardButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isClaimable,
    required this.isClaimed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isClaimable;
  final bool isClaimed;

  @override
  Widget build(BuildContext context) {
    final gradient = isClaimed
        ? [
            const Color(0xFFDCEFE7),
            const Color(0xFFBEDFD1),
          ]
        : isClaimable
            ? [
                const Color(0xFFFFD86E),
                const Color(0xFFFFAF6D),
              ]
            : [
                const Color(0xFFE5EFEA),
                const Color(0xFFD4E7DF),
              ];
    final foreground = isClaimed ? context.colors.success : (isClaimable ? Colors.white : context.colors.mutedForeground);
    final button = PressScale(
      onTap: onPressed,
      scale: isClaimable ? 0.95 : 0.98,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isClaimed ? 0.86 : (isClaimable ? 1 : 0.72),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isClaimable ? Colors.white.withOpacity(0.28) : Colors.white.withOpacity(0.7),
              width: isClaimable ? 1.2 : 1,
            ),
            boxShadow: isClaimable
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFB564).withOpacity(0.34),
                      blurRadius: 26,
                      spreadRadius: -4,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFE2A8).withOpacity(0.46),
                      blurRadius: 18,
                      spreadRadius: -10,
                      offset: const Offset(0, -2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: context.colors.primary.withOpacity(0.08),
                      blurRadius: 16,
                      spreadRadius: -6,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 19, color: foreground),
            ],
          ),
        ),
      ),
    );

    if (isClaimable && !isClaimed) {
      return PulseGlow(color: const Color(0xFFFFC26F), child: button);
    }

    return button;
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
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF309F89),
                context.colors.primary,
                context.colors.primaryGlow,
                const Color(0xFFF7E5C2),
              ],
              stops: const [0, 0.38, 0.72, 1],
            ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.16),
            blurRadius: 30,
            spreadRadius: -10,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 14,
            spreadRadius: -12,
            offset: const Offset(0, -2),
          ),
        ],
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
        border: Border.all(color: Colors.white.withOpacity(0.82)),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.08),
            blurRadius: 26,
            spreadRadius: -8,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.68),
            blurRadius: 12,
            spreadRadius: -8,
            offset: const Offset(0, -2),
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
