import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/disclaimer_banner.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PatientTabScaffold(
      currentIndex: 3,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    MskConstants.disclaimerFull,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    MskConstants.disclaimerPhoto,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
