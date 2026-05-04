import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/custom_bottom_bar.dart';
import '../home_today_screen/home_today_screen.dart';
import '../workouts_library_screen/workouts_library_screen.dart';
import '../programs_screen/programs_screen.dart';
import '../progress_tracking_screen/progress_tracking_screen.dart';
import '../profile_settings_screen/profile_settings_screen.dart';

/// Navigation container for HabitFlow
class NavigationContainerScreen extends StatefulWidget {
  const NavigationContainerScreen({super.key});

  @override
  State<NavigationContainerScreen> createState() =>
      _NavigationContainerScreenState();
}

class _NavigationContainerScreenState extends State<NavigationContainerScreen> {
  String _currentRoute = '/home-today-screen';

  final Map<String, Widget> _screens = const {
    '/home-today-screen': HomeTodayScreen(),
    '/habits-library-screen': WorkoutsLibraryScreen(),
    '/challenges-screen': ProgramsScreen(),
    '/progress-tracking-screen': ProgressTrackingScreen(),
    '/profile-settings-screen': ProfileSettingsScreen(),
  };

  void _onNavigate(String route) {
    if (_currentRoute == route) return;

    HapticFeedback.lightImpact();
    setState(() {
      _currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(_currentRoute),
          child: _screens[_currentRoute] ?? _screens['/home-today-screen']!,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: _currentRoute,
        onNavigate: _onNavigate,
      ),
    );
  }
}
