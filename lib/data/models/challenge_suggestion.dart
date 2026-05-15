import 'package:flutter/material.dart';

class ChallengeSuggestion {
  final String title;
  final String description;
  final int durationDays;
  final String difficulty;
  final String category;
  final String dailyTask;

  const ChallengeSuggestion({
    required this.title,
    required this.description,
    required this.durationDays,
    required this.difficulty,
    required this.category,
    this.dailyTask = '',
  });

  factory ChallengeSuggestion.fromJson(Map<String, dynamic> json) {
    return ChallengeSuggestion(
      title: json['title'] as String? ?? 'New Challenge',
      description: json['description'] as String? ?? '',
      durationDays: json['durationDays'] as int? ?? 7,
      difficulty: json['difficulty'] as String? ?? 'Easy',
      category: json['category'] as String? ?? 'Other',
      dailyTask: json['dailyTask'] as String? ?? '',
    );
  }

  IconData get icon {
    switch (category) {
      case 'Health': return Icons.favorite_rounded;
      case 'Fitness': return Icons.fitness_center_rounded;
      case 'Mindfulness': return Icons.self_improvement_rounded;
      case 'Learning': return Icons.menu_book_rounded;
      case 'Productivity': return Icons.rocket_launch_rounded;
      case 'Social': return Icons.people_rounded;
      case 'Finance': return Icons.savings_rounded;
      case 'Sleep': return Icons.bedtime_rounded;
      default: return Icons.emoji_events_rounded;
    }
  }

  int get colorValue {
    switch (category) {
      case 'Health': return 0xFFFF6B6B;
      case 'Fitness': return 0xFF00C896;
      case 'Mindfulness': return 0xFF7C3AED;
      case 'Learning': return 0xFFED8936;
      case 'Productivity': return 0xFF0EA5E9;
      case 'Social': return 0xFFEC4899;
      case 'Finance': return 0xFF38A169;
      case 'Sleep': return 0xFF6366F1;
      default: return 0xFF64748B;
    }
  }

  String get durationLabel => '$durationDays days';
}
