import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_export.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/models/progress_stats.dart';

/// Progress Tracking Screen - Habit statistics and analytics
class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();
  String _selectedPeriod = 'Weekly';

  static const _fullMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  OverallStats? _overallStats;
  List<WeeklyDataPoint> _weeklyData = [];
  List<MonthlyDataPoint> _monthlyData = [];
  List<HabitBreakdown> _habitBreakdown = [];
  Map<int, double> _calendarData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _overallStats = _progressRepository.getOverallStats();
      _weeklyData = _progressRepository.getWeeklyData();
      _monthlyData = _progressRepository.getMonthlyData();
      _habitBreakdown = _progressRepository.getHabitBreakdown();
      _calendarData = _progressRepository.getCalendarData();
    });
  }

  List<dynamic> get _currentChartData =>
      _selectedPeriod == 'Weekly' ? _weeklyData : _monthlyData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Progress',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.colorScheme.onSurface),
            onPressed: () {
              HapticUtil.lightImpact();
              final text = 'My FlowFit Progress:\n'
                  '🔥 Current Streak: ${_overallStats?.currentStreak ?? 0} days\n'
                  '🏆 Best Streak: ${_overallStats?.longestStreak ?? 0} days\n'
                  '✅ Total Completed: ${_overallStats?.totalCompleted ?? 0}\n'
                  '⭐ Completion Rate: ${((_overallStats?.completionRate ?? 0) * 100).toInt()}%\n'
                  '📊 Active Habits: ${_overallStats?.activeHabits ?? 0}\n'
                  '💯 Perfect Days: ${_overallStats?.perfectDays ?? 0}';
              SharePlus.instance.share(ShareParams(text: text));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsOverview(theme),
              SizedBox(height: 2.h),
              _buildPeriodSelector(theme),
              SizedBox(height: 2.h),
              _buildCompletionChart(theme),
              SizedBox(height: 2.h),
              _buildCalendarHeatmap(theme),
              SizedBox(height: 2.h),
              _buildHabitBreakdown(theme),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              theme,
              '🔥',
              '${_overallStats?.currentStreak ?? 0}',
              'Current Streak',
              const Color(0xFFFF6B35),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              theme,
              '🏆',
              '${_overallStats?.longestStreak ?? 0}',
              'Best Streak',
              const Color(0xFFFBBF24),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              theme,
              '✅',
              '${_overallStats?.totalCompleted ?? 0}',
              'Total Done',
              theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              theme,
              '⭐',
              '${((_overallStats?.completionRate ?? 0) * 100).toInt()}%',
              'Completion Rate',
              const Color(0xFF7C3AED),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Row(
      children: ['Weekly', 'Monthly'].map((period) {
        final isSelected = _selectedPeriod == period;
        return GestureDetector(
          onTap: () {
            HapticUtil.lightImpact();
            setState(() => _selectedPeriod = period);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              period,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompletionChart(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Completion',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final data = _currentChartData;
                        if (value.toInt() < data.length) {
                          final item = data[value.toInt()];
                          String label;
                          if (item is WeeklyDataPoint) {
                            label = item.label;
                          } else if (item is MonthlyDataPoint) {
                            label = item.label;
                          } else {
                            label = '';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_currentChartData.length, (index) {
                  final item = _currentChartData[index];
                  double val;
                  if (item is WeeklyDataPoint) {
                    val = item.value;
                  } else if (item is MonthlyDataPoint) {
                    val = item.value;
                  } else {
                    val = 0;
                  }
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        color: theme.colorScheme.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 6,
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap(ThemeData theme) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_fullMonths[now.month - 1]} ${now.year}',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(theme.colorScheme.primaryContainer, 'Low'),
                  const SizedBox(width: 8),
                  _buildLegendDot(theme.colorScheme.primary.withValues(alpha: 0.5), 'Mid'),
                  const SizedBox(width: 8),
                  _buildLegendDot(theme.colorScheme.primary, 'Full'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => Text(
              d,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final rate = _calendarData[day] ?? 0.0;
              Color cellColor;
              if (rate == 0) {
                cellColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
              } else if (rate < 0.5) {
                cellColor = theme.colorScheme.primary.withValues(alpha: 0.25);
              } else if (rate < 1.0) {
                cellColor = theme.colorScheme.primary.withValues(alpha: 0.6);
              } else {
                cellColor = theme.colorScheme.primary;
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: rate >= 0.5 ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF718096)),
        ),
      ],
    );
  }

  Widget _buildHabitBreakdown(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Breakdown',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ..._habitBreakdown.map((habit) {
            final color = Color(habit.colorValue);
            final rate = habit.rate;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.check_circle_rounded, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                habit.name,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded,
                                    size: 13, color: Color(0xFFFF6B35)),
                                const SizedBox(width: 2),
                                Text(
                                  '${habit.streak}d',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(rate * 100).toInt()}%',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rate,
                            backgroundColor: color.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
