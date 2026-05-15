import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/habit_repository.dart';

class ChallengeManager {
  ChallengeManager._();

  static List<Map<String, dynamic>> _activeChallenges = [];
  static final List<VoidCallback> _listeners = [];

  static List<Map<String, dynamic>> get activeChallenges =>
      List.unmodifiable(_activeChallenges);

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('active_challenges');
    if (data != null) {
      _activeChallenges =
          List<Map<String, dynamic>>.from(jsonDecode(data) as List);
    }
    for (final c in _activeChallenges) {
      final repo = HabitRepository();
      if (!repo.hasChallengeHabit(c['id'] as int)) {
        await repo.addChallengeHabit(
          c['title'] as String,
          IconData(c['icon'] as int, fontFamily: 'MaterialIcons'),
          c['color'] as int,
          c['id'] as int,
        );
      }
    }
    _notify();
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_challenges', jsonEncode(_activeChallenges));
  }

  static Future<void> joinChallenge(Map<String, dynamic> challenge) async {
    final now = DateTime.now();
    final active = {
      'id': challenge['id'],
      'title': challenge['title'],
      'description': challenge['description'],
      'icon': (challenge['icon'] as IconData).codePoint,
      'color': challenge['color'],
      'totalDays': _extractDays(challenge['duration'] as String? ?? '30 days'),
      'currentDay': 0,
      'completedDays': <String>[],
      'joinedDate':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'dailyTask': '',
      'participants': challenge['participants'],
    };
    _activeChallenges.add(active);
    await HabitRepository().addChallengeHabit(
      challenge['title'] as String,
      challenge['icon'] as IconData,
      challenge['color'] as int,
      challenge['id'] as int,
    );
    await _save();
    _notify();
  }

  static Future<void> markDayComplete(int challengeId) async {
    final idx =
        _activeChallenges.indexWhere((c) => c['id'] == challengeId);
    if (idx == -1) return;
    final today = _todayStr();
    final completed = List<String>.from(_activeChallenges[idx]['completedDays']);
    if (!completed.contains(today)) {
      completed.add(today);
      _activeChallenges[idx]['completedDays'] = completed;
      _activeChallenges[idx]['currentDay'] = completed.length;
    }
    await _save();
    _notify();
  }

  static bool isTodayComplete(int challengeId) {
    final idx =
        _activeChallenges.indexWhere((c) => c['id'] == challengeId);
    if (idx == -1) return false;
    final completed = List<String>.from(_activeChallenges[idx]['completedDays']);
    return completed.contains(_todayStr());
  }

  static Future<void> leaveChallenge(int challengeId) async {
    _activeChallenges.removeWhere((c) => c['id'] == challengeId);
    await HabitRepository().removeChallengeHabit(challengeId);
    await _save();
    _notify();
  }

  static bool isJoined(int challengeId) {
    return _activeChallenges.any((c) => c['id'] == challengeId);
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int _extractDays(String duration) {
    final match = RegExp(r'(\d+)').firstMatch(duration);
    return match != null ? int.parse(match.group(1)!) : 30;
  }


}
