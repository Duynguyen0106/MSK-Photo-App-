import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import 'package:provider/provider.dart';

import '../providers/check_in_provider.dart';
import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  String _message = 'Building your summary…';

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    final provider = context.read<CheckInProvider>();
    provider.setAnalyzing(true);

    final poseService = PoseService();
    final storage = StorageService();

    try {
      if (provider.hasPhoto && provider.photoPaths.isNotEmpty) {
        if (mounted) {
          setState(() => _message = 'Detecting posture…');
        }

        for (final path in provider.photoPaths) {
          final result = await poseService.analyze(path, view: 'front');
          provider.setPoseResult('front', result);
        }

        if (mounted) {
          setState(() => _message = 'Building your summary…');
        }
        await Future.delayed(const Duration(milliseconds: 400));
      }

      final checkIn = provider.finalizeCheckIn();
      await storage.init();
      await storage.saveCheckIn(checkIn);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.result);
      }
    } finally {
      await poseService.dispose();
      provider.setAnalyzing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                _message,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Everything stays on your device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const DisclaimerBanner(compact: true, padding: EdgeInsets.zero),
            ],
          ),
        ),
      ),
    );
  }
}
