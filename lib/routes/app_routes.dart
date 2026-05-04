import 'package:flutter/material.dart';

import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/navigation_container/navigation_container_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/add_habit_screen/add_habit_screen.dart';
import '../presentation/edit_habit_screen/edit_habit_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';

/// Application routes configuration
class AppRoutes {
  // Route constants
  static const String initial = splashScreen;
  static const String splashScreen = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String navigationContainer = '/navigation-container';
  static const String homeTodayScreen = '/home-today-screen';
  static const String habitsLibraryScreen = '/habits-library-screen';
  static const String challengesScreen = '/challenges-screen';
  static const String progressTrackingScreen = '/progress-tracking-screen';
  static const String profileSettingsScreen = '/profile-settings-screen';
  static const String addHabitScreen = '/add-habit-screen';
  static const String editHabitScreen = '/edit-habit-screen';
  static const String notificationsScreen = '/notifications-screen';

  /// Routes map
  static Map<String, WidgetBuilder> get routes => {
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    navigationContainer: (context) => const NavigationContainerScreen(),
    addHabitScreen: (context) => const AddHabitScreen(),
    editHabitScreen: (context) => const EditHabitScreen(),
    notificationsScreen: (context) => const NotificationsScreen(),
  };
}
