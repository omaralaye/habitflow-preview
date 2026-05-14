import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/category.dart';
import '../repositories/progress_repository.dart';

class HabitRepository {
  static final List<Habit> _habits = [];

  static int _nextId = 1;

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

  List<Habit> getMyHabits() => _habits.where((h) => h.isAdded).toList();

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

  Habit addHabit(Map<String, dynamic> data) {
    final category = data['category'] as String? ?? 'Other';
    final habit = Habit(
      id: _nextId++,
      title: data['name'] as String? ?? 'New Habit',
      icon: _iconForCategory(category),
      colorValue: _colorForCategory(category),
      category: category,
      duration: data['frequency'] as String? ?? 'Daily',
      isAdded: true,
    );
    _habits.add(habit);
    return habit;
  }

  void updateHabit(int id, Map<String, dynamic> data) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    final category = data['category'] as String? ?? _habits[index].category;
    _habits[index] = _habits[index].copyWith(
      title: data['name'] as String?,
      category: category,
      duration: data['frequency'] as String?,
      icon: _iconForCategory(category),
      colorValue: _colorForCategory(category),
    );
  }

  void removeHabit(int id) {
    _habits.removeWhere((h) => h.id == id);
  }

  void addChallengeHabit(String title, IconData icon, int colorValue, int challengeId) {
    _habits.add(Habit(
      id: _nextId++,
      title: title,
      icon: icon,
      colorValue: colorValue,
      category: 'Challenge',
      duration: 'Daily',
      isAdded: true,
      isChallenge: true,
      challengeId: challengeId,
    ));
  }

  void removeChallengeHabit(int challengeId) {
    final habitIds = _habits.where((h) => h.challengeId == challengeId).map((h) => h.id).toList();
    _habits.removeWhere((h) => h.challengeId == challengeId);
    for (final id in habitIds) {
      ProgressRepository.removeHabitLogs(id);
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

  void toggleComplete(int id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    final newCompleted = !_habits[index].isCompleted;
    _habits[index] = _habits[index].copyWith(
      isCompleted: newCompleted,
    );
    ProgressRepository.recordToggle(id, newCompleted);
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

  List<WeeklyDay> get weeklyData => const [
    WeeklyDay(day: 'M', completed: true),
    WeeklyDay(day: 'T', completed: true),
    WeeklyDay(day: 'W', completed: true),
    WeeklyDay(day: 'T', completed: false),
    WeeklyDay(day: 'F', completed: true),
    WeeklyDay(day: 'S', completed: true),
    WeeklyDay(day: 'S', completed: false),
  ];

  List<String> get settingCategories => const [
    'Health', 'Mindfulness', 'Learning', 'Fitness', 'Productivity',
  ];
}
