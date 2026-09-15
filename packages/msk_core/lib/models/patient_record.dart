import 'assessment.dart';

/// Patient record for clinician roster — encrypted local storage.
class PatientRecord {
  const PatientRecord({
    required this.id,
    required this.displayName,
    required this.dateOfBirth,
    required this.mrn,
    required this.createdAt,
    required this.assessments,
    this.notes = '',
  });

  final String id;
  final String displayName;
  final DateTime dateOfBirth;
  final String mrn;
  final DateTime createdAt;
  final List<Assessment> assessments;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'mrn': mrn,
        'createdAt': createdAt.toIso8601String(),
        'assessments': assessments.map((a) => a.toJson()).toList(),
        'notes': notes,
      };

  factory PatientRecord.fromJson(Map<String, dynamic> json) => PatientRecord(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
        mrn: json['mrn'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        assessments: (json['assessments'] as List<dynamic>?)
                ?.map((e) => Assessment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        notes: json['notes'] as String? ?? '',
      );
}
