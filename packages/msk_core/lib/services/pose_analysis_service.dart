import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/landmark_data.dart';
import '../models/pose_observation.dart';
import '../models/symptom_report.dart';
import 'observation_formatter.dart';

/// On-device pose detection and measurement — observations only.
class PoseAnalysisService {
  PoseAnalysisService() : _detector = PoseDetector(options: PoseDetectorOptions());

  final PoseDetector _detector;

  static const _landmarkNames = {
    PoseLandmarkType.leftShoulder: 'left_shoulder',
    PoseLandmarkType.rightShoulder: 'right_shoulder',
    PoseLandmarkType.leftHip: 'left_hip',
    PoseLandmarkType.rightHip: 'right_hip',
    PoseLandmarkType.leftKnee: 'left_knee',
    PoseLandmarkType.rightKnee: 'right_knee',
    PoseLandmarkType.leftAnkle: 'left_ankle',
    PoseLandmarkType.rightAnkle: 'right_ankle',
  };

  Future<void> dispose() => _detector.close();

  Future<PoseObservation> analyzeImage({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required SymptomReport report,
  }) async {
    final inputImage = InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: width,
      ),
    );

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) {
      return _emptyObservation(report);
    }

    final pose = poses.first;
    final landmarks = _extractLandmarks(pose);
    final angles = _computeAngles(pose);
    final deltas = _computeLrDeltas(pose);
    final confidence = _overallConfidence(landmarks);

    return ObservationFormatter.buildObservation(
      report: report,
      landmarks: landmarks,
      angles: angles,
      deltas: deltas,
      confidence: confidence,
    );
  }

  /// Build observation from manual symptom data when photo capture is skipped.
  PoseObservation buildManualObservation(SymptomReport report) {
    return ObservationFormatter.buildObservation(
      report: report,
      landmarks: [],
      angles: [],
      deltas: [],
      confidence: 0.0,
    );
  }

  PoseObservation _emptyObservation(SymptomReport report) {
    return ObservationFormatter.buildObservation(
      report: report,
      landmarks: [],
      angles: [],
      deltas: [],
      confidence: 0.0,
    );
  }

  List<LandmarkPoint> _extractLandmarks(Pose pose) {
    final points = <LandmarkPoint>[];
    for (final entry in _landmarkNames.entries) {
      final lm = pose.landmarks[entry.key];
      if (lm != null) {
        points.add(LandmarkPoint(
          name: entry.value,
          x: lm.x,
          y: lm.y,
          confidence: lm.likelihood,
        ));
      }
    }
    return points;
  }

  List<AngleMeasurement> _computeAngles(Pose pose) {
    final angles = <AngleMeasurement>[];

    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final lKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    if (lShoulder != null && lHip != null && lKnee != null) {
      angles.add(_angleBetween(
        'left_hip_flexion',
        lShoulder,
        lHip,
        lKnee,
      ));
    }

    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    if (rShoulder != null && rHip != null && rKnee != null) {
      angles.add(_angleBetween(
        'right_hip_flexion',
        rShoulder,
        rHip,
        rKnee,
      ));
    }

    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (lHip != null && lKnee != null && lAnkle != null) {
      angles.add(_angleBetween(
        'left_knee_flexion',
        lHip,
        lKnee,
        lAnkle,
      ));
    }

    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    if (rHip != null && rKnee != null && rAnkle != null) {
      angles.add(_angleBetween(
        'right_knee_flexion',
        rHip,
        rKnee,
        rAnkle,
      ));
    }

    return angles;
  }

  AngleMeasurement _angleBetween(
    String label,
    PoseLandmark a,
    PoseLandmark vertex,
    PoseLandmark c,
  ) {
    final angle = _degrees(a.x, a.y, vertex.x, vertex.y, c.x, c.y);
    final conf = (a.likelihood + vertex.likelihood + c.likelihood) / 3;
    return AngleMeasurement(
      label: label,
      degrees: angle,
      confidence: conf,
      landmarksUsed: [label],
    );
  }

  double _degrees(double ax, double ay, double bx, double by, double cx, double cy) {
    final ab = math.sqrt(math.pow(ax - bx, 2) + math.pow(ay - by, 2));
    final cb = math.sqrt(math.pow(cx - bx, 2) + math.pow(cy - by, 2));
    final dot = (ax - bx) * (cx - bx) + (ay - by) * (cy - by);
    if (ab == 0 || cb == 0) return 0;
    final cosAngle = (dot / (ab * cb)).clamp(-1.0, 1.0);
    return math.acos(cosAngle) * 180 / math.pi;
  }

  List<LrDelta> _computeLrDeltas(Pose pose) {
    final deltas = <LrDelta>[];
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (lShoulder != null && rShoulder != null) {
      final lY = lShoulder.y;
      final rY = rShoulder.y;
      deltas.add(LrDelta(
        metric: 'shoulder_height',
        leftValue: lY,
        rightValue: rY,
        delta: (lY - rY).abs(),
        unit: 'px',
      ));
    }

    if (lHip != null && rHip != null) {
      final lY = lHip.y;
      final rY = rHip.y;
      deltas.add(LrDelta(
        metric: 'hip_height',
        leftValue: lY,
        rightValue: rY,
        delta: (lY - rY).abs(),
        unit: 'px',
      ));
    }

    return deltas;
  }

  double _overallConfidence(List<LandmarkPoint> landmarks) {
    if (landmarks.isEmpty) return 0;
    return landmarks.map((l) => l.confidence).reduce((a, b) => a + b) /
        landmarks.length;
  }
}
