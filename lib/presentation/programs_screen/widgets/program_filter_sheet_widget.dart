import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProgramFilterSheetWidget extends StatefulWidget {
  final String currentFilter;
  final Function(String) onFilterSelected;

  const ProgramFilterSheetWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  State<ProgramFilterSheetWidget> createState() =>
      _ProgramFilterSheetWidgetState();
}

class _ProgramFilterSheetWidgetState extends State<ProgramFilterSheetWidget> {
  late String _selectedFilter;

  final List<Map<String, dynamic>> _filterOptions = [
    {"label": "All Programs", "value": "All", "icon": "apps"},
    {"label": "Beginner", "value": "Beginner", "icon": "school"},
    {"label": "Intermediate", "value": "Intermediate", "icon": "trending_up"},
    {"label": "Advanced", "value": "Advanced", "icon": "military_tech"},
    {
      "label": "Short (< 4 weeks)",
      "value": "Short (< 4 weeks)",
      "icon": "timer"
    },
    {
      "label": "Medium (4-6 weeks)",
      "value": "Medium (4-6 weeks)",
      "icon": "schedule"
    },
    {"label": "Long (> 6 weeks)", "value": "Long (> 6 weeks)", "icon": "event"},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter Programs',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Filter Options
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final option = _filterOptions[index];
                  final isSelected = _selectedFilter == option["value"];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() =>
                              _selectedFilter = option["value"] as String);
                          widget.onFilterSelected(option["value"] as String);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: option["icon"] as String,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  option["label"] as String,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
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
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
