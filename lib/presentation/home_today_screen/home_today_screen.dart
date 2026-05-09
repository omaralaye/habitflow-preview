import 'package:flowfit/core/app_export.dart';
import 'package:flowfit/core/challenge_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Home/Today Screen - Daily habit check-in dashboard
class HomeTodayScreen extends StatefulWidget {
  final VoidCallback? onSeeAllHabits;

  const HomeTodayScreen({super.key, this.onSeeAllHabits});

  @override
  State<HomeTodayScreen> createState() => _HomeTodayScreenState();
}

class _HomeTodayScreenState extends State<HomeTodayScreen> {
  final String _userName = 'Alex';
  final int _currentStreak = 14;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    ChallengeManager.addListener(_onChallengesChanged);
  }

  @override
  void dispose() {
    ChallengeManager.removeListener(_onChallengesChanged);
    super.dispose();
  }

  void _onChallengesChanged() {
    if (mounted) setState(() {});
  }

  final List<Map<String, dynamic>> _todayHabits = [
    {
      'id': 1,
      'title': 'Morning Meditation',
      'icon': Icons.self_improvement_rounded,
      'color': 0xFF7C3AED,
      'duration': '10 min',
      'category': 'Mindfulness',
      'isCompleted': true,
      'streak': 14,
    },
    {
      'id': 2,
      'title': 'Drink 8 Glasses of Water',
      'icon': Icons.water_drop_rounded,
      'color': 0xFF0EA5E9,
      'duration': 'All day',
      'category': 'Health',
      'isCompleted': true,
      'streak': 7,
    },
    {
      'id': 3,
      'title': 'Read 20 Pages',
      'icon': Icons.menu_book_rounded,
      'color': 0xFFED8936,
      'duration': '20 min',
      'category': 'Learning',
      'isCompleted': false,
      'streak': 5,
    },
    {
      'id': 4,
      'title': 'Evening Walk',
      'icon': Icons.directions_walk_rounded,
      'color': 0xFF00C896,
      'duration': '30 min',
      'category': 'Fitness',
      'isCompleted': false,
      'streak': 10,
    },
    {
      'id': 5,
      'title': 'Gratitude Journal',
      'icon': Icons.edit_note_rounded,
      'color': 0xFFEC4899,
      'duration': '5 min',
      'category': 'Mindfulness',
      'isCompleted': false,
      'streak': 3,
    },
    {
      'id': 6,
      'title': 'No Social Media Before 9AM',
      'icon': Icons.phone_android_rounded,
      'color': 0xFF64748B,
      'duration': 'Morning',
      'category': 'Productivity',
      'isCompleted': true,
      'streak': 8,
    },
  ];

  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'M', 'completed': true},
    {'day': 'T', 'completed': true},
    {'day': 'W', 'completed': true},
    {'day': 'T', 'completed': false},
    {'day': 'F', 'completed': true},
    {'day': 'S', 'completed': true},
    {'day': 'S', 'completed': false},
  ];

  int get _completedCount =>
      _todayHabits.where((h) => h['isCompleted'] == true).length;

  double get _completionRate => _completedCount / _todayHabits.length;

  String _getGreeting() {
    final hour = _today.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  void _toggleHabit(int id) {
    HapticUtil.mediumImpact();
    setState(() {
      final index = _todayHabits.indexWhere((h) => h['id'] == id);
      if (index != -1) {
        _todayHabits[index]['isCompleted'] =
            !_todayHabits[index]['isCompleted'];
      }
    });
  }

  void _editHabit(Map<String, dynamic> habit) async {
    HapticUtil.mediumImpact();
    final habitArgs = {
      'name': habit['title'] as String,
      'category': habit['category'] as String,
      'frequency': habit['frequency'] ?? 'Daily',
      'reminderEnabled': true,
      'reminderTime': null,
    };
    final result = await Navigator.pushNamed(
      context,
      '/edit-habit-screen',
      arguments: habitArgs,
    );
    if (result is Map<String, dynamic>) {
      setState(() {
        final index = _todayHabits.indexWhere((h) => h['id'] == habit['id']);
        if (index != -1) {
          _todayHabits[index]['title'] = result['name'];
          _todayHabits[index]['category'] = result['category'];
          _todayHabits[index]['frequency'] = result['frequency'];
        }
      });
    }
  }

  Future<void> _confirmDeleteHabit(Map<String, dynamic> habit) async {
    HapticUtil.mediumImpact();
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Delete Habit',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${habit['title']}"? This action cannot be undone.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _todayHabits.removeWhere((h) => h['id'] == habit['id']);
      });
    }
  }

  void _showHabitOptions(Map<String, dynamic> habit) {
    HapticUtil.mediumImpact();
    final theme = Theme.of(context);
    final color = Color(habit['color'] as int);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(habit['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit['title'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.edit_rounded,
                    color: theme.colorScheme.primary, size: 20),
              ),
              title: Text(
                'Edit Habit',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _editHabit(habit);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_rounded,
                    color: Colors.red.shade600, size: 20),
              ),
              title: Text(
                'Delete Habit',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600, color: Colors.red.shade600),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDeleteHabit(habit);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakAndProgress(theme),
                _buildWeeklyOverview(theme),
                if (AppSettings.motivationalQuotes) _buildQuoteCard(theme),
                _buildActiveChallengeCard(theme),
                _buildTodayHabitsSection(theme),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-habit-screen'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Habit',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'HabitFlow',
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: theme.colorScheme.onSurface,
                            size: 22,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.notificationsScreen),

                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_getGreeting()}, $_userName! 👋',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${_getDayName(_today.weekday)}, ${_today.day} ${_getMonthName(_today.month)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildStreakAndProgress(ThemeData theme) {
    final showStreak = AppSettings.showStreak;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (showStreak) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35),
                      const Color(0xFFFF6B35).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_currentStreak days',
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Current Streak',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_completedCount/${_todayHabits.length}',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${(_completionRate * 100).toInt()}%',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _completionRate,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Today\'s Progress',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_weeklyData.length, (index) {
                final day = _weeklyData[index];
                final isToday = index == _today.weekday - 1;
                final isCompleted = day['completed'] as bool;
                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : isToday
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                day['day'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day['day'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(ThemeData theme) {
    final quote = motivationalQuotesList[_today.day % motivationalQuotesList.length];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.format_quote_rounded,
                color: theme.colorScheme.primary, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '"$quote"',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChallengeCard(ThemeData theme) {
    final activeList = ChallengeManager.activeChallenges;
    if (activeList.isEmpty) return const SizedBox.shrink();
    final challenge = activeList.first;
    final color = Color(challenge['color'] as int);
    final currentDay = challenge['currentDay'] as int;
    final totalDays = challenge['totalDays'] as int;
    final progress = totalDays > 0 ? currentDay / totalDays : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/challenges-screen'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(challenge['icon'] as int,
                      fontFamily: 'MaterialIcons'),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['title'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Day $currentDay of $totalDays',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayHabitsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Habits',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: widget.onSeeAllHabits,
                child: Text(
                  'See all',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._todayHabits.map((habit) => _buildHabitCard(theme, habit)),
        ],
      ),
    );
  }

  Widget _buildHabitCard(ThemeData theme, Map<String, dynamic> habit) {
    final isCompleted = habit['isCompleted'] as bool;
    final color = Color(habit['color'] as int);

    return Dismissible(
      key: ValueKey(habit['id']),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticUtil.mediumImpact();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'Delete Habit',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Are you sure you want to permanently delete "${habit['title']}"? This action cannot be undone.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
        return confirmed == true;
      },
      onDismissed: (_) {
        setState(() {
          _todayHabits.removeWhere((h) => h['id'] == habit['id']);
        });
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => _toggleHabit(habit['id'] as int),
        onLongPress: () => _showHabitOptions(habit),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted
                ? color.withValues(alpha: 0.08)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCompleted
                  ? color.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? color.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(habit['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit['title'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : theme.colorScheme.onSurface,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 13,
                          color: const Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${habit['streak']} day streak',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          habit['duration'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? color
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
