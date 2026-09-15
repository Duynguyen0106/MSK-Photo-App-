import 'package:csv/csv.dart';

import '../models/patient_record.dart';

/// CSV export for clinician measurement data.
class CsvExportService {
  String exportAssessments(PatientRecord patient) {
    final rows = <List<dynamic>>[
      [
        'patient_id',
        'patient_name',
        'mrn',
        'assessment_id',
        'date',
        'pain_level',
        'affected_side',
        'duration_days',
        'angle_label',
        'angle_degrees',
        'angle_confidence',
        'lr_metric',
        'lr_delta',
        'overall_confidence',
        'clinical_summary',
      ],
    ];

    for (final assessment in patient.assessments) {
      final obs = assessment.poseObservation;
      if (obs != null && obs.angles.isNotEmpty) {
        for (final angle in obs.angles) {
          rows.add([
            patient.id,
            patient.displayName,
            patient.mrn,
            assessment.id,
            assessment.createdAt.toIso8601String(),
            assessment.symptomReport.painLevel,
            assessment.symptomReport.affectedSide,
            assessment.symptomReport.durationDays,
            angle.label,
            angle.degrees,
            angle.confidence,
            obs.lrDeltas.isNotEmpty ? obs.lrDeltas.first.metric : '',
            obs.lrDeltas.isNotEmpty ? obs.lrDeltas.first.delta : '',
            obs.overallConfidence,
            obs.clinicalSummary,
          ]);
        }
      } else {
        rows.add([
          patient.id,
          patient.displayName,
          patient.mrn,
          assessment.id,
          assessment.createdAt.toIso8601String(),
          assessment.symptomReport.painLevel,
          assessment.symptomReport.affectedSide,
          assessment.symptomReport.durationDays,
          '',
          '',
          '',
          '',
          '',
          '',
          obs?.clinicalSummary ?? '',
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }
}
