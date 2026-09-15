import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

import '../services/settings_preferences.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/disclaimer_banner.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = SettingsPreferences();
  final _storage = StorageService();
  bool _anonymousStats = false;
  bool _loading = true;

  static const _appVersion = '0.1.0';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await _prefs.anonymousStatsEnabled;
    if (mounted) {
      setState(() {
        _anonymousStats = stats;
        _loading = false;
      });
    }
  }

  Future<void> _toggleAnonymousStats(bool value) async {
    await _prefs.setAnonymousStatsEnabled(value);
    if (mounted) setState(() => _anonymousStats = value);
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all my data?'),
        content: const Text(
          'This will permanently remove all check-ins stored on this device. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _storage.init();
    await _storage.deleteAll();
    await _prefs.clearAll();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data deleted from this device.')),
    );
    setState(() => _anonymousStats = false);
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy policy'),
        content: const SingleChildScrollView(
          child: Text(
            'MSK Check-In processes photos and health information entirely on '
            'your device. We do not upload your photos, symptoms, or check-in '
            'history without your explicit consent.\n\n'
            'If you enable anonymous stats, only non-identifying usage counts '
            'may be shared to help improve the app. You can turn this off at '
            'any time.\n\n'
            'You can delete all stored data from Settings at any time.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PatientTabScaffold(
      currentIndex: 3,
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const DisclaimerBanner(),
                const SizedBox(height: 20),
                Text('Privacy', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('On-device processing'),
                        subtitle: const Text(
                          'Photos and analysis stay on your phone.',
                        ),
                        value: true,
                        onChanged: null,
                        secondary: const Icon(Icons.phonelink_lock_outlined),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Anonymous stats'),
                        subtitle: const Text(
                          'Share non-identifying usage counts to improve the app.',
                        ),
                        value: _anonymousStats,
                        onChanged: _toggleAnonymousStats,
                        secondary: const Icon(Icons.insights_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Data', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever_outlined,
                      color: theme.colorScheme.error,
                    ),
                    title: Text(
                      'Delete all my data',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    subtitle: const Text(
                      'Remove all check-ins from this device',
                    ),
                    onTap: _confirmDeleteAll,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Legal', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.gavel_outlined),
                        title: const Text('Disclaimers'),
                        subtitle: Text(
                          MskConstants.disclaimerShort,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Disclaimers'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(MskConstants.disclaimerFull),
                                  const SizedBox(height: 12),
                                  Text(MskConstants.disclaimerPhoto),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy policy'),
                        onTap: _showPrivacyPolicy,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Version $_appVersion',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
