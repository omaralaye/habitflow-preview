import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class SettingItemWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? textColor;
  final bool isDestructive;

  const SettingItemWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.textColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isDestructive
        ? theme.colorScheme.error
        : (textColor ?? theme.colorScheme.onSurfaceVariant);
    final effectiveTextColor = isDestructive
        ? theme.colorScheme.error
        : (textColor ?? theme.colorScheme.onSurface);

    return InkWell(
      onTap: enabled && onTap != null
          ? () {
              HapticUtil.lightImpact();
              onTap!();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon
            CustomIconWidget(
              iconName: icon,
              color: enabled
                  ? effectiveColor
                  : effectiveColor.withValues(alpha: 0.4),
              size: 24,
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? effectiveTextColor
                          : effectiveTextColor.withValues(alpha: 0.4),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing widget or chevron
            if (trailing != null)
              trailing!
            else if (onTap != null)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: enabled
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
