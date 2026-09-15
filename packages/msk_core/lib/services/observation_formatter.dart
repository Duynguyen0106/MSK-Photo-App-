import '../models/landmark_data.dart';
import '../models/pose_observation.dart';
import '../models/symptom_report.dart';

/// Formats data as observations — never diagnoses or conclusions.
class ObservationFormatter {
  /// Plain-language summary for the patient app.
  static String plainLanguageSummary({
    required SymptomReport report,
    required List<AngleMeasurement> angles,
    required double confidence,
  }) {
    final side = _sideLabel(report.affectedSide);
    final parts = <String>[
      'You reported discomfort on the $side side',
      'with a level of ${report.painLevel} out of 10',
      'for about ${report.durationDays} day${report.durationDays == 1 ? '' : 's'}.',
    ];
    if (angles.isNotEmpty) {
      final primary = angles.first;
      parts.add(
        'We recorded a body position measurement of '
        '${primary.degrees.round()} (confidence ${(confidence * 100).round()}%).',
      );
    }
    if (report.usedPhotoCapture) {
      parts.add('A photo was used for on-device analysis.');
    } else {
      parts.add('You entered your information manually.');
    }
    return parts.join(' ');
  }

  /// Clinical summary for the clinician app.
  static String clinicalSummary({
    required SymptomReport report,
    required List<AngleMeasurement> angles,
    required List<LrDelta> deltas,
    required double confidence,
  }) {
    final parts = <String>[
      'Patient reported ${report.affectedSide} involvement, '
      'pain ${report.painLevel}/10, duration ${report.durationDays}d.',
    ];
    for (final angle in angles) {
      parts.add(
        'Recorded ${angle.label}: ${angle.degrees.toStringAsFixed(1)}° '
        '(conf ${(angle.confidence * 100).toStringAsFixed(0)}%).',
      );
    }
    for (final delta in deltas) {
      parts.add(
        'L/R ${delta.metric}: L=${delta.leftValue.toStringAsFixed(1)} '
        'R=${delta.rightValue.toStringAsFixed(1)} '
        'Δ=${delta.delta.toStringAsFixed(1)} ${delta.unit}.',
      );
    }
    parts.add('Overall pose confidence: ${(confidence * 100).toStringAsFixed(0)}%.');
    return parts.join(' ');
  }

  static PoseObservation buildObservation({
    required SymptomReport report,
    required List<LandmarkPoint> landmarks,
    required List<AngleMeasurement> angles,
    required List<LrDelta> deltas,
    required double confidence,
  }) {
    return PoseObservation(
      recordedAt: DateTime.now(),
      landmarks: landmarks,
      angles: angles,
      lrDeltas: deltas,
      overallConfidence: confidence,
      plainLanguageSummary: plainLanguageSummary(
        report: report,
        angles: angles,
        confidence: confidence,
      ),
      clinicalSummary: clinicalSummary(
        report: report,
        angles: angles,
        deltas: deltas,
        confidence: confidence,
      ),
    );
  }

  static String _sideLabel(String side) {
    switch (side) {
      case 'left':
        return 'left';
      case 'right':
        return 'right';
      case 'both':
        return 'both';
      default:
        return 'unspecified';
    }
  }
}
