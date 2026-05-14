import '../models/habit.dart';
import '../models/progress_stats.dart';
import '../repositories/habit_repository.dart';

class ProgressRepository {
  static final Map<String, Map<int, bool>> _dailyLog = {};

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static int _daysBetween(DateTime a, DateTime b) =>
      DateTime(a.year, a.month, a.day).difference(DateTime(b.year, b.month, b.day)).inDays;

  static void recordToggle(int habitId, bool isCompleted) {
    final today = _dateKey(DateTime.now());
    _dailyLog.putIfAbsent(today, () => {});
    _dailyLog[today]![habitId] = isCompleted;
  }

  static void removeHabitLogs(int habitId) {
    for (final date in _dailyLog.keys) {
      _dailyLog[date]?.remove(habitId);
    }
  }

  static bool isHabitCompletedOn(int habitId, DateTime date) {
    final key = _dateKey(date);
    return _dailyLog[key]?[habitId] == true;
  }

  static int getHabitCompletedCount(int habitId) {
    int count = 0;
    for (final dayLog in _dailyLog.values) {
      if (dayLog[habitId] == true) count++;
    }
    return count;
  }

  static int getHabitCurrentStreak(int habitId) {
    final sortedDates = _dailyLog.keys.toList()..sort();
    int streak = 0;
    for (int i = sortedDates.length - 1; i >= 0; i--) {
      final dayLog = _dailyLog[sortedDates[i]];
      if (dayLog?[habitId] == true) {
        streak++;
      } else if (dayLog?.containsKey(habitId) == true) {
        break;
      } else if (i < sortedDates.length - 1) {
        break;
      }
    }
    return streak;
  }

  List<Habit> get _allHabits => HabitRepository().getAllHabits();

  int get _activeCount => _allHabits.length;

  bool _allCompletedOn(String dateKey, List<Habit> habits) {
    final dayLog = _dailyLog[dateKey];
    if (dayLog == null || dayLog.isEmpty) return false;
    return habits.every((h) => dayLog[h.id] == true);
  }

  int _completedOn(String dateKey) {
    final dayLog = _dailyLog[dateKey];
    if (dayLog == null) return 0;
    return dayLog.values.where((v) => v).length;
  }

  double _rateOn(String dateKey, int total) {
    final dayLog = _dailyLog[dateKey];
    if (dayLog == null || total == 0) return 0.0;
    return dayLog.values.where((v) => v).length / total;
  }

  OverallStats? getOverallStats() {
    final habits = _allHabits;
    if (habits.isEmpty) return null;

    final today = DateTime.now();
    final todayKey = _dateKey(today);

    int totalCompleted = 0;
    int totalPossible = 0;
    int perfectDays = 0;

    for (final entry in _dailyLog.entries) {
      final dayHabits = entry.value;
      totalCompleted += dayHabits.values.where((v) => v).length;
      totalPossible += habits.length;

      if (habits.every((h) => dayHabits[h.id] == true)) {
        perfectDays++;
      }
    }

    final completionRate = totalPossible > 0 ? totalCompleted / totalPossible : 0.0;

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedDates = _dailyLog.keys.toList()..sort();

    for (final key in sortedDates) {
      if (_allCompletedOn(key, habits)) {
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 0;
      }
    }

    if (_allCompletedOn(todayKey, habits)) {
      currentStreak = tempStreak;
      var checkDate = DateTime(today.year, today.month, today.day - 1);
      while (true) {
        final key = _dateKey(checkDate);
        if (_dailyLog.containsKey(key) && _allCompletedOn(key, habits)) {
          currentStreak++;
          checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
        } else {
          break;
        }
      }
    } else if (_dailyLog.containsKey(todayKey)) {
      currentStreak = 0;
    }

    return OverallStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCompleted: totalCompleted,
      completionRate: completionRate,
      activeHabits: habits.length,
      perfectDays: perfectDays,
    );
  }

  List<WeeklyDataPoint> getWeeklyData() {
    final habits = _allHabits;
    if (habits.isEmpty) return [];

    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final total = habits.length;

    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      final key = _dateKey(date);
      final completed = _completedOn(key);
      return WeeklyDataPoint(
        label: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
        value: completed.toDouble(),
        total: total.toDouble(),
      );
    });
  }

  List<MonthlyDataPoint> getMonthlyData() {
    final habits = _allHabits;
    if (habits.isEmpty) return [];

    final today = DateTime.now();
    final total = habits.length;

    return List.generate(4, (i) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1 + (3 - i) * 7));
      double sum = 0;
      int days = 0;
      for (int d = 0; d < 7; d++) {
        final date = weekStart.add(Duration(days: d));
        if (!date.isAfter(today)) {
          sum += _rateOn(_dateKey(date), total);
          days++;
        }
      }
      return MonthlyDataPoint(
        label: 'W${i + 1}',
        value: days > 0 ? sum / days * total : 0,
      );
    });
  }

  List<HabitBreakdown> getHabitBreakdown() {
    final habits = _allHabits;
    if (habits.isEmpty) return [];

    return habits.map((habit) {
      int completed = 0;
      int total = 0;
      int streak = 0;
      int tempStreak = 0;
      final sortedDates = _dailyLog.keys.toList()..sort();

      for (final key in sortedDates) {
        final dayLog = _dailyLog[key];
        if (dayLog != null && dayLog.containsKey(habit.id)) {
          total++;
          if (dayLog[habit.id] == true) {
            completed++;
            tempStreak++;
            if (tempStreak > streak) streak = tempStreak;
          } else {
            tempStreak = 0;
          }
        }
      }

      final today = _dateKey(DateTime.now());
      if (_dailyLog[today]?.containsKey(habit.id) == true) {
        var s = 0;
        var checkDate = DateTime.now();
        while (true) {
          final key = _dateKey(checkDate);
          if (_dailyLog[key]?[habit.id] == true) {
            s++;
            checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
          } else {
            break;
          }
        }
        streak = s;
      }

      return HabitBreakdown(
        name: habit.title,
        colorValue: habit.colorValue,
        rate: total > 0 ? completed / total : 0.0,
        streak: streak,
      );
    }).toList();
  }

  Map<int, double> getCalendarData() {
    final habits = _allHabits;
    if (habits.isEmpty) return {};

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final total = habits.length;
    final result = <int, double>{};

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final key = _dateKey(date);
      result[day] = _rateOn(key, total);
    }

    return result;
  }
}
