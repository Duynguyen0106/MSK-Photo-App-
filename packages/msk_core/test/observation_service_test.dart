import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  const forbidden = [
    'diagnosis',
    'misalignment',
    'problem',
    'injury',
    'tear',
    'fracture',
    'issue',
    'condition',
    'you have',
    'indicates',
    'suggests',
  ];

  final service = ObservationService();

  PoseResult frontResult({
    Map<String, double?> measurements = const {},
    Map<BodyPart, Offset> pixels = const {},
  }) {
    return PoseResult(
      imagePath: '/front.jpg',
      landmarks: const [],
      measurements: measurements,
      confidence: const {'leftShoulder': 0.9, 'rightShoulder': 0.9, 'nose': 0.85},
      landmarkPixels: pixels,
      success: true,
    );
  }

  final sideResult = PoseResult(
    imagePath: '/side.jpg',
    landmarks: const [],
    measurements: const {
      'forwardHeadAngleDeg': 48.0,
      'thoracicKyphosisProxyDeg': 12.5,
    },
    confidence: const {'leftEar': 0.88, 'leftShoulder': 0.9},
    landmarkPixels: const {},
    success: true,
  );

  final results = {
    'front': frontResult(
      measurements: const {
        'shoulderHeightDiffCm': 2.3,
        'pelvicTiltDeg': 4.1,
        'kneeAlignmentLeftDeg': 175.0,
        'kneeAlignmentRightDeg': 178.0,
        'headLateralOffsetCm': 1.2,
      },
      pixels: {
        BodyPart.leftShoulder: const Offset(100, 220),
        BodyPart.rightShoulder: const Offset(200, 200),
      },
    ),
    'side': sideResult,
  };

  group('ObservationService', () {
    test('builds one observation per selected part', () {
      final observations = service.build(
        parts: BodyPart.values,
        results: results,
        painScore: 6,
        durationKey: '1_2_weeks',
      );
      expect(observations.length, BodyPart.values.length);
    });

    test('uses measurement templates when values are present', () {
      final observations = service.build(
        parts: [BodyPart.lowerBack, BodyPart.neck, BodyPart.leftShoulder],
        results: results,
        painScore: 5,
        durationKey: '3_7_days',
      );

      expect(
        observations[0].text,
        'Pelvic tilt: 4.1°. Observed from the front photo.',
      );
      expect(
        observations[1].text,
        'Forward head angle: 48°. Observed from the side photo.',
      );
      expect(
        observations[2].text,
        contains('Shoulder height difference: 2.3 cm'),
      );
      expect(observations[2].text, contains('left lower'));
    });

    test('uses unclear text when measurement is null', () {
      final observations = service.build(
        parts: [BodyPart.leftElbow],
        results: results,
        painScore: 3,
        durationKey: 'less_than_week',
      );

      expect(
        observations.single.text,
        'Region recorded. Camera could not measure this angle clearly.',
      );
      expect(observations.single.value, isNull);
    });

    test('no forbidden words appear in any generated text', () {
      final observations = service.build(
        parts: BodyPart.values,
        results: results,
        painScore: 7,
        durationKey: 'more_than_month',
      );

      for (final obs in observations) {
        final lower = obs.text.toLowerCase();
        for (final word in forbidden) {
          expect(
            lower.contains(word),
            isFalse,
            reason: 'Found "$word" in: ${obs.text}',
          );
        }
      }
    });

    test('forbidden words absent when all measurements are null', () {
      final emptyResults = {
        'front': PoseResult(
          imagePath: '/front.jpg',
          landmarks: const [],
          measurements: const {},
          confidence: const {},
          landmarkPixels: const {},
          success: true,
        ),
        'side': PoseResult(
          imagePath: '/side.jpg',
          landmarks: const [],
          measurements: const {},
          confidence: const {},
          landmarkPixels: const {},
          success: true,
        ),
      };

      final observations = service.build(
        parts: BodyPart.values,
        results: emptyResults,
        painScore: 4,
        durationKey: '1_2_weeks',
      );

      for (final obs in observations) {
        final lower = obs.text.toLowerCase();
        for (final word in forbidden) {
          expect(lower.contains(word), isFalse, reason: obs.text);
        }
      }
    });
  });
}
