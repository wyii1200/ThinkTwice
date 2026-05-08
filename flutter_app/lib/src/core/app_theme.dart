import 'package:flutter/material.dart';
ThemeData buildTheme() {
  const background = Color(0xFFFFFBF3);
  const foreground = Color(0xFF21423A);
  const card = Colors.white;
  const muted = Color(0xFFF4EFE3);
  const mutedForeground = Color(0xFF7D8378);
  const primary = Color(0xFF48B39B);
  const primaryGlow = Color(0xFFA7E6D3);
  const accent = Color(0xFFF6D27A);
  const accentForeground = Color(0xFF6D4E1F);
  const success = Color(0xFF5DBB83);
  const warning = Color(0xFFE9A552);
  const destructive = Color(0xFFE16E63);

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
    primary: primary,
    secondary: accent,
    surface: card,
    error: destructive,
  ).copyWith(
    surface: card,
    onSurface: foreground,
    primary: primary,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: accentForeground,
    error: destructive,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: scheme,
    textTheme: Typography.blackCupertino.apply(
      bodyColor: foreground,
      displayColor: foreground,
    ).copyWith(
      headlineLarge: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.9),
      headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.7),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
      bodyMedium: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
    ),
    dividerColor: const Color(0xFFE3ECE6),
    cardColor: card,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: foreground,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        background: background,
        foreground: foreground,
        card: card,
        muted: muted,
        mutedForeground: mutedForeground,
        primary: primary,
        primaryGlow: primaryGlow,
        accent: accent,
        accentForeground: accentForeground,
        success: success,
        warning: warning,
        destructive: destructive,
        guardianGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E6), Color(0xFFFFE6D7), Color(0xFFDDF7EE)],
        ),
      ),
    ],
  );
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.muted,
    required this.mutedForeground,
    required this.primary,
    required this.primaryGlow,
    required this.accent,
    required this.accentForeground,
    required this.success,
    required this.warning,
    required this.destructive,
    required this.guardianGradient,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color muted;
  final Color mutedForeground;
  final Color primary;
  final Color primaryGlow;
  final Color accent;
  final Color accentForeground;
  final Color success;
  final Color warning;
  final Color destructive;
  final LinearGradient guardianGradient;

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF3AA98F), primaryGlow, const Color(0xFFF8EBD2)],
      );

  LinearGradient get softMintGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFCF4), Color(0xFFE9F8F0)],
      );

  LinearGradient get warmGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF7D98A), Color(0xFFF1A879)],
      );

  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primary.withOpacity(0.12),
          blurRadius: 24,
          spreadRadius: -8,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.7),
          blurRadius: 16,
          spreadRadius: -10,
          offset: const Offset(0, -4),
        ),
      ];

  @override
  AppColors copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? muted,
    Color? mutedForeground,
    Color? primary,
    Color? primaryGlow,
    Color? accent,
    Color? accentForeground,
    Color? success,
    Color? warning,
    Color? destructive,
    LinearGradient? guardianGradient,
  }) {
    return AppColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      primary: primary ?? this.primary,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      destructive: destructive ?? this.destructive,
      guardianGradient: guardianGradient ?? this.guardianGradient,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(accentForeground, other.accentForeground, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      guardianGradient: LinearGradient.lerp(guardianGradient, other.guardianGradient, t)!,
    );
  }
}

extension ThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}






