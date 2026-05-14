import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';

class HabitFocusScreen extends StatefulWidget {
  final Habit habit;

  const HabitFocusScreen({super.key, required this.habit});

  @override
  State<HabitFocusScreen> createState() => _HabitFocusScreenState();
}

class _HabitFocusScreenState extends State<HabitFocusScreen> {
  final HabitRepository _habitRepository = HabitRepository();
  final ProgressRepository _progressRepository = ProgressRepository();
  late bool _isCompleted;
  late int _streak;
  late int _completedCount;
  late List<bool> _weekDays;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final habit = widget.habit;
    _isCompleted = habit.isCompleted;
    _streak = ProgressRepository.getHabitCurrentStreak(habit.id);
    _completedCount = ProgressRepository.getHabitCompletedCount(habit.id);
    _weekDays = List.generate(7, (i) {
      final monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final date = monday.add(Duration(days: i));
      return ProgressRepository.isHabitCompletedOn(habit.id, date);
    });
  }

  void _toggleComplete() {
    HapticUtil.mediumImpact();
    _habitRepository.toggleComplete(widget.habit.id);
    _habitRepository.syncStreaks(_progressRepository);
    setState(() {
      _isCompleted = !_isCompleted;
      _loadData();
    });
  }

  Future<void> _editHabit() async {
    final habit = widget.habit;
    final habitArgs = {
      'name': habit.title,
      'category': habit.category,
      'frequency': habit.duration,
      'reminderEnabled': true,
      'reminderTime': null,
    };
    final result = await Navigator.pushNamed(
      context,
      '/edit-habit-screen',
      arguments: habitArgs,
    );
    if (result is Map<String, dynamic>) {
      _habitRepository.updateHabit(habit.id, result);
      if (mounted) setState(() {});
    }
  }

  Future<void> _confirmDelete() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.colorScheme.surface,
        title: Text('Delete Habit', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
        content: Text('Are you sure you want to permanently delete "${widget.habit.title}"?', style: GoogleFonts.dmSans(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Delete', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _habitRepository.removeHabit(widget.habit.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = widget.habit;
    final color = habit.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurface),
            onPressed: _editHabit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, habit, color),
            SizedBox(height: 3.h),
            _buildStatsRow(theme, color),
            SizedBox(height: 3.h),
            _buildWeeklyOverview(theme, color),
            if (habit.description.isNotEmpty) ...[
              SizedBox(height: 3.h),
              _buildDescription(theme, habit),
            ],
            SizedBox(height: 4.h),
            _buildToggleButton(theme, color),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Habit habit, Color color) {
    return Row(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(habit.icon, color: color, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(habit.title, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                  ),
                  if (habit.isChallenge) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('CHALLENGE', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(6)),
                child: Text(habit.category, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme, Color color) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(theme, '🔥', '$_streak', 'Day Streak', const Color(0xFFFF6B35))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(theme, '✅', '$_completedCount', 'Total Done', color)),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview(ThemeData theme, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final completed = _weekDays[i];
              final isToday = i == DateTime.now().weekday - 1;
              return Column(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: completed ? color : isToday ? color.withValues(alpha: 0.12) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(color: color, width: 2) : null,
                    ),
                    child: Center(
                      child: completed
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 20)
                          : Text(_dayLabels[i], style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: isToday ? color : theme.colorScheme.onSurfaceVariant)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_dayLabels[i], style: GoogleFonts.dmSans(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, Habit habit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 10),
          Text(habit.description, style: GoogleFonts.dmSans(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(ThemeData theme, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _toggleComplete,
        icon: Icon(_isCompleted ? Icons.undo_rounded : Icons.check_rounded, size: 22),
        label: Text(
          _isCompleted ? 'Mark Incomplete' : 'Mark Complete',
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCompleted ? theme.colorScheme.surfaceContainerHighest : color,
          foregroundColor: _isCompleted ? theme.colorScheme.onSurfaceVariant : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _isCompleted ? BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)) : BorderSide.none,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
