import 'package:flutter/material.dart';

class Challenge {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final int colorValue;
  final String duration;
  final String difficulty;
  final String participants;
  final double rating;
  final String category;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorValue,
    required this.duration,
    required this.difficulty,
    required this.participants,
    required this.rating,
    required this.category,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon.codePoint,
        'color': colorValue,
        'duration': duration,
        'difficulty': difficulty,
        'participants': participants,
        'rating': rating,
        'category': category,
      };
}
