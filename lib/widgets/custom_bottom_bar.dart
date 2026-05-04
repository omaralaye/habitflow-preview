import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item configuration for the bottom bar
class CustomBottomBarItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const CustomBottomBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Custom bottom navigation bar for HabitFlow
class CustomBottomBar extends StatelessWidget {
  final String currentRoute;
  final Function(String route)? onNavigate;
  final double elevation;
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentRoute,
    this.onNavigate,
    this.elevation = 8.0,
    this.showLabels = true,
  });

  static const List<CustomBottomBarItem> _navigationItems = [
    CustomBottomBarItem(
      label: 'Today',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: '/home-today-screen',
    ),
    CustomBottomBarItem(
      label: 'Habits',
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist_rounded,
      route: '/habits-library-screen',
    ),
    CustomBottomBarItem(
      label: 'Challenges',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      route: '/challenges-screen',
    ),
    CustomBottomBarItem(
      label: 'Progress',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      route: '/progress-tracking-screen',
    ),
    CustomBottomBarItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: '/profile-settings-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.map((item) {
              final isActive = currentRoute == item.route;
              return _buildNavigationItem(
                context: context,
                item: item,
                isActive: isActive,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required CustomBottomBarItem item,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(context, item.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey(isActive),
                    color: color,
                    size: 24,
                  ),
                ),
                if (showLabels) ...[
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: color,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 10,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    HapticFeedback.lightImpact();
    if (currentRoute == route) return;
    if (onNavigate != null) {
      onNavigate!(route);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}
