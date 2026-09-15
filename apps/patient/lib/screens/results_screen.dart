import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/assessment_provider.dart';
import '../widgets/health_disclaimer.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AssessmentProvider>();
    final observation = provider.observation;
    final report = provider.symptomReport;

    return Scaffold(
      appBar: AppBar(title: const Text('What we recorded')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const HealthDisclaimer(),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your report', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (report != null) ...[
                      _row(theme, 'Pain level', '${report.painLevel} out of 10'),
                      _row(theme, 'Side', _sideLabel(report.affectedSide)),
                      _row(theme, 'Duration', '${report.durationDays} days'),
                      if (report.notes.isNotEmpty)
                        _row(theme, 'Notes', report.notes),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Our observations', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      observation?.plainLanguageSummary ??
                          'We recorded the details you shared.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (observation != null && observation.overallConfidence > 0) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: observation.overallConfidence,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recording confidence: '
                        '${(observation.overallConfidence * 100).round()}%',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onContinue,
              child: const Text('See summary'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _sideLabel(String side) {
    switch (side) {
      case 'left':
        return 'Left';
      case 'right':
        return 'Right';
      case 'both':
        return 'Both sides';
      default:
        return 'Not sure';
    }
  }
}
