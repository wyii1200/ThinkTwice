import 'dart:math' as math;

import 'package:flutter/material.dart';

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
      return 'Happy and glowing';
    case AvatarMood.neutral:
      return 'Calm and centered';
    case AvatarMood.sad:
      return 'A little worried';
    case AvatarMood.excited:
      return 'Excited and sparkly';
    case AvatarMood.proud:
      return 'Proud and playful';
  }
}

class CatBreedConfig {
  const CatBreedConfig({
    required this.id,
    required this.label,
    required this.baseColor,
    required this.shadeColor,
    required this.creamColor,
    required this.earInnerColor,
    required this.eyeColor,
    required this.blushColor,
    required this.headScaleX,
    required this.headScaleY,
    required this.earHeight,
    required this.earSpread,
    required this.eyeWidth,
    required this.eyeHeight,
    required this.eyeSpacing,
    required this.cheekOffset,
    required this.pattern,
  });

  final String id;
  final String label;
  final Color baseColor;
  final Color shadeColor;
  final Color creamColor;
  final Color earInnerColor;
  final Color eyeColor;
  final Color blushColor;
  final double headScaleX;
  final double headScaleY;
  final double earHeight;
  final double earSpread;
  final double eyeWidth;
  final double eyeHeight;
  final double eyeSpacing;
  final double cheekOffset;
  final String pattern;
}

const List<CatBreedConfig> catBreedConfigs = [
  CatBreedConfig(
    id: 'siamese',
    label: 'Siamese',
    baseColor: Color(0xFFF2E3D4),
    shadeColor: Color(0xFF7A655A),
    creamColor: Color(0xFFFFF6EE),
    earInnerColor: Color(0xFFD9A5A7),
    eyeColor: Color(0xFF6FC7FF),
    blushColor: Color(0xFFF6BFC2),
    headScaleX: 0.88,
    headScaleY: 0.82,
    earHeight: 0.34,
    earSpread: 0.29,
    eyeWidth: 0.1,
    eyeHeight: 0.12,
    eyeSpacing: 0.16,
    cheekOffset: 0.17,
    pattern: 'siamese',
  ),
  CatBreedConfig(
    id: 'orange_tabby',
    label: 'Orange Tabby',
    baseColor: Color(0xFFF1AA62),
    shadeColor: Color(0xFFD07A32),
    creamColor: Color(0xFFFFF0DF),
    earInnerColor: Color(0xFFF3B198),
    eyeColor: Color(0xFF7A5627),
    blushColor: Color(0xFFFFC3B4),
    headScaleX: 0.92,
    headScaleY: 0.85,
    earHeight: 0.31,
    earSpread: 0.3,
    eyeWidth: 0.108,
    eyeHeight: 0.122,
    eyeSpacing: 0.165,
    cheekOffset: 0.18,
    pattern: 'tabby',
  ),
  CatBreedConfig(
    id: 'black_cat',
    label: 'Black Cat',
    baseColor: Color(0xFF2F3036),
    shadeColor: Color(0xFF17181D),
    creamColor: Color(0xFFEFE6E1),
    earInnerColor: Color(0xFF876A73),
    eyeColor: Color(0xFFEACD62),
    blushColor: Color(0xFFD59AA4),
    headScaleX: 0.9,
    headScaleY: 0.83,
    earHeight: 0.33,
    earSpread: 0.285,
    eyeWidth: 0.092,
    eyeHeight: 0.115,
    eyeSpacing: 0.17,
    cheekOffset: 0.175,
    pattern: 'black',
  ),
  CatBreedConfig(
    id: 'british_shorthair',
    label: 'British Shorthair',
    baseColor: Color(0xFFB8BEC8),
    shadeColor: Color(0xFF7A838F),
    creamColor: Color(0xFFFFF7F2),
    earInnerColor: Color(0xFFE0BCC5),
    eyeColor: Color(0xFFE0BF67),
    blushColor: Color(0xFFE4BAC2),
    headScaleX: 0.98,
    headScaleY: 0.9,
    earHeight: 0.27,
    earSpread: 0.3,
    eyeWidth: 0.114,
    eyeHeight: 0.126,
    eyeSpacing: 0.165,
    cheekOffset: 0.185,
    pattern: 'british',
  ),
  CatBreedConfig(
    id: 'calico',
    label: 'Calico',
    baseColor: Color(0xFFF9F1E8),
    shadeColor: Color(0xFFD49A66),
    creamColor: Color(0xFFFFFBF5),
    earInnerColor: Color(0xFFE7B2B5),
    eyeColor: Color(0xFF6E7F44),
    blushColor: Color(0xFFF7C6C7),
    headScaleX: 0.93,
    headScaleY: 0.86,
    earHeight: 0.3,
    earSpread: 0.295,
    eyeWidth: 0.104,
    eyeHeight: 0.12,
    eyeSpacing: 0.164,
    cheekOffset: 0.18,
    pattern: 'calico',
  ),
  CatBreedConfig(
    id: 'persian',
    label: 'Persian',
    baseColor: Color(0xFFF2E8DF),
    shadeColor: Color(0xFFB89E94),
    creamColor: Color(0xFFFFFAF6),
    earInnerColor: Color(0xFFE9B7C1),
    eyeColor: Color(0xFF78A68C),
    blushColor: Color(0xFFF0C5CD),
    headScaleX: 1.0,
    headScaleY: 0.92,
    earHeight: 0.25,
    earSpread: 0.305,
    eyeWidth: 0.116,
    eyeHeight: 0.112,
    eyeSpacing: 0.162,
    cheekOffset: 0.19,
    pattern: 'persian',
  ),
];

CatBreedConfig catBreedConfig(String breed) {
  return catBreedConfigs.firstWhere(
    (item) => item.id == breed,
    orElse: () => catBreedConfigs.first,
  );
}

String catBreedLabel(String breed) => catBreedConfig(breed).label;

class CatHeadAvatar extends StatefulWidget {
  const CatHeadAvatar({
    super.key,
    required this.breed,
    required this.accessory,
    required this.effect,
    required this.mood,
    this.size = 96,
    this.showBackground = true,
  });

  final String breed;
  final String accessory;
  final String effect;
  final AvatarMood mood;
  final double size;
  final bool showBackground;

  @override
  State<CatHeadAvatar> createState() => _CatHeadAvatarState();
}

class _CatHeadAvatarState extends State<CatHeadAvatar> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _blinkController;
  late final AnimationController _effectController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
    _effectController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _effectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _blinkController, _effectController]),
      builder: (context, child) {
        final floatY = math.sin(_floatController.value * math.pi * 2) * widget.size * 0.035;
        final bounce = 0.985 + math.sin(_floatController.value * math.pi * 2) * 0.015;
        final blink = _blinkController.value > 0.88 ? 0.12 : 1.0;
        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.scale(
            scale: bounce,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (widget.showBackground)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFFBF7),
                              Color(0xFFFFEAD8),
                              Color(0xFFDFF8EF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(widget.size * 0.34),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF79C9B0).withOpacity(0.18),
                              blurRadius: widget.size * 0.18,
                              offset: Offset(0, widget.size * 0.08),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.effect == 'glow_outline')
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.size * 0.34),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD684).withOpacity(0.48),
                                blurRadius: widget.size * 0.18,
                                spreadRadius: widget.size * 0.01,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.effect == 'sparkle_aura')
                    ..._sparkles(widget.size, _effectController.value),
                  if (widget.effect == 'floating_hearts')
                    ..._hearts(widget.size, _effectController.value),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CatHeadPainter(
                        breed: widget.breed,
                        accessory: widget.accessory,
                        mood: widget.mood,
                        blinkAmount: blink,
                        phase: _effectController.value,
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

  List<Widget> _sparkles(double size, double phase) {
    final offsets = [
      (-0.34, -0.28, 0.1),
      (0.33, -0.18, 0.45),
      (0.28, 0.14, 0.72),
      (-0.24, 0.22, 0.9),
    ];
    return offsets.map((item) {
      final progress = (phase + item.$3) % 1;
      final opacity = (1 - (progress - 0.5).abs() * 2).clamp(0.2, 1.0);
      return Positioned(
        left: size * (0.5 + item.$1) - size * 0.05,
        top: size * (0.5 + item.$2) - size * 0.05 - (progress * size * 0.05),
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: size * 0.1,
            color: const Color(0xFFFFD76A),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _hearts(double size, double phase) {
    final offsets = [
      (-0.25, -0.16, 0.05),
      (0.18, -0.32, 0.4),
      (0.32, 0.0, 0.7),
    ];
    return offsets.map((item) {
      final progress = (phase + item.$3) % 1;
      return Positioned(
        left: size * (0.5 + item.$1) - size * 0.045,
        top: size * (0.5 + item.$2) - size * 0.04 - math.sin(progress * math.pi) * size * 0.08,
        child: Opacity(
          opacity: (0.35 + math.sin(progress * math.pi) * 0.65).clamp(0.0, 1.0),
          child: Icon(
            Icons.favorite_rounded,
            size: size * 0.09,
            color: const Color(0xFFFF91B0),
          ),
        ),
      );
    }).toList();
  }
}

class CatHeadPainter extends CustomPainter {
  const CatHeadPainter({
    required this.breed,
    required this.accessory,
    required this.mood,
    required this.blinkAmount,
    required this.phase,
  });

  final String breed;
  final String accessory;
  final AvatarMood mood;
  final double blinkAmount;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final config = catBreedConfig(breed);
    final center = Offset(size.width * 0.5, size.height * 0.56);
    final headRect = Rect.fromCenter(
      center: center,
      width: size.width * config.headScaleX * 0.66,
      height: size.height * config.headScaleY * 0.62,
    );
    final furPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(config.baseColor, Colors.white, 0.18)!,
          config.baseColor,
          config.shadeColor,
        ],
      ).createShader(headRect);
    final creamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          config.creamColor,
          Color.lerp(config.creamColor, const Color(0xFFFFE1D7), 0.25)!,
        ],
      ).createShader(headRect);

    final earLeft = Path()
      ..moveTo(size.width * (0.5 - config.earSpread), size.height * 0.36)
      ..quadraticBezierTo(
        size.width * (0.5 - config.earSpread - 0.02),
        size.height * (0.36 - config.earHeight),
        size.width * 0.42,
        size.height * 0.29,
      )
      ..quadraticBezierTo(size.width * 0.44, size.height * 0.42, size.width * 0.47, size.height * 0.45)
      ..close();
    final earRight = Path()
      ..moveTo(size.width * (0.5 + config.earSpread), size.height * 0.36)
      ..quadraticBezierTo(
        size.width * (0.5 + config.earSpread + 0.02),
        size.height * (0.36 - config.earHeight),
        size.width * 0.58,
        size.height * 0.29,
      )
      ..quadraticBezierTo(size.width * 0.56, size.height * 0.42, size.width * 0.53, size.height * 0.45)
      ..close();

    canvas.drawShadow(earLeft, Colors.black.withOpacity(0.12), 4, false);
    canvas.drawShadow(earRight, Colors.black.withOpacity(0.12), 4, false);
    canvas.drawPath(earLeft, furPaint);
    canvas.drawPath(earRight, furPaint);

    final innerEarPaint = Paint()..color = config.earInnerColor.withOpacity(0.82);
    canvas.drawPath(_scalePath(earLeft, 0.58, center: Offset(size.width * 0.44, size.height * 0.35)), innerEarPaint);
    canvas.drawPath(_scalePath(earRight, 0.58, center: Offset(size.width * 0.56, size.height * 0.35)), innerEarPaint);

    canvas.drawShadow(
      Path()..addRRect(RRect.fromRectAndRadius(headRect, Radius.circular(size.width * 0.16))),
      Colors.black.withOpacity(0.15),
      8,
      false,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(size.width * 0.18)),
      furPaint,
    );

    _paintPattern(canvas, size, config);

    final muzzleRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.64),
      width: size.width * 0.26,
      height: size.height * 0.16,
    );
    canvas.drawOval(muzzleRect, creamPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.5 - config.cheekOffset), size.height * 0.64),
        width: size.width * 0.12,
        height: size.height * 0.1,
      ),
      creamPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.5 + config.cheekOffset), size.height * 0.64),
        width: size.width * 0.12,
        height: size.height * 0.1,
      ),
      creamPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.5 - config.cheekOffset), size.height * 0.67),
        width: size.width * 0.07,
        height: size.height * 0.045,
      ),
      Paint()..color = config.blushColor.withOpacity(_showBlush ? 0.72 : 0.0),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.5 + config.cheekOffset), size.height * 0.67),
        width: size.width * 0.07,
        height: size.height * 0.045,
      ),
      Paint()..color = config.blushColor.withOpacity(_showBlush ? 0.72 : 0.0),
    );

    _paintEyes(canvas, size, config);
    _paintMouth(canvas, size);
    _paintWhiskers(canvas, size);
    _paintAccessory(canvas, size, config);
  }

  bool get _showBlush => mood != AvatarMood.sad;

  void _paintEyes(Canvas canvas, Size size, CatBreedConfig config) {
    final baseY = size.height * 0.56;
    final eyeWidth = size.width * config.eyeWidth;
    final eyeHeight = size.height * config.eyeHeight * blinkAmount;
    final linePaint = Paint()
      ..color = const Color(0xFF3F3734)
      ..strokeWidth = size.width * 0.015
      ..strokeCap = StrokeCap.round;

    if (blinkAmount < 0.2) {
      canvas.drawLine(
        Offset(size.width * (0.5 - config.eyeSpacing) - eyeWidth * 0.38, baseY),
        Offset(size.width * (0.5 - config.eyeSpacing) + eyeWidth * 0.38, baseY + size.height * 0.006),
        linePaint,
      );
      canvas.drawLine(
        Offset(size.width * (0.5 + config.eyeSpacing) - eyeWidth * 0.38, baseY + size.height * 0.006),
        Offset(size.width * (0.5 + config.eyeSpacing) + eyeWidth * 0.38, baseY),
        linePaint,
      );
      return;
    }

    void drawEye(Offset center, {double rotation = 0}) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      final scleraRect = Rect.fromCenter(center: Offset.zero, width: eyeWidth, height: eyeHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(scleraRect, Radius.circular(size.width * 0.05)),
        Paint()..color = Colors.white,
      );
      if (mood == AvatarMood.excited) {
        _paintSparkleEye(canvas, scleraRect, config.eyeColor);
      } else if (mood == AvatarMood.happy) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset.zero, width: eyeWidth * 0.8, height: eyeHeight * 1.1),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFF2D2B2A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.015
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: eyeWidth * 0.44, height: eyeHeight * 0.72),
          Paint()..color = config.eyeColor,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: eyeWidth * 0.24, height: eyeHeight * 0.55),
          Paint()..color = const Color(0xFF2A2928),
        );
        canvas.drawCircle(
          Offset(-eyeWidth * 0.1, -eyeHeight * 0.18),
          size.width * 0.012,
          Paint()..color = Colors.white,
        );
      }
      canvas.restore();
    }

    final tilt = switch (mood) {
      AvatarMood.sad => 0.16,
      AvatarMood.proud => -0.08,
      _ => 0.04,
    };
    drawEye(Offset(size.width * (0.5 - config.eyeSpacing), baseY), rotation: -tilt);
    drawEye(Offset(size.width * (0.5 + config.eyeSpacing), baseY), rotation: tilt);
  }

  void _paintSparkleEye(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()..color = color;
    final center = rect.center;
    final radius = rect.width * 0.12;
    for (final angle in [0.0, math.pi / 2, math.pi, math.pi * 1.5]) {
      final point = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius);
      canvas.drawLine(
        point.translate(-radius * 0.35, 0),
        point.translate(radius * 0.35, 0),
        paint..strokeWidth = rect.width * 0.1,
      );
      canvas.drawLine(
        point.translate(0, -radius * 0.35),
        point.translate(0, radius * 0.35),
        paint..strokeWidth = rect.width * 0.1,
      );
    }
    canvas.drawCircle(center, rect.width * 0.1, Paint()..color = Colors.white);
  }

  void _paintMouth(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF403632)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.014
      ..strokeCap = StrokeCap.round;
    final nose = Paint()..color = const Color(0xFFF6A7B6);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.62),
        width: size.width * 0.056,
        height: size.height * 0.036,
      ),
      nose,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.635),
      Offset(size.width * 0.5, size.height * 0.664),
      stroke,
    );

    final mouth = Path();
    switch (mood) {
      case AvatarMood.happy:
        mouth.moveTo(size.width * 0.45, size.height * 0.682);
        mouth.quadraticBezierTo(size.width * 0.5, size.height * 0.715, size.width * 0.55, size.height * 0.682);
        break;
      case AvatarMood.sad:
        mouth.moveTo(size.width * 0.45, size.height * 0.692);
        mouth.quadraticBezierTo(size.width * 0.5, size.height * 0.662, size.width * 0.55, size.height * 0.692);
        break;
      case AvatarMood.excited:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.692),
            width: size.width * 0.08,
            height: size.height * 0.062,
          ),
          Paint()..color = const Color(0xFF332B29),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.708),
            width: size.width * 0.04,
            height: size.height * 0.02,
          ),
          Paint()..color = const Color(0xFFF79AB4),
        );
        return;
      case AvatarMood.proud:
        mouth.moveTo(size.width * 0.45, size.height * 0.685);
        mouth.quadraticBezierTo(size.width * 0.51, size.height * 0.718, size.width * 0.562, size.height * 0.675);
        break;
      case AvatarMood.neutral:
        mouth.moveTo(size.width * 0.465, size.height * 0.684);
        mouth.lineTo(size.width * 0.535, size.height * 0.684);
        break;
    }
    canvas.drawPath(mouth, stroke);
  }

  void _paintWhiskers(Canvas canvas, Size size) {
    final whiskerPaint = Paint()
      ..color = const Color(0xFF5A504A).withOpacity(0.72)
      ..strokeWidth = size.width * 0.01
      ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      for (final row in [0.0, 0.03, 0.06]) {
        canvas.drawLine(
          Offset(size.width * (0.5 + side * 0.08), size.height * (0.642 + row)),
          Offset(size.width * (0.5 + side * 0.24), size.height * (0.622 + row + (side < 0 ? 0.0 : 0.004))),
          whiskerPaint,
        );
      }
    }
  }

  void _paintPattern(Canvas canvas, Size size, CatBreedConfig config) {
    switch (config.pattern) {
      case 'tabby':
        final stripePaint = Paint()
          ..color = config.shadeColor.withOpacity(0.45)
          ..strokeWidth = size.width * 0.022
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(size.width * 0.43, size.height * 0.41), Offset(size.width * 0.39, size.height * 0.49), stripePaint);
        canvas.drawLine(Offset(size.width * 0.5, size.height * 0.39), Offset(size.width * 0.5, size.height * 0.5), stripePaint);
        canvas.drawLine(Offset(size.width * 0.57, size.height * 0.41), Offset(size.width * 0.61, size.height * 0.49), stripePaint);
        break;
      case 'siamese':
        final pointPaint = Paint()..color = config.shadeColor.withOpacity(0.82);
        canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.38, size.height * 0.48), width: size.width * 0.1, height: size.height * 0.09), pointPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.62, size.height * 0.48), width: size.width * 0.1, height: size.height * 0.09), pointPaint);
        break;
      case 'calico':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.38, size.height * 0.48), width: size.width * 0.14, height: size.height * 0.16),
          Paint()..color = const Color(0xFFE38B57).withOpacity(0.92),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.61, size.height * 0.44), width: size.width * 0.12, height: size.height * 0.12),
          Paint()..color = const Color(0xFF33353A).withOpacity(0.84),
        );
        break;
      case 'black':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.52, size.height * 0.44), width: size.width * 0.14, height: size.height * 0.06),
          Paint()..color = Colors.white.withOpacity(0.08),
        );
        break;
      case 'british':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.4, size.height * 0.53), width: size.width * 0.09, height: size.height * 0.08),
          Paint()..color = Colors.white.withOpacity(0.15),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.6, size.height * 0.53), width: size.width * 0.09, height: size.height * 0.08),
          Paint()..color = Colors.white.withOpacity(0.15),
        );
        break;
      case 'persian':
        for (final x in [0.39, 0.5, 0.61]) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(size.width * x, size.height * 0.45), width: size.width * 0.09, height: size.height * 0.08),
            math.pi,
            math.pi,
            false,
            Paint()
              ..color = config.shadeColor.withOpacity(0.28)
              ..style = PaintingStyle.stroke
              ..strokeWidth = size.width * 0.013,
          );
        }
        break;
    }
  }

  void _paintAccessory(Canvas canvas, Size size, CatBreedConfig config) {
    switch (accessory) {
      case 'crown':
        final path = Path()
          ..moveTo(size.width * 0.3, size.height * 0.32)
          ..lineTo(size.width * 0.38, size.height * 0.18)
          ..lineTo(size.width * 0.47, size.height * 0.28)
          ..lineTo(size.width * 0.5, size.height * 0.16)
          ..lineTo(size.width * 0.53, size.height * 0.28)
          ..lineTo(size.width * 0.62, size.height * 0.18)
          ..lineTo(size.width * 0.7, size.height * 0.32)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFF3BD57));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.3, size.height * 0.305, size.width * 0.4, size.height * 0.05),
            Radius.circular(size.width * 0.025),
          ),
          Paint()..color = const Color(0xFFE3A541),
        );
        break;
      case 'ribbon':
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.61, size.height * 0.35)
            ..lineTo(size.width * 0.67, size.height * 0.43)
            ..lineTo(size.width * 0.59, size.height * 0.44)
            ..close(),
          Paint()..color = const Color(0xFFF486A7),
        );
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.61, size.height * 0.35)
            ..lineTo(size.width * 0.55, size.height * 0.43)
            ..lineTo(size.width * 0.63, size.height * 0.44)
            ..close(),
          Paint()..color = const Color(0xFFF8A9BF),
        );
        canvas.drawCircle(Offset(size.width * 0.61, size.height * 0.385), size.width * 0.028, Paint()..color = const Color(0xFFFFD8E5));
        break;
      case 'headphones':
        final bandPath = Path()
          ..moveTo(size.width * 0.18, size.height * 0.35)
          ..arcToPoint(
            Offset(size.width * 0.82, size.height * 0.35),
            radius: Radius.elliptical(size.width * 0.32, size.height * 0.17),
            clockwise: false,
          )
          ..lineTo(size.width * 0.82, size.height * 0.39)
          ..arcToPoint(
            Offset(size.width * 0.18, size.height * 0.39),
            radius: Radius.elliptical(size.width * 0.32, size.height * 0.11),
            clockwise: true,
          )
          ..close();
        canvas.drawPath(bandPath, Paint()..color = const Color(0xFF7065E5).withOpacity(0.96));
        for (final x in [0.23, 0.67]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(size.width * x, size.height * 0.46, size.width * 0.1, size.height * 0.15),
              Radius.circular(size.width * 0.04),
            ),
            Paint()..color = const Color(0xFF9A90FF),
          );
        }
        break;
      case 'glasses':
        final lensPaint = Paint()..color = const Color(0xFF3A505B).withOpacity(0.16);
        for (final x in [0.39, 0.61]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(size.width * x, size.height * 0.56), width: size.width * 0.13, height: size.height * 0.1),
              Radius.circular(size.width * 0.04),
            ),
            lensPaint,
          );
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.56), width: size.width * 0.1, height: size.height * 0.02),
            Radius.circular(size.width * 0.01),
          ),
          Paint()..color = const Color(0xFF3A505B).withOpacity(0.22),
        );
        break;
      case 'flower':
        for (final offset in [
          const Offset(0.0, -0.04),
          const Offset(-0.035, 0.0),
          const Offset(0.035, 0.0),
          const Offset(-0.02, 0.04),
          const Offset(0.02, 0.04),
        ]) {
          canvas.drawCircle(
            Offset(size.width * (0.34 + offset.dx), size.height * (0.38 + offset.dy)),
            size.width * 0.028,
            Paint()..color = const Color(0xFFFFD4E6),
          );
        }
        canvas.drawCircle(Offset(size.width * 0.34, size.height * 0.38), size.width * 0.018, Paint()..color = const Color(0xFFFFC65E));
        break;
      case 'wizard_hat':
        canvas.drawPath(
          Path()
            ..moveTo(size.width * 0.38, size.height * 0.38)
            ..lineTo(size.width * 0.52, size.height * 0.15)
            ..lineTo(size.width * 0.66, size.height * 0.38)
            ..close(),
          Paint()..color = const Color(0xFF6053D7),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.52, size.height * 0.385), width: size.width * 0.34, height: size.height * 0.06),
          Paint()..color = const Color(0xFF8478F5),
        );
        break;
      case 'sleeping_cap':
        final capPath = Path()
          ..moveTo(size.width * 0.24, size.height * 0.34)
          ..arcToPoint(
            Offset(size.width * 0.70, size.height * 0.34),
            radius: Radius.elliptical(size.width * 0.23, size.height * 0.14),
            clockwise: false,
          )
          ..lineTo(size.width * 0.70, size.height * 0.39)
          ..arcToPoint(
            Offset(size.width * 0.24, size.height * 0.39),
            radius: Radius.elliptical(size.width * 0.23, size.height * 0.08),
            clockwise: true,
          )
          ..close();
        canvas.drawPath(capPath, Paint()..color = const Color(0xFF7AA9E8).withOpacity(0.96));
        canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.3), size.width * 0.03, Paint()..color = Colors.white);
        break;
      case 'halo':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.25), width: size.width * 0.28, height: size.height * 0.07),
          Paint()..color = const Color(0xFFFFD777).withOpacity(0.55),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.25), width: size.width * 0.2, height: size.height * 0.045),
          Paint()..color = Colors.white.withOpacity(0.24),
        );
        break;
      case 'coin_clip':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.33, size.height * 0.34, size.width * 0.16, size.height * 0.05),
            Radius.circular(size.width * 0.02),
          ),
          Paint()..color = const Color(0xFF3AA38D),
        );
        canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.365), size.width * 0.028, Paint()..color = const Color(0xFFF2C14C));
        canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.365), size.width * 0.014, Paint()..color = const Color(0xFFFFEEB7));
        break;
    }
  }

  Path _scalePath(Path path, double scale, {required Offset center}) {
    final matrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(scale, scale)
      ..translate(-center.dx, -center.dy);
    return path.transform(matrix.storage);
  }

  @override
  bool shouldRepaint(covariant CatHeadPainter oldDelegate) {
    return oldDelegate.breed != breed ||
        oldDelegate.accessory != accessory ||
        oldDelegate.mood != mood ||
        oldDelegate.blinkAmount != blinkAmount ||
        oldDelegate.phase != phase;
  }
}
