import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:msk_core/msk_core.dart';

/// Bar chart of recorded angle measurements.
class AngleChart extends StatelessWidget {
  const AngleChart({super.key, required this.angles});

  final List<AngleMeasurement> angles;

  @override
  Widget build(BuildContext context) {
    if (angles.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No angle data recorded')),
      );
    }

    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: angles.map((a) => a.degrees).reduce((a, b) => a > b ? a : b) + 20,
          barGroups: List.generate(angles.length, (i) {
            final angle = angles[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: angle.degrees,
                  color: theme.colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= angles.length) return const SizedBox();
                  final label = angles[idx].label.replaceAll('_', '\n');
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(label, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) =>
                    Text('${value.toInt()}°', style: theme.textTheme.labelSmall),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
