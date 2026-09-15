import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/body_map.dart';
import '../widgets/disclaimer_banner.dart';

class PainMapScreen extends StatelessWidget {
  const PainMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Where does it hurt?')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DisclaimerBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              'Tap where it hurts. You can pick more than one.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Center(
                child: BodyMapView(
                  selected: provider.selectedParts.toSet(),
                  onPartTapped: provider.togglePart,
                ),
              ),
            ),
          ),
          if (provider.selectedParts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.selectedParts.map((part) {
                  return InputChip(
                    label: Text(labelFor(part)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => provider.removePart(part),
                  );
                }).toList(),
              ),
            ),
          SafeArea(
            minimum: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: provider.selectedParts.isEmpty
                  ? null
                  : () => Navigator.pushNamed(context, AppRoutes.questions),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
