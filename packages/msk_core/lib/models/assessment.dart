import 'pose_observation.dart';
import 'symptom_report.dart';

/// A complete assessment session — documentation only.
class Assessment {
  const Assessment({
    required this.id,
    required this.patientId,
    required this.createdAt,
    required this.symptomReport,
    this.poseObservation,
    required this.photoConsentGiven,
    required this.notes,
  });

  final String id;
  final String patientId;
  final DateTime createdAt;
  final SymptomReport symptomReport;
  final PoseObservation? poseObservation;
  final bool photoConsentGiven;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'createdAt': createdAt.toIso8601String(),
        'symptomReport': symptomReport.toJson(),
        'poseObservation': poseObservation?.toJson(),
        'photoConsentGiven': photoConsentGiven,
        'notes': notes,
      };

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        symptomReport:
            SymptomReport.fromJson(json['symptomReport'] as Map<String, dynamic>),
        poseObservation: json['poseObservation'] != null
            ? PoseObservation.fromJson(
                json['poseObservation'] as Map<String, dynamic>)
            : null,
        photoConsentGiven: json['photoConsentGiven'] as bool? ?? false,
        notes: json['notes'] as String? ?? '',
      );
}
