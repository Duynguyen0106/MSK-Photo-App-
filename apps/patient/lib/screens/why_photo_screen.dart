import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

import '../routes.dart';
import '../widgets/disclaimer_banner.dart';

class WhyPhotoScreen extends StatelessWidget {
  const WhyPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Why a photo?')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          Text(
            'A photo helps us record your posture on this device.',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            MskConstants.disclaimerPhoto,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'You can skip the photo and enter your details manually instead.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.capture),
            child: const Text('Take a photo'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.captureFallback),
            child: const Text('Enter details manually'),
          ),
        ],
      ),
    );
  }
}
