import 'package:flutter_test/flutter_test.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  group('BodyPart', () {
    test('labelFor returns human-readable strings', () {
      expect(labelFor(BodyPart.leftKnee), 'Left knee');
      expect(labelFor(BodyPart.upperBack), 'Upper back');
    });

    test('regionFor maps to coarse region keys', () {
      expect(regionFor(BodyPart.leftShoulder), 'shoulder');
      expect(regionFor(BodyPart.rightShoulder), 'shoulder');
      expect(regionFor(BodyPart.upperBack), 'back');
      expect(regionFor(BodyPart.lowerBack), 'back');
      expect(regionFor(BodyPart.leftAnkle), 'ankle');
    });
  });

  group('PoseResult', () {
    test('toMap/fromMap round trip', () {
      final original = PoseResult(
        imagePath: '/tmp/photo.jpg',
        landmarks: [
          const Landmark(x: 0.1, y: 0.2, z: 0.3, likelihood: 0.95),
        ],
        measurements: {'hip_angle': 90.0, 'missing': null},
        confidence: {'overall': 0.88},
        landmarkPixels: {
          BodyPart.leftHip: const Offset(100, 200),
        },
        success: true,
      );

      final restored = PoseResult.fromMap(original.toMap());
      expect(restored.imagePath, original.imagePath);
      expect(restored.landmarks.length, 1);
      expect(restored.landmarks.first.likelihood, 0.95);
      expect(restored.measurements['hip_angle'], 90.0);
      expect(restored.measurements['missing'], isNull);
      expect(restored.landmarkPixels[BodyPart.leftHip]!.dx, 100);
      expect(restored.success, true);
    });
  });

  group('CheckIn', () {
    test('toMap/fromMap round trip with clinician fields', () {
      final original = CheckIn(
        id: 'ci-1',
        date: DateTime(2026, 9, 15),
        selectedParts: [BodyPart.leftKnee, BodyPart.lowerBack],
        painScore: 6,
        durationKey: '1_2_weeks',
        aggravators: ['sitting', 'stairs'],
        redFlags: [],
        observations: [
          const Observation(
            region: 'knee',
            text: 'You reported stiffness',
            value: null,
            confidence: 0.0,
          ),
        ],
        questions: ['knee_stiffness_morning'],
        hasPhoto: true,
        photoPaths: ['/data/photo1.jpg'],
        poseResults: [],
        notes: 'Follow-up in 2 weeks',
        patientId: 'pat-42',
      );

      final restored = CheckIn.fromMap(original.toMap());
      expect(restored.id, 'ci-1');
      expect(restored.selectedParts, [BodyPart.leftKnee, BodyPart.lowerBack]);
      expect(restored.painScore, 6);
      expect(restored.notes, 'Follow-up in 2 weeks');
      expect(restored.patientId, 'pat-42');
      expect(restored.observations.first.text, 'You reported stiffness');
    });
  });
}
