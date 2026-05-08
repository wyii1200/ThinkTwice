import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thinktwice_flutter/src/core/app_theme.dart';
import 'package:thinktwice_flutter/src/screens/auth_screens.dart';

void main() {
  testWidgets('shows the splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const SplashPage(),
      ),
    );

    expect(find.text('ThinkTwice'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
