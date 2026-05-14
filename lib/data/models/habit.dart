import 'package:flutter/material.dart';

class Habit {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final int colorValue;
  final String category;
  final String duration;
  final String difficulty;
  final double popularity;
  final String users;
  final bool isAdded;
  final bool isCompleted;
  final int streak;
  final bool isChallenge;
  final int? challengeId;

  const Habit({
    required this.id,
    required this.title,
    this.description = '',
    required this.icon,
    required this.colorValue,
    required this.category,
    required this.duration,
    this.difficulty = 'Easy',
    this.popularity = 0,
    this.users = '',
    this.isAdded = false,
    this.isCompleted = false,
    this.streak = 0,
    this.isChallenge = false,
    this.challengeId,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon.codePoint,
        'color': colorValue,
        'category': category,
        'duration': duration,
        'isCompleted': isCompleted,
        'streak': streak,
        'isChallenge': isChallenge,
        'challengeId': challengeId,
      };

  Habit copyWith({
    int? id,
    String? title,
    String? description,
    IconData? icon,
    int? colorValue,
    String? category,
    String? duration,
    String? difficulty,
    double? popularity,
    String? users,
    bool? isAdded,
    bool? isCompleted,
    int? streak,
    bool? isChallenge,
    int? challengeId,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      popularity: popularity ?? this.popularity,
      users: users ?? this.users,
      isAdded: isAdded ?? this.isAdded,
      isCompleted: isCompleted ?? this.isCompleted,
      streak: streak ?? this.streak,
      isChallenge: isChallenge ?? this.isChallenge,
      challengeId: challengeId ?? this.challengeId,
    );
  }
}

class WeeklyDay {
  final String day;
  final bool completed;

  const WeeklyDay({required this.day, required this.completed});
}
