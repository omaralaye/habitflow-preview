import 'package:flutter/material.dart';

class HabitCategory {
  final String label;
  final IconData icon;
  final int colorValue;

  const HabitCategory({
    required this.label,
    required this.icon,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}

class FrequencyOption {
  final String label;
  final IconData icon;
  final String description;

  const FrequencyOption({
    required this.label,
    required this.icon,
    required this.description,
  });
}
