import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

import '../routes.dart';
import '../theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/disclaimer_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.hivePath,
    this.initialCheckIns,
  });

  /// Optional Hive path for widget/integration tests.
  final String? hivePath;

  /// When set, skips [StorageService] load (widget tests).
  final List<CheckIn>? initialCheckIns;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  List<CheckIn> _checkIns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCheckIns != null) {
      _checkIns = List.of(widget.initialCheckIns!);
      _loading = false;
    } else {
      _loadCheckIns();
    }
  }

  Future<void> _loadCheckIns() async {
    try {
      await _storage.init(path: widget.hivePath);
      final all = await _storage.getAllCheckIns();
      if (mounted) {
        setState(() {
          _checkIns = all;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int? get _lastPainScore =>
      _checkIns.isNotEmpty ? _checkIns.first.painScore : null;

  _Trend _painTrend() {
    if (_checkIns.length < 2) return _Trend.steady;
    final latest = _checkIns[0].painScore;
    final previous = _checkIns[1].painScore;
    if (latest < previous) return _Trend.down;
    if (latest > previous) return _Trend.up;
    return _Trend.steady;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PatientTabScaffold(
      currentIndex: 0,
      body: RefreshIndicator(
        onRefresh: _loadCheckIns,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _GreetingHeader(greeting: _greeting()),
            const SizedBox(height: 16),
            const DisclaimerBanner(padding: EdgeInsets.zero),
            const SizedBox(height: 20),
            _HeroCard(
              onStart: () => Navigator.pushNamed(context, AppRoutes.painMap),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _StatsRow(
                count: _checkIns.length,
                lastPain: _lastPainScore,
                trend: _painTrend(),
              ),
              const SizedBox(height: 24),
              Text('Recent check-ins', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (_checkIns.isEmpty)
                _EmptyRecentState(
                  onStart: () =>
                      Navigator.pushNamed(context, AppRoutes.painMap),
                )
              else
                ..._checkIns.take(3).map((c) => _RecentCheckInTile(checkIn: c)),
            ],
          ],
        ),
      ),
    );
  }
}

enum _Trend { up, down, steady }

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.person_outline_rounded,
            color: theme.colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: theme.textTheme.headlineSmall),
              Text(
                'Welcome back',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PatientTheme.cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PatientTheme.seedColor,
            Color(0xFF1D4ED8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How is your body feeling?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record what you feel and capture your posture — all on your device.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: PatientTheme.seedColor,
            ),
            child: const Text('Start check-in →'),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.count,
    required this.lastPain,
    required this.trend,
  });

  final int count;
  final int? lastPain;
  final _Trend trend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Check-ins',
            value: '$count',
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Last pain',
            value: lastPain != null ? '$lastPain/10' : '—',
            icon: Icons.favorite_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Trend',
            value: _trendLabel(trend),
            icon: _trendIcon(trend),
            iconColor: _trendColor(context, trend),
          ),
        ),
      ],
    );
  }

  String _trendLabel(_Trend t) {
    switch (t) {
      case _Trend.up:
        return 'Higher';
      case _Trend.down:
        return 'Lower';
      case _Trend.steady:
        return 'Steady';
    }
  }

  IconData _trendIcon(_Trend t) {
    switch (t) {
      case _Trend.up:
        return Icons.trending_up_rounded;
      case _Trend.down:
        return Icons.trending_down_rounded;
      case _Trend.steady:
        return Icons.trending_flat_rounded;
    }
  }

  Color _trendColor(BuildContext context, _Trend t) {
    final scheme = Theme.of(context).colorScheme;
    switch (t) {
      case _Trend.up:
        return scheme.error;
      case _Trend.down:
        return Colors.green.shade700;
      case _Trend.steady:
        return scheme.onSurfaceVariant;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCheckInTile extends StatelessWidget {
  const _RecentCheckInTile({required this.checkIn});

  final CheckIn checkIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = checkIn.date.toLocal();
    final dateLabel =
        '${date.month}/${date.day}/${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            '${checkIn.painScore}',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text('Pain ${checkIn.painScore} out of 10'),
        subtitle: Text(
          '$dateLabel · ${checkIn.selectedParts.map(labelFor).join(', ')}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _EmptyRecentState extends StatelessWidget {
  const _EmptyRecentState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No check-ins yet. Start your first one.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onStart,
              child: const Text('Start check-in'),
            ),
          ],
        ),
      ),
    );
  }
}
