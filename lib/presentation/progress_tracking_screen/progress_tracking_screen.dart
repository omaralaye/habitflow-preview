import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_settings.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

/// Progress Tracking Screen - Habit statistics and analytics
class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  String _selectedPeriod = 'Weekly';

  final Map<String, dynamic> _overallStats = {
    'currentStreak': 14,
    'longestStreak': 21,
    'totalCompleted': 287,
    'completionRate': 0.78,
    'activeHabits': 6,
    'perfectDays': 12,
  };

  final List<Map<String, dynamic>> _weeklyData = [
{'label': 'Mon', 'value': 5.0, 'total': 6.0},
{'label': 'Tue', 'value': 6.0, 'total': 6.0},
{'label': 'Wed', 'value': 4.0, 'total': 6.0},
{'label': 'Thu', 'value': 3.0, 'total': 6.0},
{'label': 'Fri', 'value': 6.0, 'total': 6.0},
{'label': 'Sat', 'value': 5.0, 'total': 6.0},
{'label': 'Sun', 'value': 2.0, 'total': 6.0},
];

  final List<Map<String, dynamic>> _monthlyData = [
{'label': 'W1', 'value': 4.2},
{'label': 'W2', 'value': 5.1},
{'label': 'W3', 'value': 3.8},
{'label': 'W4', 'value': 5.6},
];

  final List<Map<String, dynamic>> _habitBreakdown = [
{'name': 'Morning Meditation', 'icon': Icons.self_improvement_rounded, 'color': 0xFF7C3AED, 'rate': 0.93, 'streak': 14},
{'name': 'Drink Water', 'icon': Icons.water_drop_rounded, 'color': 0xFF0EA5E9, 'rate': 0.87, 'streak': 7},
{'name': 'Read 20 Pages', 'icon': Icons.menu_book_rounded, 'color': 0xFFED8936, 'rate': 0.71, 'streak': 5},
{'name': 'Evening Walk', 'icon': Icons.directions_walk_rounded, 'color': 0xFF00C896, 'rate': 0.64, 'streak': 10},
{'name': 'Gratitude Journal', 'icon': Icons.edit_note_rounded, 'color': 0xFFEC4899, 'rate': 0.57, 'streak': 3},
{'name': 'No Phone AM', 'icon': Icons.phone_disabled_rounded, 'color': 0xFF64748B, 'rate': 0.80, 'streak': 8},
];

  // Calendar data - days with completion status
  final Map<int, double> _calendarData = {
    1: 1.0, 2: 0.8, 3: 0.6, 4: 0.0, 5: 1.0,
    6: 1.0, 7: 0.5, 8: 1.0, 9: 0.9, 10: 0.7,
    11: 0.0, 12: 1.0, 13: 1.0, 14: 0.8, 15: 1.0,
    16: 0.6, 17: 0.9, 18: 1.0, 19: 0.4, 20: 1.0,
    21: 1.0, 22: 0.7, 23: 0.8, 24: 1.0, 25: 0.5,
    26: 1.0, 27: 0.9, 28: 1.0, 29: 0.6, 30: 0.8,
  };

  List<Map<String, dynamic>> get _currentChartData =>
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
                  '🔥 Current Streak: ${_overallStats['currentStreak']} days\n'
                  '🏆 Best Streak: ${_overallStats['longestStreak']} days\n'
                  '✅ Total Completed: ${_overallStats['totalCompleted']}\n'
                  '⭐ Completion Rate: ${((_overallStats['completionRate'] as double) * 100).toInt()}%\n'
                  '📊 Active Habits: ${_overallStats['activeHabits']}\n'
                  '💯 Perfect Days: ${_overallStats['perfectDays']}';
              SharePlus.instance.share(ShareParams(text: text));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
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
              '${_overallStats['currentStreak']}',
              'Current Streak',
              const Color(0xFFFF6B35),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              theme,
              '🏆',
              '${_overallStats['longestStreak']}',
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
              '${_overallStats['totalCompleted']}',
              'Total Done',
              theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              theme,
              '⭐',
              '${((_overallStats['completionRate'] as double) * 100).toInt()}%',
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              data[value.toInt()]['label'] as String,
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
                  final val = (item['value'] as num).toDouble();
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
    final monthName = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][now.month - 1];

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
                '$monthName ${now.year}',
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
            final color = Color(habit['color'] as int);
            final rate = habit['rate'] as double;
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
                    child: Icon(habit['icon'] as IconData, color: color, size: 18),
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
                                habit['name'] as String,
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
                                  '${habit['streak']}d',
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