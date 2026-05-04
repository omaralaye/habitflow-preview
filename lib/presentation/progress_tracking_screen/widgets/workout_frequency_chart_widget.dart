import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

/// Interactive line chart showing workout frequency
class WorkoutFrequencyChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final String period;

  const WorkoutFrequencyChartWidget({
    super.key,
    required this.chartData,
    required this.period,
  });

  /// Calculate dynamic max Y value based on data
  double _calculateMaxY() {
    if (chartData.isEmpty) return 5.0;

    final maxValue = chartData
        .map((data) => (data['value'] as num).toDouble())
        .reduce((a, b) => math.max(a, b));

    // Add 20% padding to the max value for better visualization
    final paddedMax = maxValue * 1.2;

    // Round up to the nearest nice number
    if (paddedMax <= 5) return 5.0;
    if (paddedMax <= 10) return 10.0;
    if (paddedMax <= 20) return 20.0;
    if (paddedMax <= 30) return 30.0;
    if (paddedMax <= 40) return 40.0;
    if (paddedMax <= 50) return 50.0;

    // For values above 50, round to nearest 10
    return ((paddedMax / 10).ceil() * 10).toDouble();
  }

  /// Calculate appropriate interval for Y axis based on max value
  double _calculateYInterval() {
    final maxY = _calculateMaxY();

    if (maxY <= 5) return 1.0;
    if (maxY <= 10) return 2.0;
    if (maxY <= 20) return 4.0;
    if (maxY <= 30) return 5.0;
    if (maxY <= 50) return 10.0;

    // For larger values, use appropriate intervals
    return (maxY / 5).roundToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = _calculateMaxY();
    final yInterval = _calculateYInterval();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Frequency',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 25.h,
            child: Semantics(
              label: 'Workout Frequency Line Chart',
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < chartData.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Text(
                                chartData[value.toInt()]['label'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (chartData.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['value'] as num).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < chartData.length) {
                            return LineTooltipItem(
                              '${chartData[index]['label']}\n${spot.y.toInt()} workouts',
                              theme.textTheme.bodySmall!.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
