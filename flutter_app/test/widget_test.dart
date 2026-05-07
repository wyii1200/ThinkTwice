import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_twice_flutter/src/app/app.dart';

void main() {
  testWidgets('renders splash onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ThinkTwiceApp(),
      ),
    );

    expect(find.text('Financial resilience by design.'), findsOneWidget);
  });
}
