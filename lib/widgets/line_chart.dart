import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class LineChartWidget extends StatelessWidget {
  final Map<String, double> monthlyExpenses;
  final Map<String, double> monthlyIncome;
  final String title;

  const LineChartWidget({
    super.key,
    required this.monthlyExpenses,
    required this.monthlyIncome,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final expenseSpots = <FlSpot>[];
    final incomeSpots = <FlSpot>[];
    final labels = monthlyExpenses.keys.toList();

    for (var i = 0; i < labels.length; i++) {
      final key = labels[i];
      expenseSpots.add(FlSpot(i.toDouble(), monthlyExpenses[key] ?? 0));
      incomeSpots.add(FlSpot(i.toDouble(), monthlyIncome[key] ?? 0));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  color: AppColors.expense,
                  isCurved: true,
                  spots: expenseSpots,
                ),
                if (monthlyIncome.isNotEmpty)
                  LineChartBarData(
                    color: AppColors.income,
                    isCurved: true,
                    spots: incomeSpots,
                  ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < labels.length) {
                        return Text(labels[index], style: const TextStyle(fontSize: 10));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
