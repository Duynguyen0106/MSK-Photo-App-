import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

import '../routes.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/disclaimer_banner.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.initialCheckIns});

  /// When set (e.g. in widget tests), skips [StorageService] and uses this list.
  final List<CheckIn>? initialCheckIns;

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
    if (widget.initialCheckIns != null) {
      _checkIns = List.of(widget.initialCheckIns!);
      _loading = false;
    } else {
      _load();
    }
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

  List<CheckIn> get _chartCheckIns {
    final recent = _checkIns.take(6).toList();
    return recent.reversed.toList();
  }

  static Color painColor(int score) {
    if (score <= 3) return Colors.green.shade600;
    if (score <= 6) return Colors.amber.shade700;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PatientTabScaffold(
      currentIndex: 2,
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const DisclaimerBanner(),
                  const SizedBox(height: 20),
                  if (_checkIns.isEmpty)
                    Text(
                      'No check-ins yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else ...[
                    if (_chartCheckIns.length >= 2) ...[
                      Text(
                        'Pain over time',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _PainChart(checkIns: _chartCheckIns),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'All check-ins',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._checkIns.map(
                      (checkIn) => _CheckInListTile(
                        checkIn: checkIn,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.historyDetail,
                          arguments: checkIn,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _PainChart extends StatelessWidget {
  const _PainChart({required this.checkIns});

  final List<CheckIn> checkIns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = <FlSpot>[
      for (var i = 0; i < checkIns.length; i++)
        FlSpot(i.toDouble(), checkIns[i].painScore.toDouble()),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 10,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= checkIns.length) {
                        return const SizedBox.shrink();
                      }
                      final date = checkIns[index].date.toLocal();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${date.month}/${date.day}',
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) {
                      final score = checkIns[index].painScore;
                      return FlDotCirclePainter(
                        radius: 5,
                        color: _HistoryScreenState.painColor(score),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckInListTile extends StatelessWidget {
  const _CheckInListTile({
    required this.checkIn,
    required this.onTap,
  });

  final CheckIn checkIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = checkIn.date.toLocal();
    final dateLabel =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final color = _HistoryScreenState.painColor(checkIn.painScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            '${checkIn.painScore}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text('$dateLabel · Pain ${checkIn.painScore}/10'),
        subtitle: Text(
          checkIn.selectedParts.isEmpty
              ? 'Symptom check-in'
              : checkIn.selectedParts.map(labelFor).join(', '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
