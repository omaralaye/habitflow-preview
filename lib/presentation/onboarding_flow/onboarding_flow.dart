import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedGoal;
  String? _selectedReminderTime;
  final List<String> _selectedHabitAreas = [];

  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'icon': Icons.track_changes_rounded,
      'title': 'Build Better Habits',
      'subtitle':
          'Track your daily habits and build streaks that keep you motivated every single day.',
      'color': 0xFF00C896,
    },
    {
      'icon': Icons.bar_chart_rounded,
      'title': 'Visualize Progress',
      'subtitle':
          'See your growth with beautiful charts, streak calendars, and detailed statistics.',
      'color': 0xFF7C3AED,
    },
    {
      'icon': Icons.emoji_events_rounded,
      'title': 'Earn Achievements',
      'subtitle':
          'Stay motivated with streaks, badges, and milestones as you build lasting habits.',
      'color': 0xFFED8936,
    },
  ];

  final List<Map<String, dynamic>> _goalOptions = [
    {
      'id': 'health',
      'label': 'Health & Wellness',
      'icon': Icons.favorite_rounded,
    },
    {'id': 'productivity', 'label': 'Productivity', 'icon': Icons.bolt_rounded},
    {
      'id': 'mindfulness',
      'label': 'Mindfulness',
      'icon': Icons.self_improvement_rounded,
    },
    {'id': 'fitness', 'label': 'Fitness', 'icon': Icons.fitness_center_rounded},
    {'id': 'learning', 'label': 'Learning', 'icon': Icons.menu_book_rounded},
    {
      'id': 'social',
      'label': 'Social & Relationships',
      'icon': Icons.people_rounded,
    },
  ];

  final List<Map<String, dynamic>> _habitAreas = [
    {
      'id': 'morning',
      'label': 'Morning Routine',
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'id': 'exercise',
      'label': 'Exercise',
      'icon': Icons.directions_run_rounded,
    },
    {'id': 'nutrition', 'label': 'Nutrition', 'icon': Icons.restaurant_rounded},
    {'id': 'reading', 'label': 'Reading', 'icon': Icons.menu_book_rounded},
    {
      'id': 'meditation',
      'label': 'Meditation',
      'icon': Icons.self_improvement_rounded,
    },
    {'id': 'sleep', 'label': 'Sleep', 'icon': Icons.bedtime_rounded},
    {'id': 'hydration', 'label': 'Hydration', 'icon': Icons.water_drop_rounded},
    {
      'id': 'journaling',
      'label': 'Journaling',
      'icon': Icons.edit_note_rounded,
    },
  ];

  final List<String> _reminderTimes = [
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '12:00 PM',
    '6:00 PM',
    '8:00 PM',
    '10:00 PM',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _canContinue() {
    switch (_currentPage) {
      case 0:
      case 1:
      case 2:
        return true;
      case 3:
        return _selectedGoal != null;
      case 4:
        return _selectedHabitAreas.isNotEmpty;
      case 5:
        return true;
      default:
        return false;
    }
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.navigationContainer);
    }
  }

  void _handleSkip() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.navigationContainer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPages = 6;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width:
                              constraints.maxWidth *
                              ((_currentPage + 1) / totalPages),
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_currentPage + 1} of $totalPages',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              'Skip',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildIntroPage(0),
                  _buildIntroPage(1),
                  _buildIntroPage(2),
                  _buildGoalPage(theme),
                  _buildHabitAreasPage(theme),
                  _buildReminderPage(theme),
                ],
              ),
            ),
            _buildBottomSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage(int index) {
    final page = _onboardingPages[index];
    final color = Color(page['color'] as int);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(page['icon'] as IconData, size: 72, color: color),
          ),
          const SizedBox(height: 40),
          Text(
            page['title'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page['subtitle'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF718096),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'What\'s your main goal?',
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll personalize your habit recommendations.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _goalOptions.length,
            itemBuilder: (context, index) {
              final option = _goalOptions[index];
              final isSelected = _selectedGoal == option['id'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedGoal = option['id'] as String);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        option['icon'] as IconData,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option['label'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHabitAreasPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Which areas to focus on?',
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply. You can always change this later.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _habitAreas.map((area) {
              final isSelected = _selectedHabitAreas.contains(area['id']);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (isSelected) {
                      _selectedHabitAreas.remove(area['id']);
                    } else {
                      _selectedHabitAreas.add(area['id'] as String);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        area['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        area['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Set a daily reminder',
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll remind you to check in on your habits.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: _reminderTimes.map((time) {
              final isSelected = _selectedReminderTime == time;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedReminderTime = time);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        time,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedReminderTime = null);
              },
              child: Text(
                'Skip for now',
                style: GoogleFonts.dmSans(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _canContinue() ? _handleContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            disabledBackgroundColor: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            _currentPage == 5 ? 'Get Started' : 'Continue',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
