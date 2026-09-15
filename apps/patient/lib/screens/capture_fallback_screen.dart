import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../services/analytics_service.dart';
import '../widgets/disclaimer_banner.dart';

class CaptureFallbackScreen extends StatelessWidget {
  const CaptureFallbackScreen({super.key});

  void _continueWithCaregiverPhoto(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.capture,
      arguments: const CaptureRouteArgs(caregiverMode: true),
    );
  }

  void _continueWithoutPhoto(BuildContext context) {
    final provider = context.read<CheckInProvider>();
    provider.setHasPhoto(false);
    provider.setUsedManualFallback(true);

    AnalyticsService.instance.logEvent('photo_skipped');
    Navigator.pushReplacementNamed(context, AppRoutes.analyzing);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('No problem')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DisclaimerBanner(padding: EdgeInsets.zero),
              const SizedBox(height: 28),
              Text(
                'No problem',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You can still do a symptom-only check-in. Your report will '
                'have fewer posture details, but it will still work.',
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _continueWithCaregiverPhoto(context),
                child: const Text('Someone else will take my photo'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _continueWithoutPhoto(context),
                child: const Text('Continue without photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route arguments for [CaptureScreen].
class CaptureRouteArgs {
  const CaptureRouteArgs({this.caregiverMode = false});

  final bool caregiverMode;
}
