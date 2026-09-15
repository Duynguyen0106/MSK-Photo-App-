import 'package:flutter_test/flutter_test.dart';
import 'package:clinician/main.dart';

void main() {
  testWidgets('Clinician app renders roster', (WidgetTester tester) async {
    await tester.pumpWidget(const ClinicianApp());
    expect(find.text('Patient Roster'), findsOneWidget);
  });
}
