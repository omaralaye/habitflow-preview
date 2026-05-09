import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgramDetailOverlayWidget extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onStartProgram;
  final VoidCallback onClose;

  const ProgramDetailOverlayWidget({
    super.key,
    required this.program,
    required this.onStartProgram,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image
                  Stack(
                    children: [
                      CustomImageWidget(
                        imageUrl: program["coverImage"] as String,
                        width: double.infinity,
                        height: 30.h,
                        fit: BoxFit.cover,
                        semanticLabel: program["semanticLabel"] as String,
                      ),
                      Positioned(
                        top: 2.h,
                        right: 4.w,
                        child: IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          onPressed: onClose,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          program["title"] as String,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Stats Row
                        Row(
                          children: [
                            _buildStatChip(
                              context,
                              icon: 'schedule',
                              label: program["duration"] as String,
                            ),
                            SizedBox(width: 2.w),
                            _buildStatChip(
                              context,
                              icon: 'trending_up',
                              label: program["difficulty"] as String,
                            ),
                            SizedBox(width: 2.w),
                            _buildStatChip(
                              context,
                              icon: 'star',
                              label: '${program["rating"]}',
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Description
                        Text(
                          'About This Program',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          program["description"] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Weekly Breakdown
                        Text(
                          'Weekly Breakdown',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        ...(program["weeklyBreakdown"] as List).map((week) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 0.5.h),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    week as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        SizedBox(height: 3.h),

                        // Requirements
                        Text(
                          'Requirements',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        ...(program["requirements"] as List).map((req) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    req as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        SizedBox(height: 3.h),

                        // Equipment
                        Text(
                          'Equipment Needed',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children:
                              (program["equipment"] as List).map((equipment) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'fitness_center',
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                    size: 16,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    equipment as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 3.h),

                        // Trainer
                        Text(
                          'Your Trainer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 8.w,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: CustomIconWidget(
                                iconName: 'person',
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    program["trainer"] as String,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Certified Fitness Trainer',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Start Button
          Container(
            padding: EdgeInsets.all(4.w),
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
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticUtil.mediumImpact();
                    onStartProgram();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Start Program',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatChip(BuildContext context,
      {required String icon, required String label}) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.onSecondaryContainer,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
