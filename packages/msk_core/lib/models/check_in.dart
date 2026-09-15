import 'body_part.dart';
import 'observation.dart';
import 'pose_result.dart';

/// A complete check-in session for patient or clinician use.
class CheckIn {
  const CheckIn({
    required this.id,
    required this.date,
    required this.selectedParts,
    required this.painScore,
    required this.durationKey,
    required this.aggravators,
    required this.redFlags,
    required this.observations,
    required this.questions,
    required this.hasPhoto,
    required this.photoPaths,
    required this.poseResults,
    this.notes,
    this.patientId,
  });

  final String id;
  final DateTime date;
  final List<BodyPart> selectedParts;
  final int painScore;
  final String durationKey;
  final List<String> aggravators;
  final List<String> redFlags;
  final List<Observation> observations;
  final List<String> questions;
  final bool hasPhoto;
  final List<String> photoPaths;
  final List<PoseResult> poseResults;

  /// Clinician-only free-text notes.
  final String? notes;

  /// Clinician-only link to roster patient.
  final String? patientId;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'selectedParts': selectedParts.map((p) => p.name).toList(),
        'painScore': painScore,
        'durationKey': durationKey,
        'aggravators': aggravators,
        'redFlags': redFlags,
        'observations': observations.map((o) => o.toMap()).toList(),
        'questions': questions,
        'hasPhoto': hasPhoto,
        'photoPaths': photoPaths,
        'poseResults': poseResults.map((r) => r.toMap()).toList(),
        'notes': notes,
        'patientId': patientId,
      };

  factory CheckIn.fromMap(Map<String, dynamic> map) => CheckIn(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        selectedParts: (map['selectedParts'] as List<dynamic>)
            .map((e) => bodyPartFromName(e as String))
            .toList(),
        painScore: map['painScore'] as int,
        durationKey: map['durationKey'] as String,
        aggravators: (map['aggravators'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        redFlags: (map['redFlags'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        observations: (map['observations'] as List<dynamic>)
            .map((e) => Observation.fromMap(e as Map<String, dynamic>))
            .toList(),
        questions: (map['questions'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        hasPhoto: map['hasPhoto'] as bool,
        photoPaths: (map['photoPaths'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        poseResults: (map['poseResults'] as List<dynamic>)
            .map((e) => PoseResult.fromMap(e as Map<String, dynamic>))
            .toList(),
        notes: map['notes'] as String?,
        patientId: map['patientId'] as String?,
      );
}
