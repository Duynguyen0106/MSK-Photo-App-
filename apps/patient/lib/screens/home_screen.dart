import 'package:flutter/material.dart';

import '../routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/disclaimer_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PatientTabScaffold(
      currentIndex: 0,
      appBar: AppBar(title: const Text('MSK Check-In')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 24),
          Text(
            'How are you feeling today?',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Record how you feel and capture your posture — all on your device.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.painMap),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start a check-in'),
          ),
        ],
      ),
    );
  }
}
