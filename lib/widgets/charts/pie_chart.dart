import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final total = entries.fold<double>(0.0, (p, e) => p + e.value);

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (i) {
                final e = entries[i];
                final value = e.value;
                final percent = total <= 0 ? 0.0 : (value / total) * 100;
                return PieChartSectionData(
                  color: Colors.primaries[i % Colors.primaries.length],
                  value: value,
                  title: '${percent.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  radius: 50,
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 28,
            ),
          ),
        ),
      ),
    );
  }
}
