class OverallStats {
  final int currentStreak;
  final int longestStreak;
  final int totalCompleted;
  final double completionRate;
  final int activeHabits;
  final int perfectDays;

  const OverallStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompleted,
    required this.completionRate,
    required this.activeHabits,
    required this.perfectDays,
  });
}

class WeeklyDataPoint {
  final String label;
  final double value;
  final double total;

  const WeeklyDataPoint({
    required this.label,
    required this.value,
    required this.total,
  });
}

class MonthlyDataPoint {
  final String label;
  final double value;

  const MonthlyDataPoint({required this.label, required this.value});
}

class HabitBreakdown {
  final String name;
  final int colorValue;
  final double rate;
  final int streak;

  const HabitBreakdown({
    required this.name,
    required this.colorValue,
    required this.rate,
    required this.streak,
  });
}
