import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/app_models.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
    super.key,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _GradientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 88),
                            child: child,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: BottomNavBar(
                          currentIndex: currentIndex,
                          onSelected: onTabSelected,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppFrame extends StatelessWidget {
  const AppFrame({
    required this.child,
    this.showNav = false,
    this.currentIndex = 0,
    this.onTabSelected,
    this.showStatusBar = true,
    super.key,
  });

  final Widget child;
  final bool showNav;
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;
  final bool showStatusBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _GradientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Column(
                            children: [
                              if (showStatusBar) const _StatusBar(),
                              Expanded(child: child),
                            ],
                          ),
                        ),
                      ),
                      if (showNav && onTabSelected != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: BottomNavBar(
                            currentIndex: currentIndex,
                            onSelected: onTabSelected!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (label: 'Home', icon: Icons.home_rounded),
      (label: 'Activity', icon: Icons.show_chart_rounded),
      (label: 'Radar', icon: Icons.place_rounded),
      (label: 'Quests', icon: Icons.emoji_events_rounded),
      (label: 'Profile', icon: Icons.person_rounded),
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      strong: true,
      radius: 28,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelected(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: i == currentIndex
                              ? const LinearGradient(colors: AppColors.aiGradient)
                              : null,
                        ),
                        child: Icon(
                          items[i].icon,
                          size: 18,
                          color: i == currentIndex
                              ? Colors.white
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: i == currentIndex
                              ? AppColors.text
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.strong = false,
    this.radius = 24,
    this.gradient,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool strong;
  final double radius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (strong
                ? AppColors.surfaceStrong.withValues(alpha: 0.88)
                : AppColors.surface.withValues(alpha: 0.78))
            : null,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          if (gradient != null)
            BoxShadow(
              color: (gradient as LinearGradient)
                  .colors
                  .first
                  .withValues(alpha: 0.28),
              blurRadius: 30,
              spreadRadius: -10,
            ),
          const BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, 12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: child,
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.gradient,
    required this.onTap,
    this.icon,
    this.textColor = AppColors.background,
    super.key,
  });

  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  final IconData? icon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: textColor),
            ],
          ],
        ),
      ),
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class PixelCatWidget extends StatelessWidget {
  const PixelCatWidget({
    required this.breed,
    this.size = 96,
    this.hat = CatHat.none,
    this.glasses = false,
    super.key,
  });

  final CatBreed breed;
  final double size;
  final CatHat hat;
  final bool glasses;

  @override
  Widget build(BuildContext context) {
    const sprite = [
      '0000000000000000',
      '0003000000003000',
      '0033300000033300',
      '0333330000333330',
      '0331330000331330',
      '0011111111111100',
      '0114411111144110',
      '0111551111551110',
      '0111111771111110',
      '0111166666611110',
      '0112222222221110',
      '0122222222222210',
      '0122222222222210',
      '0112222222221100',
      '0011222222211100',
      '0001100000110000',
    ];

    final palette = _paletteForBreed(breed);
    final cell = size / 16;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: sprite.map((row) {
              return Row(
                children: row.split('').map((value) {
                  return Container(
                    width: cell,
                    height: cell,
                    color: _colorForCode(value, palette),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          if (hat == CatHat.cap)
            Positioned(
              left: cell * 3,
              top: 0,
              child: Container(
                width: cell * 10,
                height: cell * 2,
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          if (hat == CatHat.crown)
            Positioned(
              left: cell * 4,
              top: -cell * 1.5,
              child: CustomPaint(
                size: Size(cell * 8, cell * 2.5),
                painter: _CrownPainter(),
              ),
            ),
          if (glasses)
            Positioned(
              left: cell * 4,
              top: cell * 7,
              child: Row(
                children: [
                  _GlassLens(size: Size(cell * 3, cell * 2)),
                  SizedBox(width: cell),
                  _GlassLens(size: Size(cell * 3, cell * 2)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, Color> _paletteForBreed(CatBreed breed) {
    switch (breed) {
      case CatBreed.orangeTabby:
        return {
          'body': const Color(0xFFF59E42),
          'belly': const Color(0xFFFDE7C8),
          'ears': const Color(0xFFD97706),
          'stripe': const Color(0xFFB45309),
        };
      case CatBreed.britishShorthair:
        return {
          'body': const Color(0xFF9AA6B2),
          'belly': const Color(0xFFD6DDE6),
          'ears': const Color(0xFF6B7480),
          'stripe': const Color(0xFF6B7480),
        };
      case CatBreed.siamese:
        return {
          'body': const Color(0xFFF3E7D3),
          'belly': const Color(0xFFFFF7E6),
          'ears': const Color(0xFF5B3A29),
          'stripe': const Color(0xFF5B3A29),
        };
      case CatBreed.persian:
        return {
          'body': const Color(0xFFFAFAFA),
          'belly': const Color(0xFFFFFFFF),
          'ears': const Color(0xFFE5E7EB),
          'stripe': const Color(0xFFE5E7EB),
        };
      case CatBreed.calico:
        return {
          'body': const Color(0xFFFFF7E6),
          'belly': const Color(0xFFFDE7C8),
          'ears': const Color(0xFF1F2937),
          'stripe': const Color(0xFFF59E42),
        };
      case CatBreed.tuxedo:
        return {
          'body': const Color(0xFF0F172A),
          'belly': const Color(0xFFFFFFFF),
          'ears': const Color(0xFF0F172A),
          'stripe': const Color(0xFF0F172A),
        };
      case CatBreed.ragdoll:
        return {
          'body': const Color(0xFFEDE0D4),
          'belly': const Color(0xFFFFFFFF),
          'ears': const Color(0xFF7C5E4A),
          'stripe': const Color(0xFF7C5E4A),
        };
    }
  }

  Color _colorForCode(String code, Map<String, Color> palette) {
    switch (code) {
      case '1':
        return palette['body']!;
      case '2':
        return palette['belly']!;
      case '3':
        return palette['ears']!;
      case '4':
        return palette['stripe']!;
      case '5':
        return const Color(0xFF0F172A);
      case '6':
        return const Color(0xFFF9A8D4);
      case '7':
        return const Color(0xFF7C2D12);
      default:
        return Colors.transparent;
    }
  }
}

class AppChipToggle extends StatelessWidget {
  const AppChipToggle({
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: AppColors.aiGradient)
              : null,
          color: active ? null : AppColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.text.withValues(alpha: 0.86),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      child: Row(
        children: const [
          Text('9:41', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.ai),
              SizedBox(width: 4),
              Text(
                'ThinkTwice',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Spacer(),
          Text('100%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [Color(0xFF232944), AppColors.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -120,
            top: -120,
            child: _Blob(
              size: 260,
              colors: AppColors.aiGradient,
              opacity: 0.18,
            ),
          ),
          Positioned(
            right: -120,
            bottom: -120,
            child: _Blob(
              size: 260,
              colors: AppColors.emeraldGradient,
              opacity: 0.14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatefulWidget {
  const _Blob({
    required this.size,
    required this.colors,
    required this.opacity,
  });

  final double size;
  final List<Color> colors;
  final double opacity;

  @override
  State<_Blob> createState() => _BlobState();
}

class _BlobState extends State<_Blob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

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
        final value = Curves.easeInOut.transform(_controller.value);
        return Transform.rotate(
          angle: value * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.colors
                    .map((color) => color.withValues(alpha: widget.opacity))
                    .toList(),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.colors.first.withValues(alpha: widget.opacity),
                  blurRadius: 90,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlassLens extends StatelessWidget {
  const _GlassLens({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: AppColors.goldGradient,
      ).createShader(Offset.zero & size);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.15, size.height * 0.3)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.85, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
