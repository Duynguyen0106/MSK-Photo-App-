import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

class PainMapScreen extends StatelessWidget {
  const PainMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Where do you feel it?')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          Text(
            'Tap the areas that feel uncomfortable right now.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BodyPart.values.map((part) {
              final selected = provider.selectedParts.contains(part);
              return FilterChip(
                label: Text(labelFor(part)),
                selected: selected,
                onSelected: (_) => provider.togglePart(part),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Pain level', style: theme.textTheme.titleMedium),
          Row(
            children: [
              const Text('Mild'),
              Expanded(
                child: Slider(
                  value: provider.painScore.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '${provider.painScore}',
                  onChanged: (v) => provider.setPainScore(v.round()),
                ),
              ),
              const Text('Strong'),
            ],
          ),
          Text('${provider.painScore} out of 10', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: provider.selectedParts.isEmpty
                ? null
                : () => Navigator.pushNamed(context, AppRoutes.questions),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
