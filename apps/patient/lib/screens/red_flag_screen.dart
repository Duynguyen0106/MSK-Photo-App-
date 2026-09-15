import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';

/// Urgent-care messaging when red flags are reported — not a diagnosis.
class RedFlagScreen extends StatelessWidget {
  const RedFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckInProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.error,
                  child: Icon(
                    Icons.priority_high_rounded,
                    size: 56,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Please seek urgent medical care',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                provider.escalationMessage,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'This app cannot assess emergencies. It has stopped your '
                    'check-in and will not produce a report.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.questions,
                ),
                child: const Text('← Go back and edit'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  provider.reset();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (r) => false,
                  );
                },
                child: const Text('I understand'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
