import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';
import 'package:patient/screens/home_screen.dart';
import 'package:patient/theme.dart';

void main() {
  testWidgets('Home screen shows greeting, hero, and empty state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: PatientTheme.light(),
        home: HomeScreen(initialCheckIns: <CheckIn>[]),
      ),
    );

    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.text('Start check-in →'), findsOneWidget);
    expect(find.text('Recent check-ins'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('No check-ins yet'),
      200,
    );
    expect(find.textContaining('No check-ins yet'), findsOneWidget);
  });
}
