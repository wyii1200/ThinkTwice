import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_repository.dart';
import '../../domain/models/app_models.dart';

final mockRepositoryProvider = Provider<MockRepository>((ref) {
  return MockRepository();
});

final appStateProvider =
    NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

class AppState {
  const AppState({
    required this.onboardingStep,
    required this.onboardingComplete,
    required this.currentTab,
    required this.profile,
    required this.accountFullName,
    required this.accountEmail,
    required this.accountPassword,
    required this.nudges,
  });

  final int onboardingStep;
  final bool onboardingComplete;
  final int currentTab;
  final UserProfileModel profile;
  final String accountFullName;
  final String accountEmail;
  final String accountPassword;
  final List<NudgeModel> nudges;

  AppState copyWith({
    int? onboardingStep,
    bool? onboardingComplete,
    int? currentTab,
    UserProfileModel? profile,
    String? accountFullName,
    String? accountEmail,
    String? accountPassword,
    List<NudgeModel>? nudges,
  }) {
    return AppState(
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currentTab: currentTab ?? this.currentTab,
      profile: profile ?? this.profile,
      accountFullName: accountFullName ?? this.accountFullName,
      accountEmail: accountEmail ?? this.accountEmail,
      accountPassword: accountPassword ?? this.accountPassword,
      nudges: nudges ?? this.nudges,
    );
  }
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    final repo = ref.read(mockRepositoryProvider);
    return AppState(
      onboardingStep: 0,
      onboardingComplete: false,
      currentTab: 0,
      profile: repo.loadProfile(),
      accountFullName: '',
      accountEmail: '',
      accountPassword: '',
      nudges: repo.loadNudges(),
    );
  }

  void advanceOnboarding() {
    final next = state.onboardingStep + 1;
    if (next > 6) {
      completeOnboarding();
      return;
    }
    state = state.copyWith(onboardingStep: next);
  }

  void setOnboardingStep(int step) {
    state = state.copyWith(onboardingStep: step);
  }

  void rewindOnboarding() {
    if (state.onboardingStep == 0) return;
    state = state.copyWith(onboardingStep: state.onboardingStep - 1);
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true, currentTab: 0);
  }

  void setTab(int index) {
    state = state.copyWith(currentTab: index);
  }

  void setAccountFullName(String value) {
    state = state.copyWith(accountFullName: value);
  }

  void setAccountEmail(String value) {
    state = state.copyWith(accountEmail: value);
  }

  void setAccountPassword(String value) {
    state = state.copyWith(accountPassword: value);
  }

  void dismissNudge(int index) {
    final nudges = [...state.nudges];
    if (index < 0 || index >= nudges.length) return;
    nudges[index] = nudges[index].copyWith(dismissed: true);
    state = state.copyWith(nudges: nudges);
  }

  void completePrimaryNudgeAction(int index) {
    dismissNudge(index);
  }

  void setIncome(String value) {
    state = state.copyWith(profile: state.profile.copyWith(income: value));
  }

  void setHabit(String value) {
    state = state.copyWith(profile: state.profile.copyWith(habit: value));
  }

  void toggleGoal(String value) {
    final current = [...state.profile.goals];
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(profile: state.profile.copyWith(goals: current));
  }

  void toggleConcern(String value) {
    final current = [...state.profile.concerns];
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(profile: state.profile.copyWith(concerns: current));
  }

  void setDailyBudget(double value) {
    state = state.copyWith(profile: state.profile.copyWith(dailyBudget: value));
  }

  void setAutoSaveRate(double value) {
    state = state.copyWith(profile: state.profile.copyWith(autoSaveRate: value));
  }

  void toggleAlerts(bool value) {
    state = state.copyWith(
      profile: state.profile.copyWith(spendingAlerts: value),
    );
  }

  void setBreed(CatBreed value) {
    state = state.copyWith(profile: state.profile.copyWith(catBreed: value));
  }

  void setHat(CatHat value) {
    state = state.copyWith(profile: state.profile.copyWith(catHat: value));
  }

  void toggleGlasses() {
    state = state.copyWith(
      profile: state.profile.copyWith(catGlasses: !state.profile.catGlasses),
    );
  }

  void setCatName(String value) {
    state = state.copyWith(profile: state.profile.copyWith(catName: value));
  }
}
