import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Workout card with swipe actions and tap navigation
class WorkoutCardWidget extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const WorkoutCardWidget({
    super.key,
    required this.workout,
    required this.onTap,
    required this.onFavorite,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(workout['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.lightImpact();
              onFavorite();
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.favorite_border_rounded,
            label: 'Favorite',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.lightImpact();
              onDownload();
            },
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.download_rounded,
            label: 'Download',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.lightImpact();
              onShare();
            },
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            icon: Icons.share_rounded,
            label: 'Share',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'workout_${workout['id']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageWidget(
                      imageUrl: workout['thumbnail'] as String,
                      width: 25.w,
                      height: 12.h,
                      fit: BoxFit.cover,
                      semanticLabel: workout['thumbnailLabel'] as String,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${workout['duration']} min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(
                                workout['difficulty'] as String,
                                theme,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              workout['difficulty'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getDifficultyColor(
                                  workout['difficulty'] as String,
                                  theme,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 0.5.h,
                        children: (workout['equipment'] as List<String>)
                            .map((equipment) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: _getEquipmentIcon(equipment),
                                  color: theme.colorScheme.onSecondaryContainer,
                                  size: 12,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  equipment,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'dumbbells':
        return 'fitness_center';
      case 'mat':
        return 'self_improvement';
      case 'resistance band':
        return 'sports_gymnastics';
      case 'none':
        return 'check_circle';
      default:
        return 'sports';
    }
  }
}
