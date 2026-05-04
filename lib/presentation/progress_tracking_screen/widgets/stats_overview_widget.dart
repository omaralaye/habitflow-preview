import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Stats overview widget displaying key metrics with circular progress indicators
class StatsOverviewWidget extends StatelessWidget {
  final int workoutsCompleted;
  final int activeMinutes;
  final int caloriesBurned;
  final double consistencyScore;

  const StatsOverviewWidget({
    super.key,
    required this.workoutsCompleted,
    required this.activeMinutes,
    required this.caloriesBurned,
    required this.consistencyScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context: context,
            label: 'Workouts',
            value: workoutsCompleted.toString(),
            progress: (workoutsCompleted / 7).clamp(0.0, 1.0),
            color: theme.colorScheme.primary,
          ),
          _buildStatItem(
            context: context,
            label: 'Minutes',
            value: activeMinutes.toString(),
            progress: (activeMinutes / 300).clamp(0.0, 1.0),
            color: theme.colorScheme.tertiary,
          ),
          _buildStatItem(
            context: context,
            label: 'Calories',
            value: caloriesBurned.toString(),
            progress: (caloriesBurned / 2000).clamp(0.0, 1.0),
            color: const Color(0xFF38A169),
          ),
          _buildStatItem(
            context: context,
            label: 'Consistency',
            value: '${(consistencyScore * 100).toInt()}%',
            progress: consistencyScore,
            color: const Color(0xFFED8936),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: 15.w,
          height: 15.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 15.w,
                height: 15.w,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
