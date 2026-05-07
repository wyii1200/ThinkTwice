import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../presentation/providers/app_providers.dart';
import '../presentation/screens/analytics_screen.dart';
import '../presentation/screens/coach_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/gamification_screen.dart';
import '../presentation/screens/nudge_center_screen.dart';
import '../presentation/screens/onboarding_flow.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/radar_screen.dart';
import '../presentation/screens/transactions_screen.dart';
import '../presentation/widgets/app_shell.dart';

class ThinkTwiceApp extends StatelessWidget {
  const ThinkTwiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThinkTwice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);

    if (!state.onboardingComplete) {
      return OnboardingFlow(
        state: state,
        onContinue: controller.advanceOnboarding,
        onBack: controller.rewindOnboarding,
        onOpenSignIn: () => controller.setOnboardingStep(3),
        onOpenCreateAccount: () => controller.setOnboardingStep(2),
        accountFullName: state.accountFullName,
        accountEmail: state.accountEmail,
        accountPassword: state.accountPassword,
        onSetAccountFullName: controller.setAccountFullName,
        onSetAccountEmail: controller.setAccountEmail,
        onSetAccountPassword: controller.setAccountPassword,
        onSetIncome: controller.setIncome,
        onSetHabit: controller.setHabit,
        onToggleGoal: controller.toggleGoal,
        onToggleConcern: controller.toggleConcern,
        onSetDailyBudget: controller.setDailyBudget,
        onSetAutoSaveRate: controller.setAutoSaveRate,
        onToggleAlerts: controller.toggleAlerts,
        onSetBreed: controller.setBreed,
        onSetHat: controller.setHat,
        onToggleGlasses: controller.toggleGlasses,
        onSetCatName: controller.setCatName,
      );
    }

    return AppShell(
      currentIndex: state.currentTab,
      onTabSelected: controller.setTab,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(state.currentTab),
          child: _screenForIndex(state.currentTab),
        ),
      ),
    );
  }

  Widget _screenForIndex(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const TransactionsScreen();
      case 2:
        return const RadarScreen();
      case 3:
        return const GamificationScreen();
      case 4:
        return const ProfileScreen();
      case 5:
        return const CoachScreen();
      case 6:
        return const AnalyticsScreen();
      case 7:
        return const NudgeCenterScreen();
      default:
        return const DashboardScreen();
    }
  }
}
