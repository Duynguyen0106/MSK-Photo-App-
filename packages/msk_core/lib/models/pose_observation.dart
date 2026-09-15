import 'landmark_data.dart';

/// Observations recorded from on-device pose analysis — not diagnoses.
class PoseObservation {
  const PoseObservation({
    required this.recordedAt,
    required this.landmarks,
    required this.angles,
    required this.lrDeltas,
    required this.overallConfidence,
    required this.plainLanguageSummary,
    required this.clinicalSummary,
  });

  final DateTime recordedAt;
  final List<LandmarkPoint> landmarks;
  final List<AngleMeasurement> angles;
  final List<LrDelta> lrDeltas;
  final double overallConfidence;
  final String plainLanguageSummary;
  final String clinicalSummary;

  Map<String, dynamic> toJson() => {
        'recordedAt': recordedAt.toIso8601String(),
        'landmarks': landmarks.map((l) => l.toJson()).toList(),
        'angles': angles.map((a) => a.toJson()).toList(),
        'lrDeltas': lrDeltas.map((d) => d.toJson()).toList(),
        'overallConfidence': overallConfidence,
        'plainLanguageSummary': plainLanguageSummary,
        'clinicalSummary': clinicalSummary,
      };

  factory PoseObservation.fromJson(Map<String, dynamic> json) =>
      PoseObservation(
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        landmarks: (json['landmarks'] as List<dynamic>)
            .map((e) => LandmarkPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        angles: (json['angles'] as List<dynamic>)
            .map((e) => AngleMeasurement.fromJson(e as Map<String, dynamic>))
            .toList(),
        lrDeltas: (json['lrDeltas'] as List<dynamic>)
            .map((e) => LrDelta.fromJson(e as Map<String, dynamic>))
            .toList(),
        overallConfidence: (json['overallConfidence'] as num).toDouble(),
        plainLanguageSummary: json['plainLanguageSummary'] as String,
        clinicalSummary: json['clinicalSummary'] as String,
      );
}
