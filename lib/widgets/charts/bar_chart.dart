import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryBarChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final categories = data.keys.toList();
    final values = data.values.toList();
    final maxY = (values.isEmpty)
        ? 1.0
        : (values.reduce((a, b) => a > b ? a : b) * 1.2);

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (index, meta) {
                      final text = categories[index.toInt()];
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(text, style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              barGroups: List.generate(values.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i],
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
