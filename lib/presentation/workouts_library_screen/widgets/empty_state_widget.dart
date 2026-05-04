import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget for no search results
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? suggestion;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.suggestion,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (suggestion != null) ...[
              SizedBox(height: 2.h),
              Text(
                suggestion!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onActionTap != null && actionLabel != null) ...[
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: onActionTap,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
