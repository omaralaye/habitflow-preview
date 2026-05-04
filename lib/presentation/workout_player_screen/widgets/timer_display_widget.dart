import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Large timer display for workout tracking
class TimerDisplayWidget extends StatelessWidget {
  final String timeText;
  final String label;
  final bool isResting;

  const TimerDisplayWidget({
    super.key,
    required this.timeText,
    required this.label,
    this.isResting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isResting
            ? theme.colorScheme.tertiaryContainer
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isResting
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            timeText,
            style: theme.textTheme.displayLarge?.copyWith(
              color: isResting
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 48.sp,
            ),
          ),
        ],
      ),
    );
  }
}
