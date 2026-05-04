import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Rep and set counter with increment/decrement controls
class RepCounterWidget extends StatelessWidget {
  final int currentReps;
  final int targetReps;
  final int currentSet;
  final int totalSets;
  final VoidCallback? onRepIncrement;
  final VoidCallback? onRepDecrement;

  const RepCounterWidget({
    super.key,
    required this.currentReps,
    required this.targetReps,
    required this.currentSet,
    required this.totalSets,
    this.onRepIncrement,
    this.onRepDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Set indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'fitness_center',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Set $currentSet of $totalSets',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Rep counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement button
              IconButton(
                onPressed: currentReps > 0
                    ? () {
                        HapticFeedback.lightImpact();
                        onRepDecrement?.call();
                      }
                    : null,
                icon: CustomIconWidget(
                  iconName: 'remove_circle_outline',
                  color: currentReps > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                  size: 32,
                ),
              ),

              SizedBox(width: 4.w),

              // Rep display
              Column(
                children: [
                  Text(
                    '$currentReps',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 40.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'of $targetReps reps',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 4.w),

              // Increment button
              IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onRepIncrement?.call();
                },
                icon: CustomIconWidget(
                  iconName: 'add_circle_outline',
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Progress indicator
          LinearProgressIndicator(
            value: currentReps / targetReps,
            backgroundColor: theme.colorScheme.primaryContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
