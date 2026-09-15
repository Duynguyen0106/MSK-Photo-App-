import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  group('RedFlagService', () {
    final service = RedFlagService();

    test('no flags returns no urgent message', () {
      final result = service.evaluate({});
      expect(result.hasRedFlags, false);
      expect(result.urgentCareMessage, '');
    });

    test('reported flags trigger urgent care message', () {
      final result = service.evaluate({RedFlagSymptom.suddenSeverePain});
      expect(result.hasRedFlags, true);
      expect(result.urgentCareMessage, isNotEmpty);
      expect(result.reportedSymptoms, contains(RedFlagSymptom.suddenSeverePain));
    });
  });

  group('ObservationFormatter', () {
    final report = SymptomReport(
      reportedAt: DateTime(2026, 1, 1),
      painLevel: 5,
      affectedSide: 'left',
      durationDays: 3,
      notes: '',
      usedPhotoCapture: false,
    );

    test('plain language uses observation framing', () {
      final summary = ObservationFormatter.plainLanguageSummary(
        report: report,
        angles: [
          const AngleMeasurement(
            label: 'left_hip_flexion',
            degrees: 85,
            confidence: 0.9,
            landmarksUsed: ['left_hip_flexion'],
          ),
        ],
        confidence: 0.9,
      );
      expect(summary, contains('You reported'));
      expect(summary, contains('We recorded'));
      expect(summary.toLowerCase(), isNot(contains('diagnosis')));
      expect(summary.toLowerCase(), isNot(contains('you have')));
    });

    test('clinical summary records measurements', () {
      final summary = ObservationFormatter.clinicalSummary(
        report: report,
        angles: [
          const AngleMeasurement(
            label: 'left_hip_flexion',
            degrees: 90,
            confidence: 0.85,
            landmarksUsed: ['left_hip_flexion'],
          ),
        ],
        deltas: [],
        confidence: 0.85,
      );
      expect(summary, contains('Recorded'));
      expect(summary, contains('90.0°'));
    });
  });

  group('DisclaimerService', () {
    test('disclaimers state non-diagnostic purpose', () {
      expect(DisclaimerService.fullDisclaimer, contains('does not diagnose'));
      expect(DisclaimerService.clinicianDisclaimer, contains('documentation tool'));
    });
  });
}
