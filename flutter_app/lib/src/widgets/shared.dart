import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:rive/rive.dart' as rive;
import '../core/app_theme.dart';
import '../core/models.dart';

class PointsChip extends StatelessWidget {
  const PointsChip({required this.totalPoints});

  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF7D8).withOpacity(0.96),
            const Color(0xFFFFE6A8).withOpacity(0.94),
            const Color(0xFFF5C96F).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE6BE67).withOpacity(0.28),
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
              color: Color(0xFFFFF4CD),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF78521B), size: 12),
          ),
          const SizedBox(width: 6),
          Text(
            '$totalPoints pts',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF6A4818)),
          ),
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
      return 'Cap';
    case 'backpack':
    case 'bag':
      return 'Backpack';
    case 'necklace':
      return 'Coin Necklace';
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
      return Icons.sports_baseball_rounded;
    case 'backpack':
    case 'bag':
      return Icons.shopping_bag_rounded;
    case 'necklace':
      return Icons.monetization_on_rounded;
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

String _normalizedBreed(String breed) {
  switch (breed) {
    case 'tabby':
      return 'orange_tabby';
    case 'black':
      return 'black_cat';
    case 'persian':
      return 'british_shorthair';
    case 'calico':
      return 'siamese';
    default:
      return breed;
  }
}

String _normalizedCoatVariant(String color) {
  switch (color) {
    case 'mint':
      return 'classic';
    case 'peach':
      return 'warm';
    case 'sky':
      return 'cool';
    case 'rose':
      return 'soft';
    case 'lavender':
      return 'deep';
    default:
      return color;
  }
}

Color _avatarColor(String color) {
  switch (_normalizedCoatVariant(color)) {
    case 'warm':
      return const Color(0xFFD29554);
    case 'cool':
      return const Color(0xFFB0A89E);
    case 'soft':
      return const Color(0xFFCBB8A2);
    case 'deep':
      return const Color(0xFF534A48);
    default:
      return const Color(0xFFE2A35B);
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
    final breedSpec = _guardianBreedSpec(widget.breed, widget.color);
    final moodConfig = _guardianMoodStyle(context, widget.mood);
    final lookSpec = _guardianLookSpec(
      baseColor: breedSpec.base,
      accessory: widget.accessory,
      outfit: widget.outfit,
      cosmetic: widget.cosmetic,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _tailController, _blinkController, _sparkleController]),
      builder: (context, child) {
        final floatY = (_floatController.value - 0.5) * 10;
        final blink = widget.mood == AvatarMood.sad ? 0.25 : 1 - (_blinkController.value > 0.92 ? 0.8 : 0.0);
        final tailTurn = (_tailController.value - 0.5) * 0.55;
        final auraScale = 0.96 + (_sparkleController.value * 0.08);
        final sparkleLift = (_sparkleController.value - 0.5) * 12;
        final pulse = 0.97 + math.sin(_sparkleController.value * math.pi * 2) * 0.03;
        return Transform.translate(
          offset: Offset(0, floatY),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: Container(
              key: ValueKey('${widget.accessory}-${widget.outfit}-${widget.cosmetic}-${widget.mood}-${widget.color}'),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    lookSpec.stageGlow.withOpacity(0.28),
                    moodConfig.tint.withOpacity(0.45),
                    const Color(0xFFFFF6E7),
                  ],
                  stops: const [0, 0.38, 0.75, 1],
                ),
                borderRadius: BorderRadius.circular(widget.size * 0.36),
                border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: lookSpec.glow.withOpacity(0.24),
                    blurRadius: 36,
                    spreadRadius: -6,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.58),
                    blurRadius: 18,
                    spreadRadius: -10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.size * 0.36),
                        gradient: RadialGradient(
                          center: const Alignment(-0.15, -0.18),
                          radius: 0.95,
                          colors: [
                            Colors.white.withOpacity(0.86),
                            Colors.white.withOpacity(0.26),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.36, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Transform.scale(
                        scale: auraScale * pulse,
                        child: Container(
                          width: widget.size * 0.72,
                          height: widget.size * 0.72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                lookSpec.glow.withOpacity(0.4),
                                lookSpec.stageGlow.withOpacity(0.16),
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
                      width: widget.size * 0.2,
                      height: widget.size * 0.2,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.14),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.size * 0.15,
                    right: widget.size * 0.15,
                    bottom: widget.size * 0.08,
                    child: Transform.scale(
                      scaleY: 0.42,
                      child: Container(
                        height: widget.size * 0.12,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              lookSpec.shadow.withOpacity(0.28),
                              lookSpec.shadow.withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(widget.size),
                        ),
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
                            color: lookSpec.glow,
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
                          if (widget.cosmetic == 'sparkle')
                            _guardianSparkle(
                              size: widget.size,
                              alignment: const Alignment(-0.18, -0.7),
                              color: const Color(0xFFFFED98),
                              offsetY: -sparkleLift * 0.22,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (lookSpec.rarityLevel > 0)
                    Positioned(
                      right: widget.size * 0.08,
                      top: widget.size * 0.08,
                      child: Container(
                        width: widget.size * 0.11,
                        height: widget.size * 0.11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white,
                              lookSpec.glow,
                              lookSpec.glow.withOpacity(0.35),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: lookSpec.glow.withOpacity(0.34),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          lookSpec.rarityLevel >= 3 ? Icons.auto_awesome_rounded : Icons.diamond_rounded,
                          size: widget.size * 0.05,
                          color: lookSpec.shadow,
                        ),
                      ),
                    ),
                  Center(
                    child: SizedBox(
                      width: widget.size * 0.84,
                      height: widget.size * 0.84,
                      child: _GuardianCharacterLayer(
                        breed: widget.breed,
                        color: widget.color,
                        accessory: widget.accessory,
                        outfit: widget.outfit,
                        cosmetic: widget.cosmetic,
                        mood: widget.mood,
                        expression: avatarMoodId(widget.mood),
                        size: widget.size * 0.84,
                        fallback: CustomPaint(
                          painter: _WalletGuardianPainter(
                            breed: widget.breed,
                            color: widget.color,
                            bodyColor: breedSpec.base,
                            mood: widget.mood,
                            tailTurn: tailTurn,
                            blinkAmount: blink,
                            accessory: widget.accessory,
                            outfit: widget.outfit,
                            cosmetic: widget.cosmetic,
                            sparklePhase: _sparkleController.value,
                            lookSpec: lookSpec,
                          ),
                        ),
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
    required this.icon,
  });

  final Color highlight;
  final Color tint;
  final IconData icon;
}

class _GuardianLookSpec {
  const _GuardianLookSpec({
    required this.base,
    required this.baseShade,
    required this.cream,
    required this.glow,
    required this.stageGlow,
    required this.shadow,
    required this.rarityLevel,
  });

  final Color base;
  final Color baseShade;
  final Color cream;
  final Color glow;
  final Color stageGlow;
  final Color shadow;
  final int rarityLevel;
}

class _GuardianBreedSpec {
  const _GuardianBreedSpec({
    required this.base,
    required this.baseShade,
    required this.cream,
    required this.earInner,
    required this.eyeColor,
    required this.blush,
    required this.headWidth,
    required this.headHeight,
    required this.bodyWidth,
    required this.bodyHeight,
    required this.eyeY,
    required this.eyeSpacing,
    required this.eyeWidth,
    required this.eyeHeight,
    required this.cheekY,
    required this.cheekWidth,
    required this.cheekHeight,
    required this.muzzleWidth,
    required this.muzzleHeight,
    required this.tailThickness,
    required this.tailTipY,
    required this.earInset,
  });

  final Color base;
  final Color baseShade;
  final Color cream;
  final Color earInner;
  final Color eyeColor;
  final Color blush;
  final double headWidth;
  final double headHeight;
  final double bodyWidth;
  final double bodyHeight;
  final double eyeY;
  final double eyeSpacing;
  final double eyeWidth;
  final double eyeHeight;
  final double cheekY;
  final double cheekWidth;
  final double cheekHeight;
  final double muzzleWidth;
  final double muzzleHeight;
  final double tailThickness;
  final double tailTipY;
  final double earInset;
}

_GuardianBreedSpec _guardianBreedSpec(String breed, String color) {
  final normalizedBreed = _normalizedBreed(breed);
  final coat = _normalizedCoatVariant(color);

  switch (normalizedBreed) {
    case 'black_cat':
      final deepBlack = switch (coat) {
        'warm' => const Color(0xFF3E332F),
        'cool' => const Color(0xFF2E3338),
        'soft' => const Color(0xFF403537),
        _ => const Color(0xFF232529),
      };
      return _GuardianBreedSpec(
        base: deepBlack,
        baseShade: const Color(0xFF111316),
        cream: const Color(0xFFE7DFD8),
        earInner: const Color(0xFF705A62),
        eyeColor: const Color(0xFFE3D982),
        blush: const Color(0xFFC89292),
        headWidth: 0.46,
        headHeight: 0.37,
        bodyWidth: 0.42,
        bodyHeight: 0.34,
        eyeY: 0.445,
        eyeSpacing: 0.118,
        eyeWidth: 0.102,
        eyeHeight: 0.11,
        cheekY: 0.548,
        cheekWidth: 0.068,
        cheekHeight: 0.044,
        muzzleWidth: 0.24,
        muzzleHeight: 0.15,
        tailThickness: 0.098,
        tailTipY: 0.17,
        earInset: 0.18,
      );
    case 'siamese':
      final creamBase = switch (coat) {
        'warm' => const Color(0xFFEAD0B2),
        'cool' => const Color(0xFFE5DDD3),
        'soft' => const Color(0xFFE8D7C4),
        _ => const Color(0xFFF0E6D8),
      };
      return _GuardianBreedSpec(
        base: creamBase,
        baseShade: const Color(0xFF8B6E5A),
        cream: const Color(0xFFFFF5EA),
        earInner: const Color(0xFFB4877A),
        eyeColor: const Color(0xFF7EC6FF),
        blush: const Color(0xFFD6B3A8),
        headWidth: 0.47,
        headHeight: 0.36,
        bodyWidth: 0.43,
        bodyHeight: 0.34,
        eyeY: 0.448,
        eyeSpacing: 0.12,
        eyeWidth: 0.106,
        eyeHeight: 0.108,
        cheekY: 0.545,
        cheekWidth: 0.064,
        cheekHeight: 0.04,
        muzzleWidth: 0.235,
        muzzleHeight: 0.145,
        tailThickness: 0.102,
        tailTipY: 0.18,
        earInset: 0.19,
      );
    case 'british_shorthair':
      final plushGray = switch (coat) {
        'warm' => const Color(0xFFB8ACA4),
        'cool' => const Color(0xFFA8B1BC),
        'soft' => const Color(0xFFBAB3BF),
        _ => const Color(0xFFA7ABB3),
      };
      return _GuardianBreedSpec(
        base: plushGray,
        baseShade: const Color(0xFF717883),
        cream: const Color(0xFFF8F4F0),
        earInner: const Color(0xFFD2B9BF),
        eyeColor: const Color(0xFFE0C56A),
        blush: const Color(0xFFD7B1B6),
        headWidth: 0.52,
        headHeight: 0.4,
        bodyWidth: 0.49,
        bodyHeight: 0.37,
        eyeY: 0.455,
        eyeSpacing: 0.122,
        eyeWidth: 0.114,
        eyeHeight: 0.115,
        cheekY: 0.552,
        cheekWidth: 0.082,
        cheekHeight: 0.052,
        muzzleWidth: 0.28,
        muzzleHeight: 0.165,
        tailThickness: 0.12,
        tailTipY: 0.2,
        earInset: 0.205,
      );
    default:
      final tabbyOrange = switch (coat) {
        'warm' => const Color(0xFFD4873C),
        'cool' => const Color(0xFFC68D5E),
        'soft' => const Color(0xFFE0A16C),
        'deep' => const Color(0xFFB96E3E),
        _ => const Color(0xFFE19B4E),
      };
      return _GuardianBreedSpec(
        base: tabbyOrange,
        baseShade: const Color(0xFFB56A30),
        cream: const Color(0xFFFFF2DE),
        earInner: const Color(0xFFF3B69C),
        eyeColor: const Color(0xFF7C5B21),
        blush: const Color(0xFFFFC6B6),
        headWidth: 0.51,
        headHeight: 0.39,
        bodyWidth: 0.47,
        bodyHeight: 0.36,
        eyeY: 0.452,
        eyeSpacing: 0.12,
        eyeWidth: 0.116,
        eyeHeight: 0.118,
        cheekY: 0.548,
        cheekWidth: 0.088,
        cheekHeight: 0.054,
        muzzleWidth: 0.29,
        muzzleHeight: 0.17,
        tailThickness: 0.12,
        tailTipY: 0.19,
        earInset: 0.2,
      );
  }
}

_GuardianLookSpec _guardianLookSpec({
  required Color baseColor,
  required String accessory,
  required String outfit,
  required String cosmetic,
}) {
  Color glow = const Color(0xFF6FD1B6);
  Color stageGlow = const Color(0xFFCFF5E8);
  int rarityLevel = 0;

  if (cosmetic == 'sparkle' || accessory == 'headphones' || outfit == 'Cape') {
    glow = const Color(0xFFF4B45E);
    stageGlow = const Color(0xFFFFE6B5);
    rarityLevel = 3;
  } else if (accessory == 'crown' || outfit == 'Jacket') {
    glow = const Color(0xFF8B7AF3);
    stageGlow = const Color(0xFFE8DFFF);
    rarityLevel = 2;
  } else if (accessory == 'scarf' || accessory == 'bag' || accessory == 'backpack' || cosmetic == 'coins') {
    glow = const Color(0xFF5DB8E8);
    stageGlow = const Color(0xFFD8F4FF);
    rarityLevel = 1;
  }

  return _GuardianLookSpec(
    base: baseColor,
    baseShade: Color.lerp(baseColor, const Color(0xFF1F6558), 0.34)!,
    cream: const Color(0xFFFFFBF4),
    glow: glow,
    stageGlow: stageGlow,
    shadow: const Color(0xFF29463F),
    rarityLevel: rarityLevel,
  );
}

_GuardianMoodStyle _guardianMoodStyle(BuildContext context, AvatarMood mood) {
  return switch (mood) {
    AvatarMood.happy => _GuardianMoodStyle(
        highlight: context.colors.success,
        tint: const Color(0xFFD9F7E7),
        icon: Icons.favorite_rounded,
      ),
    AvatarMood.sad => _GuardianMoodStyle(
        highlight: context.colors.warning,
        tint: const Color(0xFFFFE7D0),
        icon: Icons.water_drop_rounded,
      ),
    AvatarMood.excited => _GuardianMoodStyle(
        highlight: context.colors.accentForeground,
        tint: const Color(0xFFFFECD0),
        icon: Icons.auto_awesome_rounded,
      ),
    AvatarMood.proud => _GuardianMoodStyle(
        highlight: context.colors.accentForeground,
        tint: const Color(0xFFFFE2C2),
        icon: Icons.workspace_premium_rounded,
      ),
    AvatarMood.neutral => _GuardianMoodStyle(
        highlight: context.colors.primary,
        tint: const Color(0xFFDFF6EF),
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
        width: size * 0.095,
        height: size * 0.095,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.white,
              color.withOpacity(0.95),
              color.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(size),
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

class _GuardianCharacterLayer extends StatefulWidget {
  const _GuardianCharacterLayer({
    required this.breed,
    required this.color,
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
    required this.mood,
    required this.expression,
    required this.size,
    required this.fallback,
  });

  final String breed;
  final String color;
  final String accessory;
  final String outfit;
  final String cosmetic;
  final AvatarMood mood;
  final String expression;
  final double size;
  final Widget fallback;

  @override
  State<_GuardianCharacterLayer> createState() => _GuardianCharacterLayerState();
}

class _GuardianCharacterLayerState extends State<_GuardianCharacterLayer> {
  late final rive.FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = rive.FileLoader.fromAsset(
      'assets/rive/wallet_guardian.riv',
      riveFactory: rive.Factory.rive,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rive.RiveWidgetBuilder(
      fileLoader: _fileLoader,
      builder: (context, state) {
        return switch (state) {
          rive.RiveLoaded loaded => rive.RiveWidget(
              controller: loaded.controller,
              fit: rive.Fit.contain,
            ),
          rive.RiveLoading() => widget.fallback,
          rive.RiveFailed() => widget.fallback,
          _ => widget.fallback,
        };
      },
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

AvatarMood avatarMoodFromId(String mood) {
  switch (mood) {
    case 'happy':
      return AvatarMood.happy;
    case 'sad':
      return AvatarMood.sad;
    case 'excited':
      return AvatarMood.excited;
    case 'proud':
      return AvatarMood.proud;
    default:
      return AvatarMood.neutral;
  }
}

String avatarMoodId(AvatarMood mood) {
  switch (mood) {
    case AvatarMood.happy:
      return 'happy';
    case AvatarMood.neutral:
      return 'neutral';
    case AvatarMood.sad:
      return 'sad';
    case AvatarMood.excited:
      return 'excited';
    case AvatarMood.proud:
      return 'proud';
  }
}

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
    required this.breed,
    required this.color,
    required this.bodyColor,
    required this.mood,
    required this.tailTurn,
    required this.blinkAmount,
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
    required this.sparklePhase,
    required this.lookSpec,
  });

  final String breed;
  final String color;
  final Color bodyColor;
  final AvatarMood mood;
  final double tailTurn;
  final double blinkAmount;
  final String accessory;
  final String outfit;
  final String cosmetic;
  final double sparklePhase;
  final _GuardianLookSpec lookSpec;

  @override
  void paint(Canvas canvas, Size size) {
    final breedSpec = _guardianBreedSpec(breed, color);
    final center = Offset(size.width / 2, size.height * 0.56);
    final headCenter = Offset(size.width / 2, size.height * 0.36);
    final headRect = Rect.fromCenter(
      center: headCenter.translate(0, size.height * 0.025),
      width: size.width * breedSpec.headWidth,
      height: size.height * breedSpec.headHeight,
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(breedSpec.base, Colors.white, 0.18)!,
          breedSpec.base,
          breedSpec.baseShade,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final creamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          breedSpec.cream,
          const Color(0xFFF4E6CF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final linePaint = Paint()
      ..color = lookSpec.shadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;
    final cheekPaint = Paint()..color = breedSpec.blush.withOpacity(0.75);
    final softShadow = Paint()
      ..color = lookSpec.shadow.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final outlineFill = Paint()..color = lookSpec.shadow.withOpacity(0.1);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.84),
        width: size.width * 0.42,
        height: size.height * 0.08,
      ),
      softShadow,
    );

    _paintBackLayer(canvas, size);

    final tailPath = Path()
      ..moveTo(size.width * 0.68, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * (0.98 + tailTurn * 0.08),
        size.height * 0.48,
        size.width * (0.82 + tailTurn * 0.08),
        size.height * breedSpec.tailTipY,
      );
    canvas.drawPath(
      tailPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            breedSpec.baseShade,
            breedSpec.base,
            Color.lerp(breedSpec.base, Colors.white, 0.16)!,
          ],
        ).createShader(Rect.fromLTWH(size.width * 0.64, size.height * 0.14, size.width * 0.24, size.height * 0.56))
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * breedSpec.tailThickness
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(size.width * (0.82 + tailTurn * 0.08), size.height * breedSpec.tailTipY),
      size.width * 0.028,
      Paint()..color = Color.lerp(breedSpec.base, Colors.white, 0.08)!,
    );

    final earLeft = Path()
      ..moveTo(size.width * breedSpec.earInset, size.height * 0.3)
      ..quadraticBezierTo(size.width * breedSpec.earInset, size.height * 0.04, size.width * 0.4, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.47, size.height * 0.24, size.width * 0.42, size.height * 0.37)
      ..close();
    final earRight = Path()
      ..moveTo(size.width * (1 - breedSpec.earInset), size.height * 0.3)
      ..quadraticBezierTo(size.width * (1 - breedSpec.earInset), size.height * 0.04, size.width * 0.6, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.53, size.height * 0.24, size.width * 0.58, size.height * 0.37)
      ..close();
    canvas.drawPath(earLeft, bodyPaint);
    canvas.drawPath(earRight, bodyPaint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.28, size.height * 0.28)
        ..quadraticBezierTo(size.width * 0.31, size.height * 0.17, size.width * 0.38, size.height * 0.22)
        ..quadraticBezierTo(size.width * 0.36, size.height * 0.29, size.width * 0.34, size.height * 0.35)
        ..close(),
      Paint()..color = breedSpec.earInner.withOpacity(0.82),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.72, size.height * 0.28)
        ..quadraticBezierTo(size.width * 0.69, size.height * 0.17, size.width * 0.62, size.height * 0.22)
        ..quadraticBezierTo(size.width * 0.64, size.height * 0.29, size.width * 0.66, size.height * 0.35)
        ..close(),
      Paint()..color = breedSpec.earInner.withOpacity(0.82),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.16),
        width: size.width * 0.46,
        height: size.height * 0.26,
      ),
      softShadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(size.width * 0.2)),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.11),
        width: size.width * breedSpec.bodyWidth,
        height: size.height * breedSpec.bodyHeight,
      ),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, size.height * 0.14),
        width: size.width * 0.32,
        height: size.height * 0.24,
      ),
      Paint()..color = Colors.white.withOpacity(0.06),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.3, size.height * 0.49)
        ..quadraticBezierTo(size.width * 0.24, size.height * 0.55, size.width * 0.3, size.height * 0.61)
        ..quadraticBezierTo(size.width * 0.39, size.height * 0.59, size.width * 0.41, size.height * 0.51)
        ..close(),
      Paint()..color = Colors.white.withOpacity(0.1),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.7, size.height * 0.49)
        ..quadraticBezierTo(size.width * 0.76, size.height * 0.55, size.width * 0.7, size.height * 0.61)
        ..quadraticBezierTo(size.width * 0.61, size.height * 0.59, size.width * 0.59, size.height * 0.51)
        ..close(),
      Paint()..color = Colors.white.withOpacity(0.1),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.5 - breedSpec.eyeSpacing), size.height * breedSpec.cheekY),
        width: size.width * breedSpec.cheekWidth * 1.7,
        height: size.height * breedSpec.cheekHeight * 2.2,
      ),
      creamPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.5 + breedSpec.eyeSpacing), size.height * breedSpec.cheekY),
        width: size.width * breedSpec.cheekWidth * 1.7,
        height: size.height * breedSpec.cheekHeight * 2.2,
      ),
      creamPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.515),
        width: size.width * breedSpec.muzzleWidth,
        height: size.height * breedSpec.muzzleHeight,
      ),
      creamPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.565),
        width: size.width * (breedSpec.muzzleWidth * 0.64),
        height: size.height * (breedSpec.muzzleHeight * 0.62),
      ),
      creamPaint,
    );
    _paintBreedPattern(canvas, size);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * (0.5 - breedSpec.eyeSpacing - 0.02), size.height * breedSpec.cheekY), width: size.width * breedSpec.cheekWidth, height: size.height * breedSpec.cheekHeight), cheekPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * (0.5 + breedSpec.eyeSpacing + 0.02), size.height * breedSpec.cheekY), width: size.width * breedSpec.cheekWidth, height: size.height * breedSpec.cheekHeight), cheekPaint);

    final eyeWhitePaint = Paint()..color = Colors.white.withOpacity(0.96);
    final pupilPaint = Paint()..color = const Color(0xFF223B35);
    final irisPaint = Paint()..color = breedSpec.eyeColor.withOpacity(0.78);
    final eyeHeight = size.height * breedSpec.eyeHeight;
    final eyeWidth = size.width * breedSpec.eyeWidth * (mood == AvatarMood.excited ? 1.08 : 1);
    final eyeScaleY = blinkAmount.clamp(0.12, 1.0);

    void paintEye(Offset eyeCenter, {double tilt = 0}) {
      canvas.save();
      canvas.translate(eyeCenter.dx, eyeCenter.dy);
      canvas.rotate(tilt);
      canvas.scale(1, eyeScaleY);
      final eyeRect = Rect.fromCenter(center: Offset.zero, width: eyeWidth, height: eyeHeight);
      canvas.drawShadow(
        Path()..addRRect(RRect.fromRectAndRadius(eyeRect, Radius.circular(size.width * 0.07))),
        lookSpec.shadow.withOpacity(0.14),
        3,
        false,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(eyeRect, Radius.circular(size.width * 0.07)), eyeWhitePaint);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, eyeHeight * 0.05), width: eyeWidth * 0.42, height: eyeHeight * 0.74),
        irisPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, eyeHeight * 0.06), width: eyeWidth * 0.28, height: eyeHeight * 0.56),
        pupilPaint,
      );
      canvas.drawCircle(Offset(-eyeWidth * 0.11, -eyeHeight * 0.16), size.width * 0.014, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(eyeWidth * 0.02, eyeHeight * 0.06), size.width * 0.007, Paint()..color = Colors.white.withOpacity(0.72));
      canvas.restore();
    }

    if (blinkAmount < 0.2) {
      canvas.drawLine(Offset(size.width * (0.5 - breedSpec.eyeSpacing - 0.05), size.height * breedSpec.eyeY), Offset(size.width * (0.5 - breedSpec.eyeSpacing + 0.05), size.height * (breedSpec.eyeY + 0.003)), linePaint);
      canvas.drawLine(Offset(size.width * (0.5 + breedSpec.eyeSpacing - 0.05), size.height * (breedSpec.eyeY + 0.003)), Offset(size.width * (0.5 + breedSpec.eyeSpacing + 0.05), size.height * breedSpec.eyeY), linePaint);
    } else {
      final normalizedBreed = _normalizedBreed(breed);
      paintEye(Offset(size.width * (0.5 - breedSpec.eyeSpacing), size.height * breedSpec.eyeY), tilt: normalizedBreed == 'black_cat' ? -0.07 : -0.04);
      paintEye(Offset(size.width * (0.5 + breedSpec.eyeSpacing), size.height * breedSpec.eyeY), tilt: normalizedBreed == 'black_cat' ? 0.07 : 0.04);
    }

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.53)
        ..quadraticBezierTo(size.width * 0.502, size.height * 0.565, size.width * 0.5, size.height * 0.588),
      Paint()
        ..color = lookSpec.shadow.withOpacity(0.42)
        ..strokeWidth = size.width * 0.012
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.533),
        width: size.width * 0.065,
        height: size.height * 0.045,
      ),
      Paint()..color = const Color(0xFFED9A9A),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.517),
        width: size.width * 0.048,
        height: size.height * 0.026,
      ),
      Paint()..color = const Color(0xFF2B433D),
    );

    final mouthPath = Path();
    switch (mood) {
      case AvatarMood.happy:
        mouthPath.moveTo(size.width * 0.446, size.height * 0.615);
        mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.652, size.width * 0.554, size.height * 0.615);
        break;
      case AvatarMood.sad:
        mouthPath.moveTo(size.width * 0.446, size.height * 0.624);
        mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.592, size.width * 0.554, size.height * 0.624);
        break;
      case AvatarMood.excited:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.626), width: size.width * 0.086, height: size.height * 0.06),
          Paint()..color = const Color(0xFF243C35),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.64), width: size.width * 0.05, height: size.height * 0.024),
          Paint()..color = const Color(0xFFF58E9B),
        );
        break;
      case AvatarMood.neutral:
        mouthPath.moveTo(size.width * 0.464, size.height * 0.617);
        mouthPath.lineTo(size.width * 0.536, size.height * 0.617);
        break;
      case AvatarMood.proud:
        mouthPath.moveTo(size.width * 0.446, size.height * 0.614);
        mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.648, size.width * 0.558, size.height * 0.606);
        break;
    }
    if (mood != AvatarMood.excited) {
      canvas.drawPath(mouthPath, linePaint);
    }

    for (final whisker in [
      (const Offset(-0.085, 0.565), const Offset(-0.27, 0.545)),
      (const Offset(-0.09, 0.59), const Offset(-0.295, 0.595)),
      (const Offset(-0.085, 0.61), const Offset(-0.258, 0.64)),
      (const Offset(0.085, 0.565), const Offset(0.27, 0.545)),
      (const Offset(0.09, 0.59), const Offset(0.295, 0.595)),
      (const Offset(0.085, 0.61), const Offset(0.258, 0.64)),
    ]) {
      canvas.drawLine(
        Offset(size.width * (0.5 + whisker.$1.dx), size.height * whisker.$1.dy),
        Offset(size.width * (0.5 + whisker.$2.dx), size.height * whisker.$2.dy),
        Paint()
          ..color = lookSpec.shadow.withOpacity(0.52)
          ..strokeWidth = size.width * 0.01
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.41, size.height * 0.764), width: size.width * 0.1, height: size.height * 0.072), creamPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.59, size.height * 0.764), width: size.width * 0.1, height: size.height * 0.072), creamPaint);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.285), width: size.width * 0.12, height: size.height * 0.05),
      Paint()..color = Colors.white.withOpacity(0.18),
    );
    for (final pawX in [0.43, 0.57]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * pawX, size.height * 0.748),
          width: size.width * 0.082,
          height: size.height * 0.14,
        ),
        outlineFill,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * pawX, size.height * 0.785),
          width: size.width * 0.112,
          height: size.height * 0.068,
        ),
        Paint()..color = const Color(0xFFFFDCD6).withOpacity(0.9),
      );
      for (final toeOffset in [-0.025, 0.0, 0.025]) {
        canvas.drawCircle(
          Offset(size.width * (pawX + toeOffset), size.height * 0.785),
          size.width * 0.01,
          Paint()..color = const Color(0xFFF6B8B2).withOpacity(0.95),
        );
      }
    }

    _paintOutfit(canvas, size);
    _paintAccessory(canvas, size);
    _paintCosmetic(canvas, size);
  }

  void _paintBackLayer(Canvas canvas, Size size) {
    if (outfit == 'Cape') {
      _paintOutfit(canvas, size);
    }
    if (accessory == 'backpack' || accessory == 'bag') {
      _paintAccessory(canvas, size);
    }
  }

  void _paintBreedPattern(Canvas canvas, Size size) {
    switch (_normalizedBreed(breed)) {
      case 'orange_tabby':
        final stripePaint = Paint()
          ..color = const Color(0xFFB5662A).withOpacity(0.5)
          ..strokeWidth = size.width * 0.026
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(size.width * 0.42, size.height * 0.285), Offset(size.width * 0.39, size.height * 0.34), stripePaint);
        canvas.drawLine(Offset(size.width * 0.5, size.height * 0.27), Offset(size.width * 0.5, size.height * 0.34), stripePaint);
        canvas.drawLine(Offset(size.width * 0.58, size.height * 0.285), Offset(size.width * 0.61, size.height * 0.34), stripePaint);
        canvas.drawLine(Offset(size.width * 0.34, size.height * 0.59), Offset(size.width * 0.3, size.height * 0.67), stripePaint);
        canvas.drawLine(Offset(size.width * 0.66, size.height * 0.59), Offset(size.width * 0.7, size.height * 0.67), stripePaint);
        break;
      case 'siamese':
        final pointsPaint = Paint()..color = const Color(0xFF8E6F5C).withOpacity(0.88);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.37, size.height * 0.315), width: size.width * 0.12, height: size.height * 0.08),
          pointsPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.63, size.height * 0.315), width: size.width * 0.12, height: size.height * 0.08),
          pointsPaint,
        );
        break;
      case 'black_cat':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.51, size.height * 0.46), width: size.width * 0.08, height: size.height * 0.032),
          Paint()..color = Colors.white.withOpacity(0.14),
        );
        break;
      case 'british_shorthair':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.36, size.height * 0.52), width: size.width * 0.09, height: size.height * 0.09),
          Paint()..color = Colors.white.withOpacity(0.16),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.64, size.height * 0.52), width: size.width * 0.09, height: size.height * 0.09),
          Paint()..color = Colors.white.withOpacity(0.16),
        );
        break;
    }
  }

  void _paintAccessory(Canvas canvas, Size size) {
    switch (accessory) {
      case 'hat':
        canvas.drawArc(
          Rect.fromLTWH(size.width * 0.3, size.height * 0.09, size.width * 0.4, size.height * 0.18),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFF193C36)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.06,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.23), width: size.width * 0.38, height: size.height * 0.075),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF102C28), Color(0xFF35645C), Color(0xFF173A36)],
            ).createShader(Rect.fromLTWH(size.width * 0.31, size.height * 0.19, size.width * 0.38, size.height * 0.08)),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.355, size.height * 0.11, size.width * 0.29, size.height * 0.125),
            Radius.circular(size.width * 0.05),
          ),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF68E0C1), Color(0xFF3D9A83), Color(0xFF1F5F52)],
            ).createShader(Rect.fromLTWH(size.width * 0.355, size.height * 0.11, size.width * 0.29, size.height * 0.125)),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.4, size.height * 0.145, size.width * 0.2, size.height * 0.028),
            Radius.circular(size.width * 0.02),
          ),
          Paint()..color = Colors.white.withOpacity(0.38),
        );
        break;
      case 'crown':
        canvas.drawShadow(
          Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(size.width * 0.31, size.height * 0.19, size.width * 0.38, size.height * 0.05),
                Radius.circular(size.width * 0.03),
              ),
            ),
          lookSpec.glow.withOpacity(0.45),
          8,
          false,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.31, size.height * 0.2, size.width * 0.38, size.height * 0.045),
            Radius.circular(size.width * 0.03),
          ),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFFFE28B), Color(0xFFF3B855), Color(0xFFDEA03C)],
            ).createShader(Rect.fromLTWH(size.width * 0.31, size.height * 0.2, size.width * 0.38, size.height * 0.045)),
        );
        final path = Path()
          ..moveTo(size.width * 0.31, size.height * 0.22)
          ..lineTo(size.width * 0.37, size.height * 0.11)
          ..lineTo(size.width * 0.45, size.height * 0.19)
          ..lineTo(size.width * 0.5, size.height * 0.08)
          ..lineTo(size.width * 0.55, size.height * 0.19)
          ..lineTo(size.width * 0.63, size.height * 0.11)
          ..lineTo(size.width * 0.69, size.height * 0.22)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFEDAE), Color(0xFFF1BB57)],
            ).createShader(Rect.fromLTWH(size.width * 0.31, size.height * 0.08, size.width * 0.38, size.height * 0.14)),
        );
        for (final gem in [0.38, 0.5, 0.62]) {
          canvas.drawCircle(
            Offset(size.width * gem, gem == 0.5 ? size.height * 0.14 : size.height * 0.17),
            size.width * 0.02,
            Paint()..color = gem == 0.5 ? const Color(0xFF7DF0D0) : const Color(0xFFFF8B95),
          );
          canvas.drawCircle(
            Offset(size.width * gem, gem == 0.5 ? size.height * 0.14 : size.height * 0.17),
            size.width * 0.008,
            Paint()..color = Colors.white.withOpacity(0.88),
          );
        }
        break;
      case 'ribbon':
        canvas.drawShadow(
          Path()
            ..addOval(Rect.fromCenter(center: Offset(size.width * 0.63, size.height * 0.24), width: size.width * 0.18, height: size.height * 0.12)),
          const Color(0xFF80354B).withOpacity(0.16),
          4,
          false,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.63, size.height * 0.245), width: size.width * 0.11, height: size.height * 0.074),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFFFC3D2), Color(0xFFFF8AA3), Color(0xFFE66082)],
            ).createShader(Rect.fromLTWH(size.width * 0.58, size.height * 0.21, size.width * 0.12, size.height * 0.08)),
        );
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.63, size.height * 0.274)
            ..lineTo(size.width * 0.59, size.height * 0.36)
            ..lineTo(size.width * 0.65, size.height * 0.322)
            ..close(),
          Paint()..color = const Color(0xFFF56F8E),
        );
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.66, size.height * 0.268)
            ..lineTo(size.width * 0.72, size.height * 0.35)
            ..lineTo(size.width * 0.655, size.height * 0.322)
            ..close(),
          Paint()..color = const Color(0xFFF56F8E),
        );
        canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.245), size.width * 0.014, Paint()..color = Colors.white.withOpacity(0.9));
        break;
      case 'glasses':
        final paint = Paint()
          ..color = const Color(0xFF3D505C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.022;
        final lensPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFD9F6FF).withOpacity(0.62),
              const Color(0xFF9ED8E8).withOpacity(0.24),
            ],
          ).createShader(Rect.fromLTWH(size.width * 0.32, size.height * 0.37, size.width * 0.36, size.height * 0.12));
        for (final x in [0.39, 0.61]) {
          final rect = Rect.fromCenter(center: Offset(size.width * x, size.height * 0.446), width: size.width * 0.122, height: size.height * 0.092);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.05)), lensPaint);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.05)), paint);
        }
        canvas.drawLine(Offset(size.width * 0.45, size.height * 0.446), Offset(size.width * 0.55, size.height * 0.446), paint);
        break;
      case 'headphones':
        final bandPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF705EFF), Color(0xFF3C366E)],
          ).createShader(Rect.fromLTWH(size.width * 0.18, size.height * 0.08, size.width * 0.64, size.height * 0.34))
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.038;
        canvas.drawArc(Rect.fromLTWH(size.width * 0.19, size.height * 0.11, size.width * 0.62, size.height * 0.38), 3.18, 3.05, false, bandPaint);
        for (final x in [0.2, 0.7]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(size.width * x, size.height * 0.36, size.width * 0.11, size.height * 0.165),
              Radius.circular(size.width * 0.05),
            ),
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB39CFF), Color(0xFF7164E0), Color(0xFF4C419A)],
              ).createShader(Rect.fromLTWH(size.width * x, size.height * 0.36, size.width * 0.11, size.height * 0.165)),
          );
          canvas.drawCircle(
            Offset(size.width * (x + 0.055), size.height * 0.445),
            size.width * 0.025,
            Paint()..color = const Color(0xFF90FFE7),
          );
        }
        break;
      case 'scarf':
        final knotY = size.height * 0.605 + math.sin(sparklePhase * math.pi * 2) * size.height * 0.006;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.29, size.height * 0.585, size.width * 0.42, size.height * 0.07),
            Radius.circular(size.width * 0.055),
          ),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFFFC2A9), Color(0xFFEF7A84), Color(0xFFC75165)],
            ).createShader(Rect.fromLTWH(size.width * 0.29, size.height * 0.585, size.width * 0.42, size.height * 0.07)),
        );
        final scarfTail = Path()
          ..moveTo(size.width * 0.55, knotY)
          ..quadraticBezierTo(size.width * 0.64, knotY + size.height * 0.08, size.width * 0.58, size.height * 0.79)
          ..lineTo(size.width * 0.49, size.height * 0.75)
          ..quadraticBezierTo(size.width * 0.57, size.height * 0.67, size.width * 0.5, knotY + size.height * 0.012)
          ..close();
        canvas.drawPath(
          scarfTail,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD0BE), Color(0xFFE96E7D), Color(0xFFC24A60)],
            ).createShader(Rect.fromLTWH(size.width * 0.49, knotY, size.width * 0.15, size.height * 0.2)),
        );
        break;
      case 'backpack':
      case 'bag':
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.61, size.height * 0.57)
            ..quadraticBezierTo(size.width * 0.72, size.height * 0.56, size.width * 0.74, size.height * 0.68),
          Paint()
            ..color = const Color(0xFF6C9285)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.02
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.62, size.height * 0.605, size.width * 0.14, size.height * 0.16),
            Radius.circular(size.width * 0.05),
          ),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFB5E0CD), Color(0xFF76A08D), Color(0xFF547463)],
            ).createShader(Rect.fromLTWH(size.width * 0.62, size.height * 0.605, size.width * 0.14, size.height * 0.16)),
        );
        canvas.drawCircle(Offset(size.width * 0.69, size.height * 0.685), size.width * 0.013, Paint()..color = const Color(0xFFFFE6B0));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.655, size.height * 0.626, size.width * 0.07, size.height * 0.026),
            Radius.circular(size.width * 0.014),
          ),
          Paint()..color = Colors.white.withOpacity(0.36),
        );
        break;
      case 'necklace':
        canvas.drawArc(
          Rect.fromLTWH(size.width * 0.33, size.height * 0.53, size.width * 0.34, size.height * 0.17),
          0.3,
          math.pi - 0.6,
          false,
          Paint()
            ..color = const Color(0xFFF2C45A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.02,
        );
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.655),
          size.width * 0.03,
          Paint()
            ..shader = const RadialGradient(
              colors: [Color(0xFFFFF1BD), Color(0xFFF0B947), Color(0xFFCB8A1A)],
            ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.655), radius: size.width * 0.03)),
        );
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.655),
          size.width * 0.013,
          Paint()..color = const Color(0xFFFFF1BA),
        );
        break;
    }
  }

  void _paintOutfit(Canvas canvas, Size size) {
    switch (outfit) {
      case 'Jacket':
        final jacketRect = Rect.fromLTWH(size.width * 0.26, size.height * 0.61, size.width * 0.48, size.height * 0.205);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            jacketRect,
            Radius.circular(size.width * 0.08),
          ),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC7DAF7), Color(0xFF7394BE), Color(0xFF435E84)],
            ).createShader(jacketRect),
        );
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.39, size.height * 0.61)
            ..lineTo(size.width * 0.47, size.height * 0.735)
            ..lineTo(size.width * 0.5, size.height * 0.64)
            ..lineTo(size.width * 0.53, size.height * 0.735)
            ..lineTo(size.width * 0.61, size.height * 0.61),
          Paint()..color = const Color(0xFFFFF3DF),
        );
        canvas.drawLine(
          Offset(size.width * 0.5, size.height * 0.63),
          Offset(size.width * 0.5, size.height * 0.8),
          Paint()
            ..color = const Color(0xFFE5EFFB).withOpacity(0.55)
            ..strokeWidth = size.width * 0.014,
        );
        break;
      case 'Cape':
        final path = Path()
          ..moveTo(size.width * 0.28, size.height * 0.575)
          ..lineTo(size.width * 0.72, size.height * 0.575)
          ..lineTo(size.width * 0.82, size.height * 0.86)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.79, size.width * 0.18, size.height * 0.86)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB9FFE9), Color(0xFF5BC4A5), Color(0xFF2D7867)],
            ).createShader(Rect.fromLTWH(size.width * 0.18, size.height * 0.575, size.width * 0.64, size.height * 0.285)),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.38, size.height * 0.568, size.width * 0.24, size.height * 0.058),
            Radius.circular(size.width * 0.03),
          ),
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFFFF0BF), Color(0xFFFFD679)],
            ).createShader(Rect.fromLTWH(size.width * 0.38, size.height * 0.568, size.width * 0.24, size.height * 0.058)),
        );
        break;
      default:
        final hoodieRect = Rect.fromLTWH(size.width * 0.28, size.height * 0.6, size.width * 0.44, size.height * 0.205);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            hoodieRect,
            Radius.circular(size.width * 0.09),
          ),
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFEBC0), Color(0xFFEDC371), Color(0xFFCB9447)],
            ).createShader(hoodieRect),
        );
        canvas.drawArc(
          Rect.fromLTWH(size.width * 0.315, size.height * 0.535, size.width * 0.37, size.height * 0.19),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFFD59A4D)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.034,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.445, size.height * 0.705, size.width * 0.11, size.height * 0.045),
            Radius.circular(size.width * 0.02),
          ),
          Paint()..color = const Color(0xFFF5D98C),
        );
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.29, size.height * 0.61)
            ..quadraticBezierTo(size.width * 0.23, size.height * 0.48, size.width * 0.32, size.height * 0.3)
            ..quadraticBezierTo(size.width * 0.36, size.height * 0.24, size.width * 0.43, size.height * 0.28),
          Paint()
            ..color = const Color(0xFFF2CC82).withOpacity(0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.042
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.71, size.height * 0.61)
            ..quadraticBezierTo(size.width * 0.77, size.height * 0.48, size.width * 0.68, size.height * 0.3)
            ..quadraticBezierTo(size.width * 0.64, size.height * 0.24, size.width * 0.57, size.height * 0.28),
          Paint()
            ..color = const Color(0xFFF2CC82).withOpacity(0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.042
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  void _paintCosmetic(Canvas canvas, Size size) {
    switch (cosmetic) {
      case 'sparkle':
        final glowPaint = Paint()
          ..color = lookSpec.glow.withOpacity(0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.26), size.width * 0.085, glowPaint);
        _paintStar(canvas, Offset(size.width * 0.75, size.height * 0.25), size.width * 0.04, const Color(0xFFFFF1A4));
        _paintStar(canvas, Offset(size.width * 0.67, size.height * 0.2), size.width * 0.026, Colors.white);
        _paintStar(canvas, Offset(size.width * 0.31, size.height * 0.16), size.width * 0.02, const Color(0xFFFFE39C));
        break;
      case 'coins':
        final swing = math.sin(sparklePhase * math.pi * 2) * size.width * 0.018;
        for (final coin in [
          Offset(size.width * 0.74 + swing, size.height * 0.25),
          Offset(size.width * 0.68 - swing * 0.7, size.height * 0.2),
          Offset(size.width * 0.3 + swing * 0.5, size.height * 0.24),
        ]) {
          canvas.drawCircle(coin, size.width * 0.032, Paint()..color = const Color(0xFFF3C55F));
          canvas.drawCircle(coin, size.width * 0.019, Paint()..color = const Color(0xFFFFF0B8));
        }
        break;
    }
  }

  void _paintStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + (math.pi / 4 * i);
      final r = i.isEven ? radius : radius * 0.42;
      final point = Offset(center.dx + math.cos(angle) * r, center.dy + math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WalletGuardianPainter oldDelegate) {
    return oldDelegate.breed != breed ||
        oldDelegate.color != color ||
        oldDelegate.bodyColor != bodyColor ||
        oldDelegate.mood != mood ||
        oldDelegate.tailTurn != tailTurn ||
        oldDelegate.blinkAmount != blinkAmount ||
        oldDelegate.accessory != accessory ||
        oldDelegate.outfit != outfit ||
        oldDelegate.cosmetic != cosmetic ||
        oldDelegate.sparklePhase != sparklePhase ||
        oldDelegate.lookSpec != lookSpec;
  }
}

class RewardItemPreview extends StatelessWidget {
  const RewardItemPreview({
    super.key,
    required this.item,
    this.breed = 'tabby',
    this.color = 'mint',
    this.equipped = false,
    this.locked = false,
    this.size = 92,
  });

  final RewardShopItem item;
  final String breed;
  final String color;
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
                  breed: breed,
                  color: color,
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





