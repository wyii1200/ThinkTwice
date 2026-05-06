import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF121623);
  static const surface = Color(0xFF1A2131);
  static const surfaceStrong = Color(0xFF20283A);
  static const text = Color(0xFFF5F7FF);
  static const muted = Color(0xFF98A3BF);
  static const border = Color(0x14FFFFFF);
  static const emerald = Color(0xFF5EE7A6);
  static const risk = Color(0xFFFF8A4C);
  static const ai = Color(0xFF8D72FF);
  static const gold = Color(0xFFF6D266);
  static const whiteSoft = Color(0x29FFFFFF);

  static const aiGradient = [Color(0xFF7758FF), Color(0xFF5D8BFF)];
  static const emeraldGradient = [Color(0xFF5EE7A6), Color(0xFF39D2C7)];
  static const riskGradient = [Color(0xFFFF9E56), Color(0xFFFF6D57)];
  static const goldGradient = [Color(0xFFF8DC72), Color(0xFFF5B84D)];
}

class AppTheme {
  static ThemeData get darkTheme {
    const scheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.emerald,
      secondary: AppColors.ai,
      tertiary: AppColors.gold,
      error: AppColors.risk,
      surface: AppColors.surface,
      onPrimary: AppColors.background,
      onSecondary: AppColors.text,
      onTertiary: AppColors.background,
      onSurface: AppColors.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.emerald,
        inactiveTrackColor: AppColors.surfaceStrong,
        thumbColor: AppColors.text,
        overlayColor: AppColors.emerald.withValues(alpha: 0.16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceStrong.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.emerald),
        ),
      ),
    );
  }
}
