import 'package:flutter/material.dart';
import '../models/onboarding.dart';

class OnboardingRepository {
  List<OnboardingPage> getPages() => const [
    OnboardingPage(
      icon: Icons.check_circle_rounded,
      title: 'Build Better Habits',
      subtitle: 'Track, measure, and improve your daily routines with simple yet powerful habit tracking.',
      colorValue: 0xFF00C896,
    ),
    OnboardingPage(
      icon: Icons.insights_rounded,
      title: 'Stay Motivated',
      subtitle: 'Earn streaks, unlock achievements, and get AI-powered insights to keep you going.',
      colorValue: 0xFF0EA5E9,
    ),
    OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: 'AI-Powered Coaching',
      subtitle: 'Get personalized recommendations and smart insights to optimize your habit journey.',
      colorValue: 0xFF7C3AED,
    ),
  ];

  List<GoalOption> getGoalOptions() => const [
    GoalOption(id: 'weight_loss', label: 'Weight Loss', icon: Icons.favorite_rounded),
    GoalOption(id: 'strength', label: 'Strength', icon: Icons.fitness_center_rounded),
    GoalOption(id: 'mindfulness', label: 'Mindfulness', icon: Icons.self_improvement_rounded),
    GoalOption(id: 'productivity', label: 'Productivity', icon: Icons.rocket_launch_rounded),
  ];

  List<HabitArea> getHabitAreas() => const [
    HabitArea(id: 'health', label: 'Health', icon: Icons.favorite_rounded),
    HabitArea(id: 'fitness', label: 'Fitness', icon: Icons.fitness_center_rounded),
    HabitArea(id: 'mindfulness', label: 'Mindfulness', icon: Icons.self_improvement_rounded),
    HabitArea(id: 'learning', label: 'Learning', icon: Icons.menu_book_rounded),
    HabitArea(id: 'productivity', label: 'Productivity', icon: Icons.rocket_launch_rounded),
    HabitArea(id: 'social', label: 'Social', icon: Icons.people_rounded),
    HabitArea(id: 'finance', label: 'Finance', icon: Icons.savings_rounded),
    HabitArea(id: 'sleep', label: 'Sleep', icon: Icons.bedtime_rounded),
  ];

  List<String> getReminderTimes() => const [
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '12:00 PM',
    '5:00 PM',
    '7:00 PM',
    '9:00 PM',
  ];
}
