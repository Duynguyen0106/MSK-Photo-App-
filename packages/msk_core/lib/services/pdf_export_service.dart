import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/assessment.dart';
import '../models/patient_record.dart';
import 'disclaimer_service.dart';

/// PDF export for clinician documentation.
class PdfExportService {
  Future<void> printAssessment(PatientRecord patient, Assessment assessment) async {
    final doc = await _buildDocument(patient, assessment);
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  Future<pw.Document> _buildDocument(
    PatientRecord patient,
    Assessment assessment,
  ) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('MSK Assessment Record')),
          pw.Paragraph(text: DisclaimerService.clinicianDisclaimer),
          pw.SizedBox(height: 12),
          pw.Text('Patient: ${patient.displayName}'),
          pw.Text('MRN: ${patient.mrn}'),
          pw.Text('Date: ${assessment.createdAt.toIso8601String()}'),
          pw.SizedBox(height: 12),
          pw.Header(level: 1, child: pw.Text('Symptom Report')),
          pw.Text(
            'Reported pain: ${assessment.symptomReport.painLevel}/10',
          ),
          pw.Text('Side: ${assessment.symptomReport.affectedSide}'),
          pw.Text('Duration: ${assessment.symptomReport.durationDays} days'),
          if (assessment.symptomReport.notes.isNotEmpty)
            pw.Text('Notes: ${assessment.symptomReport.notes}'),
          if (assessment.poseObservation != null) ...[
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('Pose Observations')),
            pw.Text(assessment.poseObservation!.clinicalSummary),
            pw.SizedBox(height: 8),
            for (final angle in assessment.poseObservation!.angles)
              pw.Text(
                '${angle.label}: ${angle.degrees.toStringAsFixed(1)}° '
                '(conf ${(angle.confidence * 100).toStringAsFixed(0)}%)',
              ),
            for (final delta in assessment.poseObservation!.lrDeltas)
              pw.Text(
                'L/R ${delta.metric}: Δ=${delta.delta.toStringAsFixed(1)} ${delta.unit}',
              ),
          ],
        ],
      ),
    );
    return doc;
  }
}
