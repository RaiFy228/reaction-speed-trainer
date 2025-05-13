// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/theme_provider.dart';

class ChartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialResults;
  final String exerciseName;

  const ChartScreen({
    super.key,
    required this.initialResults,
    required this.exerciseName,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late final List<Map<String, dynamic>> _sortedResults;
  final DateFormat _dateFormat = DateFormat('dd.MM');

  @override
  void initState() {
    super.initState();
    _sortedResults = _sortResults(widget.initialResults);
  }

  List<Map<String, dynamic>> _sortResults(List<Map<String, dynamic>> results) {
    final List<Map<String, dynamic>> sorted = List.from(results);
    sorted.sort((a, b) => DateTime.parse(a['CompletedAt'])
        .compareTo(DateTime.parse(b['CompletedAt'])));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final gridColor = themeProvider.isDarkMode 
        ? Colors.white.withOpacity(0.2) 
        : Colors.black.withOpacity(0.2);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sortedResults.isEmpty
            ? const Center(child: Text('Нет данных для отображения'))
            : Column(
                children: [
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: _calculateLeftInterval(),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: gridColor,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: _bottomTitles(textColor),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: _leftTitles(textColor),
                          ),
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: gridColor),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _prepareDataPoints(),
                            isCurved: true,
                            color: textColor,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 3,
                                color: textColor,
                                strokeWidth: 1,
                                strokeColor: Colors.transparent,
                              ),
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<FlSpot> _prepareDataPoints() {
    return _sortedResults.asMap().entries.map((entry) {
      final index = entry.key;
      final result = entry.value;
      return FlSpot(
        index.toDouble(),
        (result['AverageReactionTimeMs'] as num).toDouble(),
      );
    }).toList();
  }

  SideTitles _bottomTitles(Color textColor) => SideTitles(
        showTitles: true,
        interval: (_sortedResults.length / 5).ceilToDouble(),
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= _sortedResults.length) return const SizedBox();
          final date = DateTime.parse(_sortedResults[index]['CompletedAt']);
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _dateFormat.format(date),
              style: TextStyle(
                fontSize: 10,
                color: textColor,
              ),
            ),
          );
        },
      );

  SideTitles _leftTitles(Color textColor) => SideTitles(
        showTitles: true,
        interval: _calculateLeftInterval(),
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(
              '${value.toInt()}',
              style: TextStyle(
                fontSize: 12,
                color: textColor,
              ),
            ),
          );
        },
      );

  double _calculateLeftInterval() {
    final maxValue = _sortedResults
        .map((e) => (e['AverageReactionTimeMs'] as num).toDouble())
        .fold(0.0, (double max, double current) => current > max ? current : max);
    
    return (maxValue / 5).ceilToDouble();
  }
}