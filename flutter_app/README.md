# ThinkTwice Flutter Conversion

This `flutter_app` folder contains the Flutter/Dart conversion of the current `frontend` app.

Source mapping:

- `frontend/src/routes/splash.tsx` -> splash flow in `lib/main.dart`
- `frontend/src/routes/login.tsx` -> login screen in `lib/main.dart`
- `frontend/src/routes/onboarding.tsx` -> onboarding flow in `lib/main.dart`
- `frontend/src/routes/index.tsx` -> home screen in `lib/main.dart`
- `frontend/src/routes/radar.tsx` -> smart radar screen in `lib/main.dart`
- `frontend/src/routes/challenges.tsx` -> quests screen in `lib/main.dart`
- `frontend/src/routes/insights.tsx` -> insights screen in `lib/main.dart`
- `frontend/src/routes/profile.tsx` -> profile screen in `lib/main.dart`
- `frontend/src/components/MobileShell.tsx` -> bottom navigation shell in `lib/main.dart`
- `frontend/src/assets/cat-avatar.png` -> `assets/images/cat-avatar.png`

Notes:

- The current Flutter port is implemented as a single-file UI app in `lib/main.dart`.
- `pubspec.yaml` already includes the avatar asset used by the converted screens.
- I did not revert unrelated workspace changes outside this conversion.
