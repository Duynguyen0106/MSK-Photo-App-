import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum CapturePrompt {
  stepBack,
  standStraight,
  holdStill,
}

class PoseAlignmentStatus {
  const PoseAlignmentStatus({
    required this.prompt,
    required this.isAligned,
  });

  final CapturePrompt prompt;
  final bool isAligned;
}

/// Checks whether a detected pose is present, centered, and upright.
class PoseAlignmentChecker {
  static const double _minLikelihood = 0.5;
  static const double _centerMin = 0.38;
  static const double _centerMax = 0.62;

  PoseAlignmentStatus evaluate(
    Pose pose, {
    required double imageWidth,
    required double imageHeight,
  }) {
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final landmarks = [nose, lShoulder, rShoulder, lHip, rHip, lAnkle, rAnkle];
    if (landmarks.any(
      (lm) => lm == null || lm.likelihood < _minLikelihood,
    )) {
      return const PoseAlignmentStatus(
        prompt: CapturePrompt.stepBack,
        isAligned: false,
      );
    }

    final xs = landmarks.map((lm) => lm!.x).toList();
    final ys = landmarks.map((lm) => lm!.y).toList();
    final minX = xs.reduce((a, b) => a < b ? a : b);
    final maxX = xs.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    final bboxHeight = maxY - minY;
    final bboxWidth = maxX - minX;
    final centerX = (minX + maxX) / 2 / imageWidth;

    final headTooLow = nose!.y > imageHeight * 0.28;
    final feetTooHigh = lAnkle!.y < imageHeight * 0.72 ||
        rAnkle!.y < imageHeight * 0.72;
    final tooClose = bboxHeight > imageHeight * 0.82 || bboxWidth > imageWidth * 0.72;

    if (tooClose || headTooLow || feetTooHigh) {
      return const PoseAlignmentStatus(
        prompt: CapturePrompt.stepBack,
        isAligned: false,
      );
    }

    final shoulderTilt = (lShoulder!.y - rShoulder!.y).abs();
    final hipTilt = (lHip!.y - rHip!.y).abs();
    final offCenter = centerX < _centerMin || centerX > _centerMax;
    final notUpright =
        shoulderTilt > imageHeight * 0.04 || hipTilt > imageHeight * 0.04;

    if (offCenter || notUpright) {
      return const PoseAlignmentStatus(
        prompt: CapturePrompt.standStraight,
        isAligned: false,
      );
    }

    return const PoseAlignmentStatus(
      prompt: CapturePrompt.holdStill,
      isAligned: true,
    );
  }
}
