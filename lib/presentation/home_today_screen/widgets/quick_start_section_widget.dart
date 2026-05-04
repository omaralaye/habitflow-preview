import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Quick start workout cards filtered by duration
class QuickStartSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> quickWorkouts;
  final Function(Map<String, dynamic>) onWorkoutTap;

  const QuickStartSectionWidget({
    super.key,
    required this.quickWorkouts,
    required this.onWorkoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            'Quick Start',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: quickWorkouts.length,
            itemBuilder: (context, index) {
              final workout = quickWorkouts[index];
              return _buildQuickWorkoutCard(context, workout, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickWorkoutCard(
    BuildContext context,
    Map<String, dynamic> workout,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onWorkoutTap(workout);
      },
      child: Container(
        width: 35.w,
        margin: EdgeInsets.only(right: 3.w),
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
            // Workout thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CustomImageWidget(
                imageUrl: workout['thumbnail'] as String,
                width: double.infinity,
                height: 12.h,
                fit: BoxFit.cover,
                semanticLabel: workout['semanticLabel'] as String,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout['title'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${workout['duration']} min',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
