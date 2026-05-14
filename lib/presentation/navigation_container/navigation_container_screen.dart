import 'package:flutter/material.dart';
import '../../core/app_settings.dart';

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

  void _onNavigate(String route) {
    if (_currentRoute == route) return;

    HapticUtil.lightImpact();
    setState(() {
      _currentRoute = route;
    });
  }

  Widget _buildScreen() {
    switch (_currentRoute) {
      case '/home-today-screen':
        return HomeTodayScreen(
          onSeeAllHabits: () => _onNavigate('/habits-library-screen'),
          onViewChallenge: () => _onNavigate('/challenges-screen'),
        );
      case '/habits-library-screen':
        return const WorkoutsLibraryScreen();
      case '/challenges-screen':
        return const ProgramsScreen();
      case '/progress-tracking-screen':
        return const ProgressTrackingScreen();
      case '/profile-settings-screen':
        return const ProfileSettingsScreen();
      default:
        return HomeTodayScreen(
          onSeeAllHabits: () => _onNavigate('/habits-library-screen'),
          onViewChallenge: () => _onNavigate('/challenges-screen'),
        );
    }
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
          child: _buildScreen(),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: _currentRoute,
        onNavigate: _onNavigate,
      ),
    );
  }
}
