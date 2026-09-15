import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/clinician_provider.dart';
import '../widgets/angle_chart.dart';
import '../widgets/clinical_disclaimer.dart';

class MeasurementDetailScreen extends StatelessWidget {
  const MeasurementDetailScreen({
    super.key,
    required this.patientId,
    required this.assessmentId,
  });

  final String patientId;
  final String assessmentId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClinicianProvider>();
    final patient = provider.patients.firstWhere((p) => p.id == patientId);
    final assessment = patient.assessments.firstWhere((a) => a.id == assessmentId);
    final obs = assessment.poseObservation;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurement Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => provider.exportPdf(patient, assessment),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ClinicalDisclaimer(),
          const SizedBox(height: 12),
          Text('Recorded ${assessment.createdAt.toLocal()}',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Symptom report', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _row('Pain', '${assessment.symptomReport.painLevel}/10'),
                  _row('Side', assessment.symptomReport.affectedSide),
                  _row('Duration', '${assessment.symptomReport.durationDays}d'),
                  if (assessment.symptomReport.notes.isNotEmpty)
                    _row('Notes', assessment.symptomReport.notes),
                ],
              ),
            ),
          ),
          if (obs != null) ...[
            const SizedBox(height: 16),
            Text('Clinical summary', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(obs.clinicalSummary),
            const SizedBox(height: 16),
            Text('Angle measurements', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            AngleChart(angles: obs.angles),
            const SizedBox(height: 8),
            ...obs.angles.map((a) => ListTile(
                  dense: true,
                  title: Text(a.label),
                  trailing: Text(
                    '${a.degrees.toStringAsFixed(1)}° '
                    '(${ (a.confidence * 100).toStringAsFixed(0)}%)',
                  ),
                )),
            if (obs.lrDeltas.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('L/R deltas', style: theme.textTheme.titleSmall),
              ...obs.lrDeltas.map((d) => ListTile(
                    dense: true,
                    title: Text(d.metric),
                    subtitle: Text(
                      'L=${d.leftValue.toStringAsFixed(1)} '
                      'R=${d.rightValue.toStringAsFixed(1)}',
                    ),
                    trailing: Text(
                      'Δ ${d.delta.toStringAsFixed(1)} ${d.unit}',
                    ),
                  )),
            ],
            const SizedBox(height: 8),
            Text(
              'Overall confidence: ${(obs.overallConfidence * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall,
            ),
            if (obs.landmarks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Landmarks', style: theme.textTheme.titleSmall),
              ...obs.landmarks.map((lm) => ListTile(
                    dense: true,
                    title: Text(lm.name),
                    subtitle: Text(
                      'x=${lm.x.toStringAsFixed(1)} y=${lm.y.toStringAsFixed(1)}',
                    ),
                    trailing: Text('${(lm.confidence * 100).toStringAsFixed(0)}%'),
                  )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
