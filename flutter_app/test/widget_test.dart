import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thinktwice_flutter/main.dart';

void main() {
  testWidgets('shows the splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    expect(find.text('ThinkTwice'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
