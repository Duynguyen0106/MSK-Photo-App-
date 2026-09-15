import 'package:flutter_test/flutter_test.dart';
import 'package:patient/main.dart';

void main() {
  testWidgets('Welcome screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PatientApp());
    expect(find.text('MSK Check-In'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
