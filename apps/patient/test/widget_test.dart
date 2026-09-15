import 'package:flutter_test/flutter_test.dart';
import 'package:patient/main.dart';

void main() {
  testWidgets('Patient app renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PatientApp());
    expect(find.text('MSK Check-In'), findsOneWidget);
    expect(find.text('Start a check-in'), findsOneWidget);
  });
}
