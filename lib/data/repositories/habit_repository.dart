import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';
import '../models/category.dart';
import 'progress_repository.dart';

class HabitRepository {
  static SupabaseClient get _client => Supabase.instance.client;
  static final List<Habit> _habits = [];
  static bool _loaded = false;

  static String get _userId => _client.auth.currentUser?.id ?? '';

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Future<void> loadFromSupabase() async {
    if (_loaded) return;
    _loaded = true;
    await _fetchAll();
  }

  static Future<void> _fetchAll() async {
    _habits.clear();
    if (_userId.isEmpty) return;

    final data = await _client.from('habits').select().eq('user_id', _userId).order('id');
    final todayKey = _dateKey(DateTime.now());

    final todayLogs = await _client.from('daily_logs')
      .select('habit_id, is_completed')
      .eq('user_id', _userId)
      .eq('log_date', todayKey);

    final completedIds = <int>{};
    for (final log in (todayLogs as List)) {
      if (log['is_completed'] == true) {
        completedIds.add(log['habit_id'] as int);
      }
    }

    final allLogs = await _client.from('daily_logs')
      .select('habit_id, log_date, is_completed')
      .eq('user_id', _userId)
      .order('log_date', ascending: false);

    final logsByHabit = <int, List<Map<String, dynamic>>>{};
    for (final log in (allLogs as List)) {
      final hid = log['habit_id'] as int;
      logsByHabit.putIfAbsent(hid, () => []).add(log as Map<String, dynamic>);
    }

    for (final json in (data as List)) {
      final habit = _habitFromJson(json as Map<String, dynamic>);
      final isCompleted = completedIds.contains(habit.id);
      final streak = _calculateStreakFromLogs(logsByHabit[habit.id] ?? []);
      _habits.add(habit.copyWith(isCompleted: isCompleted, streak: streak));
    }
  }

  static Habit _habitFromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: IconData(json['icon'] as int? ?? Icons.check_circle_rounded.codePoint, fontFamily: 'MaterialIcons'),
      colorValue: json['color_value'] as int? ?? 0xFF64748B,
      category: json['category'] as String? ?? 'Other',
      duration: json['duration'] as String? ?? 'Daily',
      difficulty: json['difficulty'] as String? ?? 'Easy',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      users: json['users'] as String? ?? '',
      isAdded: true,
      isChallenge: json['is_challenge'] as bool? ?? false,
      challengeId: json['challenge_id'] as int?,
    );
  }

  static Map<String, dynamic> _habitToSupabase(Habit habit) {
    return {
      'user_id': _userId,
      'title': habit.title,
      'description': habit.description,
      'icon': habit.icon.codePoint,
      'color_value': habit.colorValue,
      'category': habit.category,
      'duration': habit.duration,
      'difficulty': habit.difficulty,
      'popularity': habit.popularity,
      'users': habit.users,
      'is_added': true,
      'is_challenge': habit.isChallenge,
      'challenge_id': habit.challengeId,
    };
  }

  static int _calculateStreakFromLogs(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return 0;
    logs.sort((a, b) => (a['log_date'] as String).compareTo(b['log_date'] as String));
    int streak = 0;
    for (int i = logs.length - 1; i >= 0; i--) {
      if (logs[i]['is_completed'] == true) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static IconData _iconForCategory(String category) {
    switch (category) {
      case 'Health': return Icons.favorite_rounded;
      case 'Fitness': return Icons.fitness_center_rounded;
      case 'Mindfulness': return Icons.self_improvement_rounded;
      case 'Learning': return Icons.menu_book_rounded;
      case 'Productivity': return Icons.rocket_launch_rounded;
      case 'Social': return Icons.people_rounded;
      case 'Finance': return Icons.savings_rounded;
      default: return Icons.category_rounded;
    }
  }

  static int _colorForCategory(String category) {
    switch (category) {
      case 'Health': return 0xFFFF6B6B;
      case 'Fitness': return 0xFF00C896;
      case 'Mindfulness': return 0xFF7C3AED;
      case 'Learning': return 0xFFED8936;
      case 'Productivity': return 0xFF0EA5E9;
      case 'Social': return 0xFFEC4899;
      case 'Finance': return 0xFF38A169;
      default: return 0xFF64748B;
    }
  }

  List<Habit> getTodayHabits() => List.unmodifiable(_habits);

  List<Habit> getAllHabits() => List.unmodifiable(_habits);

  List<Habit> getMyHabits() => _habits.toList();

  List<Habit> filteredHabits({
    required String query,
    required String category,
    required String difficulty,
  }) {
    return _habits.where((habit) {
      final matchesSearch = query.isEmpty ||
          habit.title.toLowerCase().contains(query.toLowerCase());
      final matchesCategory =
          category.isEmpty || category == 'All' || habit.category == category;
      final matchesDifficulty =
          difficulty.isEmpty || difficulty == 'All' || habit.difficulty == difficulty;
      return matchesSearch && matchesCategory && matchesDifficulty;
    }).toList();
  }

  List<Habit> getMyHabitsSortedBySort(String sortBy) {
    final habits = getMyHabits();
    switch (sortBy) {
      case 'Popularity':
        return List.from(habits)..sort((a, b) => b.popularity.compareTo(a.popularity));
      case 'A-Z':
        return List.from(habits)..sort((a, b) => a.title.compareTo(b.title));
      default:
        return habits;
    }
  }

  Future<Habit> addHabit(Map<String, dynamic> data) async {
    final category = data['category'] as String? ?? 'Other';
    final habit = Habit(
      id: 0,
      title: data['name'] as String? ?? 'New Habit',
      description: data['description'] as String? ?? '',
      icon: _iconForCategory(category),
      colorValue: _colorForCategory(category),
      category: category,
      duration: data['frequency'] as String? ?? 'Daily',
      isAdded: true,
    );
    final json = _habitToSupabase(habit);
    json['title'] = habit.title;
    json['icon'] = habit.icon.codePoint;
    json['color_value'] = habit.colorValue;
    json['category'] = habit.category;
    json['duration'] = habit.duration;

    final response = await _client.from('habits').insert(json).select().single();
    final saved = _habitFromJson(response);
    _habits.add(saved);
    return saved;
  }

  Future<void> updateHabit(int id, Map<String, dynamic> data) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    final category = data['category'] as String? ?? _habits[index].category;
    final updated = _habits[index].copyWith(
      title: data['name'] as String?,
      category: category,
      duration: data['frequency'] as String?,
      icon: _iconForCategory(category),
      colorValue: _colorForCategory(category),
    );
    await _client.from('habits').update(_habitToSupabase(updated)).eq('id', id);
    _habits[index] = updated;
  }

  Future<void> removeHabit(int id) async {
    _habits.removeWhere((h) => h.id == id);
    await _client.from('habits').delete().eq('id', id).eq('user_id', _userId);
  }

  Future<void> addChallengeHabit(String title, IconData icon, int colorValue, int challengeId) async {
    final habit = Habit(
      id: 0,
      title: title,
      icon: icon,
      colorValue: colorValue,
      category: 'Challenge',
      duration: 'Daily',
      isAdded: true,
      isChallenge: true,
      challengeId: challengeId,
    );
    final json = _habitToSupabase(habit);
    json['title'] = habit.title;
    json['icon'] = habit.icon.codePoint;
    json['color_value'] = habit.colorValue;
    json['category'] = habit.category;
    json['duration'] = habit.duration;

    final response = await _client.from('habits').insert(json).select().single();
    final saved = _habitFromJson(response);
    _habits.add(saved);
  }

  Future<void> removeChallengeHabit(int challengeId) async {
    final habitIds = _habits.where((h) => h.challengeId == challengeId).map((h) => h.id).toList();
    _habits.removeWhere((h) => h.challengeId == challengeId);
    for (final id in habitIds) {
      await _client.from('daily_logs').delete().eq('habit_id', id);
      await _client.from('habits').delete().eq('id', id);
    }
  }

  bool hasChallengeHabit(int challengeId) {
    return _habits.any((h) => h.challengeId == challengeId);
  }

  void syncStreaks(ProgressRepository progress) {
    final breakdown = progress.getHabitBreakdown();
    for (final b in breakdown) {
      final index = _habits.indexWhere((h) => h.title == b.name);
      if (index != -1) {
        _habits[index] = _habits[index].copyWith(streak: b.streak);
      }
    }
  }

  Future<void> toggleComplete(int id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    final newCompleted = !_habits[index].isCompleted;
    final todayKey = _dateKey(DateTime.now());

    if (newCompleted) {
      await _client.from('daily_logs').upsert({
        'user_id': _userId,
        'habit_id': id,
        'log_date': todayKey,
        'is_completed': true,
      }, onConflict: 'user_id, habit_id, log_date');
    } else {
      await _client.from('daily_logs')
        .delete()
        .eq('user_id', _userId)
        .eq('habit_id', id)
        .eq('log_date', todayKey);
    }

    _habits[index] = _habits[index].copyWith(isCompleted: newCompleted);
  }

  void toggleAdded(int id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    _habits[index] = _habits[index].copyWith(
      isAdded: !_habits[index].isAdded,
    );
  }

  List<String> get categories => const [
    'All', 'Health', 'Fitness', 'Mindfulness', 'Learning', 'Productivity', 'Sleep',
  ];

  List<HabitCategory> get formCategories => const [
    HabitCategory(label: 'Health', icon: Icons.favorite_rounded, colorValue: 0xFFFF6B6B),
    HabitCategory(label: 'Fitness', icon: Icons.fitness_center_rounded, colorValue: 0xFF00C896),
    HabitCategory(label: 'Mindfulness', icon: Icons.self_improvement_rounded, colorValue: 0xFF7C3AED),
    HabitCategory(label: 'Learning', icon: Icons.menu_book_rounded, colorValue: 0xFFED8936),
    HabitCategory(label: 'Productivity', icon: Icons.rocket_launch_rounded, colorValue: 0xFF0EA5E9),
    HabitCategory(label: 'Social', icon: Icons.people_rounded, colorValue: 0xFFEC4899),
    HabitCategory(label: 'Finance', icon: Icons.savings_rounded, colorValue: 0xFF38A169),
    HabitCategory(label: 'Other', icon: Icons.category_rounded, colorValue: 0xFF64748B),
  ];

  List<FrequencyOption> get frequencies => const [
    FrequencyOption(label: 'Daily', icon: Icons.today_rounded, description: 'Every day'),
    FrequencyOption(label: 'Weekdays', icon: Icons.work_rounded, description: 'Mon - Fri'),
    FrequencyOption(label: 'Weekends', icon: Icons.weekend_rounded, description: 'Sat & Sun'),
    FrequencyOption(label: 'Weekly', icon: Icons.date_range_rounded, description: 'Once a week'),
    FrequencyOption(label: '3x / Week', icon: Icons.repeat_rounded, description: '3 times a week'),
    FrequencyOption(label: 'Custom', icon: Icons.tune_rounded, description: 'Choose days'),
  ];

  List<String> get settingCategories => const [
    'Health', 'Mindfulness', 'Learning', 'Fitness', 'Productivity',
  ];
}
