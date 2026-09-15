import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/clinician_provider.dart';
import '../widgets/clinical_disclaimer.dart';
import 'assessment_capture_screen.dart';
import 'measurement_detail_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicianProvider>();
    final patient = provider.patients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => provider.selectedPatient!,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(patient.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () {
              final csv = provider.exportCsv(patient);
              Clipboard.setData(ClipboardData(text: csv));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV copied to clipboard')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssessmentCaptureScreen(patientId: patientId),
          ),
        ),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('New assessment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ClinicalDisclaimer(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient info', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _infoRow('MRN', patient.mrn),
                  _infoRow('DOB', patient.dateOfBirth.toIso8601String().split('T').first),
                  _infoRow('Assessments', '${patient.assessments.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Assessment history', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (patient.assessments.isEmpty)
            Text('No assessments recorded yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ))
          else
            ...patient.assessments.reversed.map((a) => Card(
                  child: ListTile(
                    title: Text(a.createdAt.toLocal().toString().split('.').first),
                    subtitle: Text(
                      'Pain ${a.symptomReport.painLevel}/10 · '
                      '${a.symptomReport.affectedSide}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeasurementDetailScreen(
                          patientId: patientId,
                          assessmentId: a.id,
                        ),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
