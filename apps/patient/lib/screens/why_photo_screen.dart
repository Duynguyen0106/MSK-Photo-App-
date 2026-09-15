import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../routes.dart';
import '../services/analytics_service.dart';
import '../widgets/disclaimer_banner.dart';

class WhyPhotoScreen extends StatefulWidget {
  const WhyPhotoScreen({super.key});

  @override
  State<WhyPhotoScreen> createState() => _WhyPhotoScreenState();
}

class _WhyPhotoScreenState extends State<WhyPhotoScreen> {
  bool _requestingPermission = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logEvent('why_photo_shown');
  }

  Future<void> _takePhoto() async {
    setState(() => _requestingPermission = true);

    final status = await Permission.camera.request();

    if (!mounted) return;
    setState(() => _requestingPermission = false);

    if (status.isGranted) {
      Navigator.pushNamed(context, AppRoutes.capture);
      return;
    }

    final message = status.isPermanentlyDenied
        ? 'Camera access is blocked. Enable it in Settings or use manual entry.'
        : 'Camera permission is needed to take a photo.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const DisclaimerBanner(padding: EdgeInsets.zero),
                  const SizedBox(height: 28),
                  Text(
                    'One quick photo',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your posture tells us things your words can\'t. It takes '
                    '20 seconds, stays on your phone, and makes your report '
                    'twice as useful.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  _IconRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Stand naturally',
                  ),
                  const SizedBox(height: 16),
                  _IconRow(
                    icon: Icons.straighten_rounded,
                    label: 'We measure alignment',
                  ),
                  const SizedBox(height: 16),
                  _IconRow(
                    icon: Icons.phonelink_lock_rounded,
                    label: 'Stays on your device',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: FilledButton(
                onPressed: _requestingPermission ? null : _takePhoto,
                child: _requestingPermission
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Take my photo'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.captureFallback),
                style: TextButton.styleFrom(
                  textStyle: theme.textTheme.bodySmall,
                ),
                child: const Text('I can\'t take a photo right now'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
