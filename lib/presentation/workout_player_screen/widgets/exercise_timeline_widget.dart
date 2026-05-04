import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Timeline showing exercise sequence with current position
class ExerciseTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final int currentExerciseIndex;
  final VoidCallback? onExerciseTap;

  const ExerciseTimelineWidget({
    super.key,
    required this.exercises,
    required this.currentExerciseIndex,
    this.onExerciseTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 12.h,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          final isActive = index == currentExerciseIndex;
          final isCompleted = index < currentExerciseIndex;

          return Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Exercise indicator
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : isCompleted
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface,
                    border: Border.all(
                      color: isActive || isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: theme.colorScheme.primary,
                            size: 20,
                          )
                        : Text(
                            '${index + 1}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isActive
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 1.h),

                // Exercise name
                SizedBox(
                  width: 20.w,
                  child: Text(
                    exercise['name'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
