import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/body_part.dart';
import '../models/pose_result.dart';

/// On-device pose detection and geometric measurement — observations only.
///
/// This service records landmark positions and derived numeric values.
/// It does NOT interpret results or name any condition.
class PoseService {
  PoseService({PoseDetector? detector, double confidenceThreshold = 0.5})
      : _detector = detector ??
            PoseDetector(
              options: PoseDetectorOptions(
                model: PoseDetectionModel.accurate,
                mode: PoseDetectionMode.single,
              ),
            ),
        _confidenceThreshold = confidenceThreshold;

  final PoseDetector _detector;

  /// Minimum landmark likelihood required before a value is computed.
  final double _confidenceThreshold;

  /// Assumed standing height (cm) used to convert pixel distances to cm.
  static const double assumedHeightCm = 170.0;

  Future<void> dispose() => _detector.close();

  /// Analyze a still image and return landmark positions and measurements.
  ///
  /// [view] must be `'front'`, `'side'`, or `'back'`.
  /// Front and back share the same measurement set; side uses sagittal proxies.
  Future<PoseResult> analyze(String imagePath, {required String view}) async {
    if (view != 'front' && view != 'side' && view != 'back') {
      throw ArgumentError.value(view, 'view', "must be 'front', 'side', or 'back'");
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final poses = await _detector.processImage(inputImage);

    if (poses.isEmpty) {
      return PoseResult.failure(imagePath, 'No person detected');
    }

    final pose = poses.first;
    final landmarks = _extractAllLandmarks(pose);
    final confidence = _perLandmarkConfidence(pose);
    final landmarkPixels = _buildLandmarkPixels(pose);

    final measurements = view == 'side'
        ? _sideMeasurements(pose)
        : _frontBackMeasurements(pose);

    return PoseResult(
      imagePath: imagePath,
      landmarks: landmarks,
      measurements: measurements,
      confidence: confidence,
      landmarkPixels: landmarkPixels,
      success: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Landmark extraction
  // ---------------------------------------------------------------------------

  /// Extract all 33 ML Kit landmarks in enum order.
  List<Landmark> _extractAllLandmarks(Pose pose) {
    return PoseLandmarkType.values.map((type) {
      final lm = pose.landmarks[type];
      if (lm == null) {
        return const Landmark(x: 0, y: 0, z: 0, likelihood: 0);
      }
      return Landmark(
        x: lm.x,
        y: lm.y,
        z: lm.z,
        likelihood: lm.likelihood,
      );
    }).toList();
  }

  /// Per-landmark likelihood keyed by enum name (e.g. `leftKnee`).
  Map<String, double> _perLandmarkConfidence(Pose pose) {
    return {
      for (final type in PoseLandmarkType.values)
        type.name: pose.landmarks[type]?.likelihood ?? 0.0,
    };
  }

  /// Map clinically relevant landmarks to [BodyPart] pixel coordinates.
  Map<BodyPart, Offset> _buildLandmarkPixels(Pose pose) {
    final pixels = <BodyPart, Offset>{};

    void put(BodyPart part, PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      if (lm != null && lm.likelihood >= _confidenceThreshold) {
        pixels[part] = Offset(lm.x, lm.y);
      }
    }

    put(BodyPart.head, PoseLandmarkType.nose);
    put(BodyPart.leftShoulder, PoseLandmarkType.leftShoulder);
    put(BodyPart.rightShoulder, PoseLandmarkType.rightShoulder);
    put(BodyPart.leftElbow, PoseLandmarkType.leftElbow);
    put(BodyPart.rightElbow, PoseLandmarkType.rightElbow);
    put(BodyPart.leftWrist, PoseLandmarkType.leftWrist);
    put(BodyPart.rightWrist, PoseLandmarkType.rightWrist);
    put(BodyPart.leftHip, PoseLandmarkType.leftHip);
    put(BodyPart.rightHip, PoseLandmarkType.rightHip);
    put(BodyPart.leftKnee, PoseLandmarkType.leftKnee);
    put(BodyPart.rightKnee, PoseLandmarkType.rightKnee);
    put(BodyPart.leftAnkle, PoseLandmarkType.leftAnkle);
    put(BodyPart.rightAnkle, PoseLandmarkType.rightAnkle);

    // Proxy points for regions without a direct ML Kit landmark.
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (nose != null && lSh != null && rSh != null) {
      // Neck: centroid of nose and both shoulders.
      pixels[BodyPart.neck] = Offset(
        (nose.x + lSh.x + rSh.x) / 3,
        (nose.y + lSh.y + rSh.y) / 3,
      );
    }

    if (lSh != null && rSh != null && lHip != null && rHip != null) {
      final shoulderMid = Offset((lSh.x + rSh.x) / 2, (lSh.y + rSh.y) / 2);
      final hipMid = Offset((lHip.x + rHip.x) / 2, (lHip.y + rHip.y) / 2);
      // Chest / upper back: midpoint between shoulder line and hip line.
      pixels[BodyPart.chest] = Offset(
        (shoulderMid.dx + hipMid.dx) / 2,
        (shoulderMid.dy + hipMid.dy) / 2,
      );
      pixels[BodyPart.upperBack] = pixels[BodyPart.chest]!;
      pixels[BodyPart.lowerBack] = hipMid;
      pixels[BodyPart.abdomen] = Offset(
        (shoulderMid.dx + hipMid.dx * 2) / 3,
        (shoulderMid.dy + hipMid.dy * 2) / 3,
      );
    }

    return pixels;
  }

  // ---------------------------------------------------------------------------
  // Front / back measurements
  // ---------------------------------------------------------------------------

  Map<String, double?> _frontBackMeasurements(Pose pose) {
    return {
      'shoulderHeightDiffCm': computeShoulderHeightDiffCm(pose, _confidenceThreshold),
      'pelvicTiltDeg': computePelvicTiltDeg(pose, _confidenceThreshold),
      'kneeAlignmentLeftDeg': computeKneeAlignmentDeg(
        pose,
        side: 'left',
        threshold: _confidenceThreshold,
      ),
      'kneeAlignmentRightDeg': computeKneeAlignmentDeg(
        pose,
        side: 'right',
        threshold: _confidenceThreshold,
      ),
      'headLateralOffsetCm': computeHeadLateralOffsetCm(pose, _confidenceThreshold),
    };
  }

  // ---------------------------------------------------------------------------
  // Side-view measurements
  // ---------------------------------------------------------------------------

  Map<String, double?> _sideMeasurements(Pose pose) {
    return {
      'forwardHeadAngleDeg': computeForwardHeadAngleDeg(pose, _confidenceThreshold),
      'thoracicKyphosisProxyDeg':
          computeThoracicKyphosisProxyDeg(pose, _confidenceThreshold),
    };
  }

  // ---------------------------------------------------------------------------
  // Measurement formulas (visible for unit tests)
  // ---------------------------------------------------------------------------

  /// Shoulder height difference in cm.
  ///
  /// Formula:
  /// 1. Δy_px = |leftShoulder.y − rightShoulder.y|  (vertical pixel gap).
  /// 2. Scale: cm_per_px = assumedHeightCm / person_height_px, where
  ///    person_height_px = ankle_mid_y − nose.y  (standing span in image).
  /// 3. shoulderHeightDiffCm = Δy_px × cm_per_px.
  ///
  /// Returns null when shoulders or scale landmarks are missing / low confidence.
  @visibleForTesting
  static double? computeShoulderHeightDiffCm(
    Pose pose,
    double threshold,
  ) {
    final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (!_allConfident([lSh, rSh], threshold)) return null;

    final cmPerPx = _cmPerPixel(pose, threshold);
    if (cmPerPx == null) return null;

    final deltaPx = (lSh!.y - rSh!.y).abs();
    return deltaPx * cmPerPx;
  }

  /// Pelvic tilt in degrees.
  ///
  /// Formula:
  /// Draw a line from left hip to right hip. In image coordinates (y grows
  /// downward), the tilt angle is:
  ///   pelvicTiltDeg = atan2(Δy, Δx) × 180/π
  /// where Δy = rightHip.y − leftHip.y and Δx = rightHip.x − leftHip.x.
  /// 0° means a level pelvis; positive/negative values record deviation only.
  @visibleForTesting
  static double? computePelvicTiltDeg(Pose pose, double threshold) {
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    if (!_allConfident([lHip, rHip], threshold)) return null;

    final dy = rHip!.y - lHip!.y;
    final dx = rHip.x - lHip.x;
    return math.atan2(dy, dx) * 180 / math.pi;
  }

  /// Frontal knee angle in degrees (hip–knee–ankle at the knee vertex).
  ///
  /// Formula:
  /// Interior angle at the knee landmark between vectors (hip→knee) and
  /// (ankle→knee):
  ///   θ = arccos( dot(v1, v2) / (|v1| × |v2|) ) × 180/π
  /// where v1 = hip − knee, v2 = ankle − knee.
  @visibleForTesting
  static double? computeKneeAlignmentDeg(
    Pose pose, {
    required String side,
    required double threshold,
  }) {
    final (hip, knee, ankle) = side == 'left'
        ? (
            pose.landmarks[PoseLandmarkType.leftHip],
            pose.landmarks[PoseLandmarkType.leftKnee],
            pose.landmarks[PoseLandmarkType.leftAnkle],
          )
        : (
            pose.landmarks[PoseLandmarkType.rightHip],
            pose.landmarks[PoseLandmarkType.rightKnee],
            pose.landmarks[PoseLandmarkType.rightAnkle],
          );

    if (!_allConfident([hip, knee, ankle], threshold)) return null;

    return _angleAtVertex(
      hip!.x, hip.y,
      knee!.x, knee.y,
      ankle!.x, ankle.y,
    );
  }

  /// Lateral head offset from shoulder midline in cm.
  ///
  /// Formula:
  /// 1. shoulder_mid_x = (leftShoulder.x + rightShoulder.x) / 2.
  /// 2. offset_px = nose.x − shoulder_mid_x  (signed; + = right in image).
  /// 3. headLateralOffsetCm = offset_px × cm_per_px.
  @visibleForTesting
  static double? computeHeadLateralOffsetCm(Pose pose, double threshold) {
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (!_allConfident([nose, lSh, rSh], threshold)) return null;

    final cmPerPx = _cmPerPixel(pose, threshold);
    if (cmPerPx == null) return null;

    final midX = (lSh!.x + rSh!.x) / 2;
    return (nose!.x - midX) * cmPerPx;
  }

  /// Forward head angle in degrees (side view).
  ///
  /// Formula:
  /// Interior angle at the shoulder between ear, shoulder, and hip on the
  /// visible side (prefers left chain; falls back to right):
  ///   θ = angle(ear → shoulder ← hip)
  /// Smaller angles indicate the ear is further forward relative to the hip.
  @visibleForTesting
  static double? computeForwardHeadAngleDeg(Pose pose, double threshold) {
    final chain = _sideChain(pose, threshold);
    if (chain == null) return null;

    return _angleAtVertex(
      chain.ear.x, chain.ear.y,
      chain.shoulder.x, chain.shoulder.y,
      chain.hip.x, chain.hip.y,
    );
  }

  /// Thoracic curve proxy in degrees (side view).
  ///
  /// Formula:
  /// 1. shoulder_mid = midpoint(leftShoulder, rightShoulder).
  /// 2. hip_mid = midpoint(leftHip, rightHip).
  /// 3. torso vector v = shoulder_mid − hip_mid (points upward in standing pose).
  /// 4. Compare v to vertical reference (0, −1) in image coords:
  ///    thoracicKyphosisProxyDeg = arccos( dot(v̂, vertical) ) × 180/π.
  /// This records torso inclination only — not a clinical diagnosis.
  @visibleForTesting
  static double? computeThoracicKyphosisProxyDeg(Pose pose, double threshold) {
    final lSh = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rSh = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    if (!_allConfident([lSh, rSh, lHip, rHip], threshold)) return null;

    final shMidX = (lSh!.x + rSh!.x) / 2;
    final shMidY = (lSh.y + rSh.y) / 2;
    final hipMidX = (lHip!.x + rHip!.x) / 2;
    final hipMidY = (lHip.y + rHip.y) / 2;

    // Torso vector from hip midpoint toward shoulder midpoint.
    final vx = shMidX - hipMidX;
    final vy = shMidY - hipMidY;
    final mag = math.sqrt(vx * vx + vy * vy);
    if (mag == 0) return null;

    // Vertical reference pointing upward in image coordinates.
    const refX = 0.0;
    const refY = -1.0;
    final dot = (vx / mag) * refX + (vy / mag) * refY;
    return math.acos(dot.clamp(-1.0, 1.0)) * 180 / math.pi;
  }

  // ---------------------------------------------------------------------------
  // Shared math helpers
  // ---------------------------------------------------------------------------

  /// Pixels per cm scale from nose-to-ankle standing height.
  ///
  /// person_height_px = mean(ankle.y) − nose.y; cm_per_px = assumedHeightCm / person_height_px.
  static double? _cmPerPixel(Pose pose, double threshold) {
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    if (!_allConfident([nose, lAnkle, rAnkle], threshold)) return null;

    final ankleY = (lAnkle!.y + rAnkle!.y) / 2;
    final heightPx = ankleY - nose!.y;
    if (heightPx <= 0) return null;

    return assumedHeightCm / heightPx;
  }

  /// Interior angle at vertex B formed by points A–B–C (degrees).
  static double _angleAtVertex(
    double ax, double ay,
    double bx, double by,
    double cx, double cy,
  ) {
    final v1x = ax - bx;
    final v1y = ay - by;
    final v2x = cx - bx;
    final v2y = cy - by;
    final mag1 = math.sqrt(v1x * v1x + v1y * v1y);
    final mag2 = math.sqrt(v2x * v2x + v2y * v2y);
    if (mag1 == 0 || mag2 == 0) return 0;
    final dot = (v1x * v2x + v1y * v2y) / (mag1 * mag2);
    return math.acos(dot.clamp(-1.0, 1.0)) * 180 / math.pi;
  }

  static bool _allConfident(List<PoseLandmark?> landmarks, double threshold) {
    return landmarks.every(
      (lm) => lm != null && lm.likelihood >= threshold,
    );
  }

  /// Visible-side ear–shoulder–hip chain for sagittal measurements.
  static _SideChain? _sideChain(Pose pose, double threshold) {
    final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    if (_allConfident([leftEar, leftShoulder, leftHip], threshold)) {
      return _SideChain(
        ear: leftEar!,
        shoulder: leftShoulder!,
        hip: leftHip!,
      );
    }

    final rightEar = pose.landmarks[PoseLandmarkType.rightEar];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    if (_allConfident([rightEar, rightShoulder, rightHip], threshold)) {
      return _SideChain(
        ear: rightEar!,
        shoulder: rightShoulder!,
        hip: rightHip!,
      );
    }

    return null;
  }
}

class _SideChain {
  const _SideChain({
    required this.ear,
    required this.shoulder,
    required this.hip,
  });

  final PoseLandmark ear;
  final PoseLandmark shoulder;
  final PoseLandmark hip;
}
