import 'package:flutter/material.dart';
ThemeData buildTheme() {
  const background = Color(0xFFF5FBF7);
  const foreground = Color(0xFF193C34);
  const card = Colors.white;
  const muted = Color(0xFFE9F2ED);
  const mutedForeground = Color(0xFF6B847E);
  const primary = Color(0xFF41B89B);
  const primaryGlow = Color(0xFF86D8BF);
  const accent = Color(0xFFEACB6A);
  const accentForeground = Color(0xFF66511D);
  const success = Color(0xFF54C18C);
  const warning = Color(0xFFE2B14C);
  const destructive = Color(0xFFE1604F);

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
    ),
    dividerColor: const Color(0xFFE3ECE6),
    cardColor: card,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
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

  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryGlow],
      );

  LinearGradient get warmGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEACB6A), Color(0xFFE49A57)],
      );

  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primary.withOpacity(0.15),
          blurRadius: 20,
          spreadRadius: -4,
          offset: const Offset(0, 4),
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
    );
  }
}

extension ThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}






