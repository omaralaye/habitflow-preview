import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Challenges Screen - Habit challenges and community goals
class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, dynamic> _activeChallenge = {
    'id': 1,
    'title': '30-Day Mindfulness Challenge',
    'description': 'Build a daily meditation practice over 30 days.',
    'icon': Icons.self_improvement_rounded,
    'color': 0xFF7C3AED,
    'currentDay': 14,
    'totalDays': 30,
    'participants': '12.4K',
    'completionRate': 0.47,
    'dailyTask': 'Meditate for 10 minutes',
    'streak': 14,
    'weeklyProgress': [true, true, true, false, true, true, false],
  };

  final List<Map<String, dynamic>> _availableChallenges = [
    {
      'id': 2,
      'title': '21-Day No Sugar Challenge',
      'description': 'Eliminate added sugars for 21 days to reset your palate.',
      'icon': Icons.no_food_rounded,
      'color': 0xFFFF6B35,
      'duration': '21 days',
      'difficulty': 'Hard',
      'participants': '8.2K',
      'rating': 4.7,
      'category': 'Health',
      'isJoined': false,
    },
    {
      'id': 3,
      'title': '7-Day Reading Sprint',
      'description': 'Read at least 30 pages every day for a week.',
      'icon': Icons.menu_book_rounded,
      'color': 0xFFED8936,
      'duration': '7 days',
      'difficulty': 'Medium',
      'participants': '5.6K',
      'rating': 4.8,
      'category': 'Learning',
      'isJoined': false,
    },
    {
      'id': 4,
      'title': '14-Day Morning Routine',
      'description':
          'Wake up at 6 AM and complete your morning routine for 2 weeks.',
      'icon': Icons.wb_sunny_rounded,
      'color': 0xFFFBBF24,
      'duration': '14 days',
      'difficulty': 'Medium',
      'participants': '15.1K',
      'rating': 4.6,
      'category': 'Productivity',
      'isJoined': false,
    },
    {
      'id': 5,
      'title': '30-Day Fitness Streak',
      'description': 'Exercise for at least 20 minutes every day for a month.',
      'icon': Icons.fitness_center_rounded,
      'color': 0xFF00C896,
      'duration': '30 days',
      'difficulty': 'Hard',
      'participants': '22.3K',
      'rating': 4.9,
      'category': 'Fitness',
      'isJoined': false,
    },
    {
      'id': 6,
      'title': '10-Day Digital Detox',
      'description': 'Limit social media to 30 minutes per day for 10 days.',
      'icon': Icons.phone_disabled_rounded,
      'color': 0xFF64748B,
      'duration': '10 days',
      'difficulty': 'Hard',
      'participants': '9.7K',
      'rating': 4.5,
      'category': 'Mindfulness',
      'isJoined': false,
    },
    {
      'id': 7,
      'title': '5-Day Gratitude Practice',
      'description': 'Write 5 things you\'re grateful for every morning.',
      'icon': Icons.favorite_rounded,
      'color': 0xFFEC4899,
      'duration': '5 days',
      'difficulty': 'Easy',
      'participants': '18.9K',
      'rating': 4.8,
      'category': 'Mindfulness',
      'isJoined': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Challenges',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildActiveTab(theme), _buildDiscoverTab(theme)],
      ),
    );
  }

  Widget _buildActiveTab(ThemeData theme) {
    final color = Color(_activeChallenge['color'] as int);
    final progress = _activeChallenge['completionRate'] as double;
    final weeklyProgress = _activeChallenge['weeklyProgress'] as List<bool>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _activeChallenge['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _activeChallenge['title'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day ${_activeChallenge['currentDay']} of ${_activeChallenge['totalDays']}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}% complete',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Today\'s Task',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.task_alt_rounded, color: color, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _activeChallenge['dailyTask'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This Week',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final done = weeklyProgress[index];
                    return Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: done ? color : color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: done
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : Text(
                                    days[index],
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days[index],
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.dmSans(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Day ${_activeChallenge['currentDay']} marked complete! 🎉',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Mark Done',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Achievements',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAchievementBadge(
                theme,
                '🔥',
                '14 Day\nStreak',
                const Color(0xFFFF6B35),
              ),
              const SizedBox(width: 12),
              _buildAchievementBadge(
                theme,
                '⭐',
                '50 Habits\nCompleted',
                const Color(0xFFFBBF24),
              ),
              const SizedBox(width: 12),
              _buildAchievementBadge(
                theme,
                '💎',
                'Early\nAdopter',
                const Color(0xFF7C3AED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
    ThemeData theme,
    String emoji,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableChallenges.length,
      itemBuilder: (context, index) {
        final challenge = _availableChallenges[index];
        final color = Color(challenge['color'] as int);
        final isJoined = challenge['isJoined'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      challenge['icon'] as IconData,
                      color: color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge['title'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people_rounded,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${challenge['participants']} joined',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: const Color(0xFFFBBF24),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${challenge['rating']}',
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
                ],
              ),
              const SizedBox(height: 10),
              Text(
                challenge['description'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag(
                    theme,
                    challenge['duration'] as String,
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    theme,
                    challenge['difficulty'] as String,
                    Icons.bar_chart_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    theme,
                    challenge['category'] as String,
                    Icons.label_rounded,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        final idx = _availableChallenges.indexWhere(
                          (c) => c['id'] == challenge['id'],
                        );
                        if (idx != -1) {
                          _availableChallenges[idx]['isJoined'] = !isJoined;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isJoined
                            ? theme.colorScheme.surfaceContainerHighest
                            : color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isJoined ? 'Joined ✓' : 'Join',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isJoined
                              ? theme.colorScheme.onSurfaceVariant
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTag(ThemeData theme, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
