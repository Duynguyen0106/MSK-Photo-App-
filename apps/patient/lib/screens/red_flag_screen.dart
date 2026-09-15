import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

/// Urgent-care messaging when red flags are reported — not a diagnosis.
class RedFlagScreen extends StatelessWidget {
  const RedFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Please seek care')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DisclaimerBanner(padding: EdgeInsets.zero),
            const SizedBox(height: 24),
            Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              provider.escalationMessage,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                provider.reset();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (r) => false,
                );
              },
              child: const Text('Return home'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.whyPhoto),
              child: const Text('Continue check-in anyway'),
            ),
          ],
        ),
      ),
    );
  }
}
