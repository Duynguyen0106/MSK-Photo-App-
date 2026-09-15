import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  final pdfService = PdfService();

  CheckIn sampleCheckIn({String id = 'ci-1', int painScore = 6}) {
    return CheckIn(
      id: id,
      date: DateTime(2026, 9, 15),
      selectedParts: [BodyPart.lowerBack, BodyPart.neck],
      painScore: painScore,
      durationKey: '1_2_weeks',
      aggravators: ['sitting'],
      redFlags: [],
      observations: const [
        Observation(
          region: 'back',
          text: 'Pelvic tilt: 4°. Observed from the front photo.',
          value: 4,
          confidence: 0.9,
        ),
      ],
      questions: ['Sample question?'],
      hasPhoto: true,
      photoPaths: const [],
      poseResults: [
        PoseResult(
          imagePath: '/tmp/front.jpg',
          landmarks: const [],
          measurements: const {
            'pelvicTiltDeg': 4.1,
            'shoulderHeightDiffCm': 1.5,
            'kneeAlignmentLeftDeg': 176.0,
          },
          confidence: const {'leftHip': 0.9, 'rightHip': 0.88},
          landmarkPixels: const {},
          success: true,
        ),
      ],
      notes: 'Patient reports stiffness in mornings.',
      patientId: 'pat-1',
    );
  }

  bool isPdf(Uint8List bytes) =>
      bytes.length > 4 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46;

  group('PdfService', () {
    test('buildPatientPdf returns valid PDF bytes', () async {
      final bytes = await pdfService.buildPatientPdf(sampleCheckIn());
      expect(bytes, isNotEmpty);
      expect(isPdf(bytes), isTrue);
    });

    test('buildClinicianPdf returns valid PDF bytes', () async {
      final bytes = await pdfService.buildClinicianPdf(
        sampleCheckIn(),
        patientName: 'Jane Doe',
      );
      expect(bytes, isNotEmpty);
      expect(isPdf(bytes), isTrue);
    });

    test('buildClinicianPdf includes session comparison when previous provided',
        () async {
      final bytes = await pdfService.buildClinicianPdf(
        sampleCheckIn(painScore: 7),
        patientName: 'Jane Doe',
        previousCheckIn: sampleCheckIn(id: 'ci-0', painScore: 5),
      );
      expect(isPdf(bytes), isTrue);
    });
  });
}
