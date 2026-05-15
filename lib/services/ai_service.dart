import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/habit.dart';
import '../data/models/progress_stats.dart';
import '../data/models/challenge_suggestion.dart';

class AIService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Sends a chat message to the AI coach and returns the response.
  /// [messages] is the conversation history so far.
  /// [habits] and [stats] provide context about the user.
  static Future<String> sendChatMessage({
    required List<Map<String, String>> messages,
    List<Habit>? habits,
    OverallStats? stats,
  }) async {
    final context = _buildContext(habits, stats);
    final response = await _client.functions.invoke('ai-chat', body: {
      'messages': messages,
      'mode': 'coach',
      'context': context,
    });
    final data = response.data as Map<String, dynamic>;
    return data['content'] as String? ?? '';
  }

  /// Extracts a create-habit action block from AI response text.
  /// Returns a map {name, category, frequency, description} or null if no action found.
  static Map<String, String>? extractCreateHabitAction(String content) {
    final regex = RegExp(r'\[CREATE_HABIT\]({.*?})\[/CREATE_HABIT\]', dotAll: true);
    final match = regex.firstMatch(content);
    if (match == null) return null;
    try {
      final parsed = json.decode(match.group(1)!) as Map<String, dynamic>;
      final name = parsed['name']?.toString().trim();
      final category = parsed['category']?.toString().trim();
      final frequency = parsed['frequency']?.toString().trim();
      final description = parsed['description']?.toString().trim();
      if (name == null || name.isEmpty) return null;
      return {
        'name': name,
        'category': category ?? 'Other',
        'frequency': frequency ?? 'Daily',
        if (description != null && description.isNotEmpty) 'description': description,
      };
    } catch (_) {
      return null;
    }
  }

  /// Generates a brief description for a habit using AI.
  /// Returns a single-sentence description string.
  static Future<String> generateHabitDescription(String name, String category, String frequency) async {
    final text = 'Create a $frequency $category habit called "$name"';
    try {
      final result = await parseHabitFromText(text);
      final desc = result['description'] ?? '';
      if (desc.length > 3) return desc;
    } catch (_) {}
    return 'A $frequency $category habit to help you stay consistent.';
  }

  /// Strips all action blocks from AI response for clean display.
  static String stripActionBlocks(String content) {
    final regex = RegExp(r'\[CREATE_HABIT\].*?\[/CREATE_HABIT\]', dotAll: true);
    return content.replaceAll(regex, '').trim();
  }

  /// Parses natural language into a structured habit.
  /// e.g. "I want to meditate for 10 minutes every morning"
  /// Returns a map with title, category, duration, description.
  static Future<Map<String, String>> parseHabitFromText(String text) async {
    final response = await _client.functions.invoke('ai-chat', body: {
      'messages': [{'role': 'user', 'content': text}],
      'mode': 'parse_habit',
    });
    final data = response.data as Map<String, dynamic>;
    final content = data['content'] as String? ?? '';
    try {
      final parsed = json.decode(content) as Map<String, dynamic>;
      return {
        'title': parsed['title'] as String? ?? 'New Habit',
        'category': parsed['category'] as String? ?? 'Other',
        'duration': parsed['duration'] as String? ?? 'Daily',
        'description': parsed['description'] as String? ?? '',
      };
    } catch (_) {
      return {'title': text, 'category': 'Other', 'duration': 'Daily', 'description': ''};
    }
  }

  /// Generates a weekly insight narrative based on user's data.
  static Future<String> generateInsight({
    required List<Habit> habits,
    required OverallStats? stats,
  }) async {
    final context = _buildContext(habits, stats);
    final response = await _client.functions.invoke('ai-chat', body: {
      'messages': [],
      'mode': 'insight',
      'context': context,
    });
    final data = response.data as Map<String, dynamic>;
    return data['content'] as String? ?? '';
  }

  /// Analyzes habit patterns and returns insights.
  static Future<String> analyzeHabits({
    required List<Habit> habits,
    required OverallStats? stats,
  }) async {
    final context = _buildContext(habits, stats);
    final response = await _client.functions.invoke('ai-chat', body: {
      'messages': [],
      'mode': 'analysis',
      'context': context,
    });
    final data = response.data as Map<String, dynamic>;
    return data['content'] as String? ?? '';
  }

  /// Gets scheduling suggestions based on patterns.
  static Future<String> suggestSchedule({
    required List<Habit> habits,
    required OverallStats? stats,
  }) async {
    final context = _buildContext(habits, stats);
    final response = await _client.functions.invoke('ai-chat', body: {
      'messages': [],
      'mode': 'schedule',
      'context': context,
    });
    final data = response.data as Map<String, dynamic>;
    return data['content'] as String? ?? '';
  }

  /// Generates personalized challenge suggestions based on user's habits.
  /// Returns a list of [ChallengeSuggestion] generated by AI.
  static Future<List<ChallengeSuggestion>> suggestChallenges({
    required List<Habit> habits,
    required OverallStats? stats,
  }) async {
    final context = _buildContext(habits, stats);
    try {
      final response = await _client.functions.invoke('ai-chat', body: {
        'messages': [],
        'mode': 'suggest_challenges',
        'context': context,
      });
      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as String? ?? '';
      if (content.isEmpty) return [];
      final list = json.decode(content) as List<dynamic>;
      return list.map((item) => ChallengeSuggestion.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic> _buildContext(List<Habit>? habits, OverallStats? stats) {
    return {
      'habits': habits?.map((h) => h.toJson()).toList() ?? [],
      'stats': stats != null
          ? {
              'currentStreak': stats.currentStreak,
              'longestStreak': stats.longestStreak,
              'totalCompleted': stats.totalCompleted,
              'completionRate': stats.completionRate,
              'activeHabits': stats.activeHabits,
              'perfectDays': stats.perfectDays,
            }
          : {},
    };
  }
}
