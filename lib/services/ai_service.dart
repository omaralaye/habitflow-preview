import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/habit.dart';
import '../data/models/progress_stats.dart';

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
