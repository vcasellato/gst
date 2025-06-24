import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> expensesByCategory;
  const ExpenseChart({super.key, required this.expensesByCategory});

  @override
  Widget build(BuildContext context) {
    final total = expensesByCategory.values.fold(0.0, (a, b) => a + b);
    final sections = <PieChartSectionData>[];
    int i = 0;
    expensesByCategory.forEach((category, value) {
      final color = AppColors.chartColors[i % AppColors.chartColors.length];
      final percent = total == 0 ? 0 : value / total * 100;
      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          radius: 50,
          title: '${percent.toStringAsFixed(1)}%',
        ),
      );
      i++;
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
