import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu'));
    }

    final total = data.values.fold(0.0, (a, b) => a + b);
    final entries = data.entries.toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: List.generate(entries.length, (i) {
                  final percentage = (entries[i].value / total * 100);
                  return PieChartSectionData(
                    color: AppConstants.chartColors[i % AppConstants.chartColors.length],
                    value: entries[i].value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 50,
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(entries.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppConstants.chartColors[i % AppConstants.chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entries[i].key,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class MonthlyBarChart extends StatelessWidget {
  final Map<int, Map<String, double>> data;
  final String title;

  const MonthlyBarChart({super.key, required this.data, this.title = ''});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.values.fold(0.0, (max, item) {
      final received = item['received'] ?? 0;
      final given = item['given'] ?? 0;
      final m = received > given ? received : given;
      return m > max ? m : max;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxVal * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = rodIndex == 0 ? 'Nhận' : 'Cho';
                    return BarTooltipItem(
                      '$label: ${Formatters.formatCompactCurrency(rod.toY)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'T${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        Formatters.formatCompactCurrency(value),
                        style: const TextStyle(fontSize: 9),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(12, (i) {
                final month = i + 1;
                final received = data[month]?['received'] ?? 0;
                final given = data[month]?['given'] ?? 0;
                return BarChartGroupData(
                  x: month,
                  barRods: [
                    BarChartRodData(
                      toY: received,
                      color: AppConstants.receivedGreen,
                      width: 8,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: given,
                      color: AppConstants.givenOrange,
                      width: 8,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(AppConstants.receivedGreen, 'Nhận'),
            const SizedBox(width: 16),
            _legendDot(AppConstants.givenOrange, 'Cho'),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
