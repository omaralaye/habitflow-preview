import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class IntegrationCardWidget extends StatelessWidget {
  final String name;
  final String icon;
  final bool isConnected;
  final String? lastSync;
  final Function(bool) onToggle;
  final VoidCallback? onSync;

  const IntegrationCardWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.isConnected,
    this.lastSync,
    required this.onToggle,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      enabled: isConnected,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (onSync != null) {
                HapticFeedback.mediumImpact();
                onSync!();
              }
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.sync,
            label: 'Sync',
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(16)),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isConnected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (lastSync != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      isConnected ? "Last sync: $lastSync" : "Not connected",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Toggle
            Switch(
              value: isConnected,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}
