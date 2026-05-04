import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Today's goals with circular progress indicators
class TodayGoalsWidget extends StatelessWidget {
  final Map<String, dynamic> goals;

  const TodayGoalsWidget({
    super.key,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
            'Today\'s Goals',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGoalIndicator(
                context,
                'Active Minutes',
                goals['activeMinutes'] as int,
                goals['activeMinutesGoal'] as int,
                theme.colorScheme.primary,
                'schedule',
                theme,
              ),
              _buildGoalIndicator(
                context,
                'Calories',
                goals['calories'] as int,
                goals['caloriesGoal'] as int,
                theme.colorScheme.tertiary,
                'whatshot',
                theme,
              ),
              _buildGoalIndicator(
                context,
                'Workouts',
                goals['workouts'] as int,
                goals['workoutsGoal'] as int,
                theme.colorScheme.secondary,
                'fitness_center',
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalIndicator(
    BuildContext context,
    String label,
    int current,
    int goal,
    Color color,
    String iconName,
    ThemeData theme,
  ) {
    final progress = current / goal;

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 30,
          lineWidth: 5,
          percent: progress > 1.0 ? 1.0 : progress,
          center: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 24,
          ),
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        SizedBox(height: 1.h),
        Text(
          '$current/$goal',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
