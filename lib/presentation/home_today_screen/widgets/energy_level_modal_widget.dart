import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Energy level input modal for personalized recommendations
class EnergyLevelModalWidget extends StatefulWidget {
  final Function(String) onEnergySelected;

  const EnergyLevelModalWidget({
    super.key,
    required this.onEnergySelected,
  });

  @override
  State<EnergyLevelModalWidget> createState() => _EnergyLevelModalWidgetState();
}

class _EnergyLevelModalWidgetState extends State<EnergyLevelModalWidget> {
  String? selectedEnergy;

  final List<Map<String, dynamic>> energyLevels = [
    {
      'level': 'Low',
      'icon': 'battery_2_bar',
      'description': 'Light stretching or yoga',
      'color': const Color(0xFFED8936),
    },
    {
      'level': 'Medium',
      'icon': 'battery_5_bar',
      'description': 'Moderate intensity workout',
      'color': const Color(0xFF00C896),
    },
    {
      'level': 'High',
      'icon': 'battery_full',
      'description': 'High intensity training',
      'color': const Color(0xFF38A169),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          Text(
            'How\'s your energy today?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            'We\'ll recommend workouts that match your energy level',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 3.h),

          // Energy level options
          ...energyLevels.map((energy) => _buildEnergyOption(energy, theme)),

          SizedBox(height: 2.h),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: selectedEnergy != null
                  ? () {
                      HapticFeedback.mediumImpact();
                      widget.onEnergySelected(selectedEnergy!);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Update Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildEnergyOption(Map<String, dynamic> energy, ThemeData theme) {
    final isSelected = selectedEnergy == energy['level'];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          selectedEnergy = energy['level'] as String;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: (energy['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: energy['icon'] as String,
                color: energy['color'] as Color,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    energy['level'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    energy['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
