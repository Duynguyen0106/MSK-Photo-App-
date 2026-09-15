import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/disclaimer_banner.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<CheckIn> _checkIns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _storage.init();
    final all = await _storage.getAllCheckIns();
    if (mounted) {
      setState(() {
        _checkIns = all;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PatientTabScaffold(
      currentIndex: 2,
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const DisclaimerBanner(),
                const SizedBox(height: 16),
                if (_checkIns.isEmpty)
                  Text(
                    'No check-ins yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ..._checkIns.map((c) => Card(
                        child: ListTile(
                          title: Text(
                            '${c.date.toLocal().toString().split(' ').first} — '
                            'Pain ${c.painScore}/10',
                          ),
                          subtitle: Text(
                            c.selectedParts.map(labelFor).join(', '),
                          ),
                        ),
                      )),
              ],
            ),
    );
  }
}
