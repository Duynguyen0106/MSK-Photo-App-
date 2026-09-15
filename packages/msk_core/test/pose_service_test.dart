import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:msk_core/msk_core.dart';

void main() {
  group('PoseResult.failure', () {
    test('creates unsuccessful result with message', () {
      final result = PoseResult.failure('/path.jpg', 'No person detected');
      expect(result.success, false);
      expect(result.errorMessage, 'No person detected');
      expect(result.landmarks, isEmpty);
    });
  });

  group('PoseService measurements', () {
    const threshold = 0.5;

    Pose makePose(Map<PoseLandmarkType, PoseLandmark> landmarks) =>
        Pose(landmarks: landmarks);

    PoseLandmark makeLm(PoseLandmarkType type, double x, double y,
            {double likelihood = 0.9}) =>
        PoseLandmark(type: type, x: x, y: y, z: 0, likelihood: likelihood);

    test('computeShoulderHeightDiffCm converts pixel delta to cm', () {
      final pose = makePose({
        PoseLandmarkType.nose: makeLm(PoseLandmarkType.nose, 200, 100),
        PoseLandmarkType.leftShoulder:
            makeLm(PoseLandmarkType.leftShoulder, 150, 200),
        PoseLandmarkType.rightShoulder:
            makeLm(PoseLandmarkType.rightShoulder, 250, 220),
        PoseLandmarkType.leftAnkle: makeLm(PoseLandmarkType.leftAnkle, 160, 900),
        PoseLandmarkType.rightAnkle:
            makeLm(PoseLandmarkType.rightAnkle, 240, 900),
        PoseLandmarkType.leftHip: makeLm(PoseLandmarkType.leftHip, 160, 500),
        PoseLandmarkType.rightHip: makeLm(PoseLandmarkType.rightHip, 240, 500),
      });

      final result = PoseService.computeShoulderHeightDiffCm(pose, threshold);
      expect(result, isNotNull);
      // 20 px delta; height span 800 px → 170/800 cm/px → 4.25 cm
      expect(result, closeTo(4.25, 0.01));
    });

    test('computePelvicTiltDeg returns atan2 of hip line', () {
      final pose = makePose({
        PoseLandmarkType.leftHip: makeLm(PoseLandmarkType.leftHip, 100, 500),
        PoseLandmarkType.rightHip: makeLm(PoseLandmarkType.rightHip, 300, 520),
      });

      final result = PoseService.computePelvicTiltDeg(pose, threshold);
      expect(result, isNotNull);
      expect(result!, closeTo(5.71, 0.1));
    });

    test('computeKneeAlignmentDeg returns interior angle at knee', () {
      final pose = makePose({
        PoseLandmarkType.leftHip: makeLm(PoseLandmarkType.leftHip, 100, 400),
        PoseLandmarkType.leftKnee: makeLm(PoseLandmarkType.leftKnee, 100, 600),
        PoseLandmarkType.leftAnkle: makeLm(PoseLandmarkType.leftAnkle, 100, 800),
      });

      final result = PoseService.computeKneeAlignmentDeg(
        pose,
        side: 'left',
        threshold: threshold,
      );
      expect(result, closeTo(180, 0.1));
    });

    test('returns null when landmark confidence is low', () {
      final pose = makePose({
        PoseLandmarkType.leftShoulder: makeLm(
          PoseLandmarkType.leftShoulder,
          150,
          200,
          likelihood: 0.1,
        ),
        PoseLandmarkType.rightShoulder:
            makeLm(PoseLandmarkType.rightShoulder, 250, 200),
      });

      expect(
        PoseService.computeShoulderHeightDiffCm(pose, threshold),
        isNull,
      );
    });

    test('computeForwardHeadAngleDeg uses ear-shoulder-hip chain', () {
      final pose = makePose({
        PoseLandmarkType.leftEar: makeLm(PoseLandmarkType.leftEar, 120, 150),
        PoseLandmarkType.leftShoulder:
            makeLm(PoseLandmarkType.leftShoulder, 100, 250),
        PoseLandmarkType.leftHip: makeLm(PoseLandmarkType.leftHip, 100, 550),
      });

      final result = PoseService.computeForwardHeadAngleDeg(pose, threshold);
      expect(result, isNotNull);
      expect(result!, greaterThan(0));
    });
  });
}
