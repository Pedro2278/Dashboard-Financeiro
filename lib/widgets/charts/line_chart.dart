import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimeSeriesLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> series;

  const TimeSeriesLineChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < series.length; i++) {
      final value = (series[i]['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    return AspectRatio(
      aspectRatio: 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LineChart(
            LineChartData(
              minY: spots.isEmpty
                  ? 0
                  : spots
                            .map((s) => s.y)
                            .fold<double>(
                              double.infinity,
                              (a, b) => a < b ? a : b,
                            ) -
                        10,
              maxY: spots.isEmpty
                  ? 1
                  : spots
                            .map((s) => s.y)
                            .fold<double>(
                              double.negativeInfinity,
                              (a, b) => a > b ? a : b,
                            ) +
                        10,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= series.length) {
                        return const SizedBox.shrink();
                      }
                      final label = (series[idx]['date'] as String)
                          .split('-')
                          .last;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(label),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
