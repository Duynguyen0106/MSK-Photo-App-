import '../models/body_part.dart';
import '../models/observation.dart';
import '../models/pose_result.dart';

/// Builds neutral, observation-only text from pose measurements.
///
/// Never interprets findings or names any medical condition.
class ObservationService {
  static const _unclearText =
      'Region recorded. Camera could not measure this angle clearly.';

  /// One [Observation] per selected [parts], using measurements from [results].
  ///
  /// [results] keys are view names: `'front'`, `'side'`, `'back'`.
  List<Observation> build({
    required List<BodyPart> parts,
    required Map<String, PoseResult> results,
    required double painScore,
    required String durationKey,
  }) {
    return parts
        .map((part) => _buildForPart(
              part: part,
              results: results,
              painScore: painScore,
              durationKey: durationKey,
            ))
        .toList();
  }

  Observation _buildForPart({
    required BodyPart part,
    required Map<String, PoseResult> results,
    required double painScore,
    required String durationKey,
  }) {
    final spec = _specs[part]!;
    final result = results[spec.view];
    final value = _readMeasurement(result, spec.measurementKey);
    final confidence = _confidenceFor(result, spec.measurementKey);

    final text = value != null
        ? spec.formatValue(
            value,
            results: results,
            painScore: painScore,
            durationKey: durationKey,
          )
        : _unclearText;

    return Observation(
      region: regionFor(part),
      text: text,
      value: value,
      confidence: confidence,
    );
  }

  double? _readMeasurement(PoseResult? result, String? key) {
    if (result == null || !result.success || key == null) return null;
    return result.measurements[key];
  }

  double _confidenceFor(PoseResult? result, String? key) {
    if (result == null || !result.success || key == null) return 0;
    final value = result.measurements[key];
    if (value == null) return 0;
    if (result.confidence.isEmpty) return 0;
    final sum = result.confidence.values.reduce((a, b) => a + b);
    return sum / result.confidence.length;
  }

  static String _formatNum(double v) {
    final rounded = (v * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
  }

  static String _shoulderLowerPhrase(Map<String, PoseResult> results) {
    final front = results['front'];
    final left = front?.landmarkPixels[BodyPart.leftShoulder];
    final right = front?.landmarkPixels[BodyPart.rightShoulder];
    if (left == null || right == null) return 'difference recorded';
    if (left.dy > right.dy) return 'left lower';
    if (right.dy > left.dy) return 'right lower';
    return 'shoulders level';
  }

  static final Map<BodyPart, _PartSpec> _specs = {
    BodyPart.head: _PartSpec(
      view: 'front',
      measurementKey: 'headLateralOffsetCm',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Head lateral offset: ${_formatNum(v)} cm from shoulder midline. '
          'Observed from the front photo.',
    ),
    BodyPart.neck: _PartSpec(
      view: 'side',
      measurementKey: 'forwardHeadAngleDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Forward head angle: ${_formatNum(v)}°. Observed from the side photo.',
    ),
    BodyPart.leftShoulder: _PartSpec(
      view: 'front',
      measurementKey: 'shoulderHeightDiffCm',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Shoulder height difference: ${_formatNum(v)} cm, '
          '${_shoulderLowerPhrase(results)}. Observed from the front photo.',
    ),
    BodyPart.rightShoulder: _PartSpec(
      view: 'front',
      measurementKey: 'shoulderHeightDiffCm',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Shoulder height difference: ${_formatNum(v)} cm, '
          '${_shoulderLowerPhrase(results)}. Observed from the front photo.',
    ),
    BodyPart.chest: _PartSpec(
      view: 'side',
      measurementKey: 'thoracicKyphosisProxyDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Chest angle proxy: ${_formatNum(v)}°. Observed from the side photo.',
    ),
    BodyPart.upperBack: _PartSpec(
      view: 'side',
      measurementKey: 'thoracicKyphosisProxyDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Upper back angle proxy: ${_formatNum(v)}°. Observed from the side photo.',
    ),
    BodyPart.lowerBack: _PartSpec(
      view: 'front',
      measurementKey: 'pelvicTiltDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Pelvic tilt: ${_formatNum(v)}°. Observed from the front photo.',
    ),
    BodyPart.abdomen: _PartSpec(
      view: 'front',
      measurementKey: 'pelvicTiltDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Pelvic tilt at abdomen: ${_formatNum(v)}°. Observed from the front photo.',
    ),
    BodyPart.leftElbow: _PartSpec(
      view: 'front',
      measurementKey: null,
      formatValue: (_, {required results, required painScore, required durationKey}) =>
          _unclearText,
    ),
    BodyPart.rightElbow: _PartSpec(
      view: 'front',
      measurementKey: null,
      formatValue: (_, {required results, required painScore, required durationKey}) =>
          _unclearText,
    ),
    BodyPart.leftWrist: _PartSpec(
      view: 'front',
      measurementKey: null,
      formatValue: (_, {required results, required painScore, required durationKey}) =>
          _unclearText,
    ),
    BodyPart.rightWrist: _PartSpec(
      view: 'front',
      measurementKey: null,
      formatValue: (_, {required results, required painScore, required durationKey}) =>
          _unclearText,
    ),
    BodyPart.leftHip: _PartSpec(
      view: 'front',
      measurementKey: 'pelvicTiltDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Pelvic tilt at left hip: ${_formatNum(v)}°. Observed from the front photo.',
    ),
    BodyPart.rightHip: _PartSpec(
      view: 'front',
      measurementKey: 'pelvicTiltDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Pelvic tilt at right hip: ${_formatNum(v)}°. Observed from the front photo.',
    ),
    BodyPart.leftKnee: _PartSpec(
      view: 'front',
      measurementKey: 'kneeAlignmentLeftDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Left knee angle: ${_formatNum(v)}°. Observed from the front photo.',
    ),
    BodyPart.rightKnee: _PartSpec(
      view: 'front',
      measurementKey: 'kneeAlignmentRightDeg',
      formatValue: (v, {required results, required painScore, required durationKey}) =>
          'Right knee angle: ${_formatNum(v)}°. Observed from the front photo.',
    ),
    BodyPart.leftAnkle: _PartSpec(
      view: 'front',
      measurementKey: null,
      formatValue: (_, {required results, required painScore, required durationKey}) =>
          _unclearText,
    ),
    BodyPart.rightAnkle: _PartSpec(
      view: 'front',
      measurementKey: null,
      formatValue: (_, {required results, required painScore, required durationKey}) =>
          _unclearText,
    ),
  };
}

typedef _FormatValue = String Function(
  double value, {
  required Map<String, PoseResult> results,
  required double painScore,
  required String durationKey,
});

class _PartSpec {
  const _PartSpec({
    required this.view,
    required this.measurementKey,
    required this.formatValue,
  });

  final String view;
  final String? measurementKey;
  final _FormatValue formatValue;
}
