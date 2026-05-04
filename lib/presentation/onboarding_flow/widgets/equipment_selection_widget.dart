import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EquipmentSelectionWidget extends StatelessWidget {
  final List<String> selectedEquipment;
  final Function(List<String>) onEquipmentChanged;

  const EquipmentSelectionWidget({
    super.key,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
  });

  final List<Map<String, dynamic>> _equipmentOptions = const [
    {
      'key': 'bodyweight',
      'title': 'Bodyweight Only',
      'icon': '🤸',
      'description': 'No equipment needed',
    },
    {
      'key': 'dumbbells',
      'title': 'Dumbbells',
      'icon': '🏋️',
      'description': 'Light to heavy weights',
    },
    {
      'key': 'resistance_bands',
      'title': 'Resistance Bands',
      'icon': '🎯',
      'description': 'Portable strength training',
    },
    {
      'key': 'yoga_mat',
      'title': 'Yoga Mat',
      'icon': '🧘',
      'description': 'For floor exercises',
    },
    {
      'key': 'kettlebell',
      'title': 'Kettlebell',
      'icon': '⚖️',
      'description': 'Dynamic movements',
    },
    {
      'key': 'pull_up_bar',
      'title': 'Pull-up Bar',
      'icon': '🎪',
      'description': 'Upper body strength',
    },
  ];

  void _toggleEquipment(String key) {
    HapticFeedback.selectionClick();

    final newSelection = List<String>.from(selectedEquipment);

    if (newSelection.contains(key)) {
      newSelection.remove(key);
    } else {
      newSelection.add(key);
    }

    onEquipmentChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What equipment do you have?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select all that apply - we\'ll customize your workouts',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: _equipmentOptions.length,
            itemBuilder: (context, index) {
              final equipment = _equipmentOptions[index];
              return _buildEquipmentCard(
                context: context,
                theme: theme,
                equipment: equipment,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard({
    required BuildContext context,
    required ThemeData theme,
    required Map<String, dynamic> equipment,
  }) {
    final isSelected = selectedEquipment.contains(equipment['key']);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleEquipment(equipment['key'] as String),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    equipment['icon'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                equipment['title'] as String,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                equipment['description'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.8)
                      : theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
