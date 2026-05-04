import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Filter bottom sheet with collapsible sections
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  bool _equipmentExpanded = true;
  bool _durationExpanded = true;
  bool _muscleGroupExpanded = true;
  bool _difficultyExpanded = true;

  final List<String> _equipmentOptions = [
    'None',
    'Dumbbells',
    'Mat',
    'Resistance Band',
    'Pull-up Bar',
  ];

  final List<String> _durationOptions = [
    '10-15 min',
    '15-30 min',
    '30-45 min',
    '45+ min',
  ];

  final List<String> _muscleGroupOptions = [
    'Full Body',
    'Upper Body',
    'Lower Body',
    'Core',
    'Cardio',
  ];

  final List<String> _difficultyOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 1.h),
          Container(
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters = {
                        'equipment': <String>[],
                        'duration': <String>[],
                        'muscleGroup': <String>[],
                        'difficulty': <String>[],
                      };
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.colorScheme.outline),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  _buildFilterSection(
                    context,
                    'Equipment',
                    _equipmentOptions,
                    'equipment',
                    _equipmentExpanded,
                    () => setState(
                        () => _equipmentExpanded = !_equipmentExpanded),
                  ),
                  _buildFilterSection(
                    context,
                    'Duration',
                    _durationOptions,
                    'duration',
                    _durationExpanded,
                    () =>
                        setState(() => _durationExpanded = !_durationExpanded),
                  ),
                  _buildFilterSection(
                    context,
                    'Muscle Group',
                    _muscleGroupOptions,
                    'muscleGroup',
                    _muscleGroupExpanded,
                    () => setState(
                        () => _muscleGroupExpanded = !_muscleGroupExpanded),
                  ),
                  _buildFilterSection(
                    context,
                    'Difficulty',
                    _difficultyOptions,
                    'difficulty',
                    _difficultyExpanded,
                    () => setState(
                        () => _difficultyExpanded = !_difficultyExpanded),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
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
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onApplyFilters(_filters);
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String title,
    List<String> options,
    String filterKey,
    bool isExpanded,
    VoidCallback onToggle,
  ) {
    final theme = Theme.of(context);
    final selectedOptions = (_filters[filterKey] as List<String>?) ?? [];

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomIconWidget(
                  iconName: isExpanded ? 'expand_less' : 'expand_more',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                    _filters[filterKey] = selectedOptions;
                  });
                  HapticFeedback.lightImpact();
                },
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary,
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 1,
                ),
              );
            }).toList(),
          ),
        Divider(color: theme.colorScheme.outline),
      ],
    );
  }
}
