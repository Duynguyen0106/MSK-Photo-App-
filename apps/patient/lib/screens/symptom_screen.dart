import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/assessment_provider.dart';
import '../widgets/health_disclaimer.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final Set<RedFlagSymptom> _selectedFlags = {};
  double _painLevel = 3;
  String _side = 'unsure';
  int _durationDays = 7;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final provider = context.read<AssessmentProvider>();
    provider.setRedFlags(_selectedFlags);

    if (provider.redFlagResult?.hasRedFlags == true) {
      _showUrgentDialog(provider.redFlagResult!.urgentCareMessage);
      return;
    }

    provider.setSymptomReport(SymptomReport(
      reportedAt: DateTime.now(),
      painLevel: _painLevel.round(),
      affectedSide: _side,
      durationDays: _durationDays,
      notes: _notesController.text.trim(),
      usedPhotoCapture: false,
    ));
    widget.onContinue();
  }

  void _showUrgentDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48),
        title: const Text('Please seek care'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('I understand'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onContinue();
            },
            child: const Text('Continue anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('How do you feel?')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const HealthDisclaimer(),
            const SizedBox(height: 20),
            Text('Pain level', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Mild'),
                Expanded(
                  child: Slider(
                    value: _painLevel,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _painLevel.round().toString(),
                    onChanged: (v) => setState(() => _painLevel = v),
                  ),
                ),
                const Text('Strong'),
              ],
            ),
            Text('${_painLevel.round()} out of 10', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text('Which side feels affected?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'left', label: Text('Left')),
                ButtonSegment(value: 'right', label: Text('Right')),
                ButtonSegment(value: 'both', label: Text('Both')),
                ButtonSegment(value: 'unsure', label: Text('Not sure')),
              ],
              selected: {_side},
              onSelectionChanged: (s) => setState(() => _side = s.first),
            ),
            const SizedBox(height: 20),
            Text('How long has this been going on?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _durationDays > 1
                      ? () => setState(() => _durationDays--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_durationDays days', style: theme.textTheme.titleLarge),
                IconButton(
                  onPressed: () => setState(() => _durationDays++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Any warning signs?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Check anything you are experiencing right now.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ...RedFlagSymptom.values.map((flag) => CheckboxListTile(
                  title: Text(flag.label),
                  value: _selectedFlags.contains(flag),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedFlags.add(flag);
                      } else {
                        _selectedFlags.remove(flag);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                )),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Anything else you want to note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
