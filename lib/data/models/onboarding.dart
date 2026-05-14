import 'package:flutter/material.dart';

class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final int colorValue;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}

class GoalOption {
  final String id;
  final String label;
  final IconData icon;

  const GoalOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class HabitArea {
  final String id;
  final String label;
  final IconData icon;

  const HabitArea({
    required this.id,
    required this.label,
    required this.icon,
  });
}
