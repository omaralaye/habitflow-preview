import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Habits Library Screen - Browse and manage all habits
class WorkoutsLibraryScreen extends StatefulWidget {
  const WorkoutsLibraryScreen({super.key});

  @override
  State<WorkoutsLibraryScreen> createState() => _WorkoutsLibraryScreenState();
}

class _WorkoutsLibraryScreenState extends State<WorkoutsLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Health',
    'Fitness',
    'Mindfulness',
    'Learning',
    'Productivity',
    'Sleep',
  ];

  final List<Map<String, dynamic>> _allHabits = [
    {
      'id': 1,
      'title': 'Morning Meditation',
      'description':
          'Start your day with 10 minutes of mindful breathing and clarity.',
      'icon': Icons.self_improvement_rounded,
      'color': 0xFF7C3AED,
      'category': 'Mindfulness',
      'duration': '10 min',
      'difficulty': 'Easy',
      'popularity': 4.9,
      'users': '125K',
      'isAdded': true,
    },
    {
      'id': 2,
      'title': 'Drink 8 Glasses of Water',
      'description':
          'Stay hydrated throughout the day for better energy and focus.',
      'icon': Icons.water_drop_rounded,
      'color': 0xFF0EA5E9,
      'category': 'Health',
      'duration': 'All day',
      'difficulty': 'Easy',
      'popularity': 4.8,
      'users': '210K',
      'isAdded': true,
    },
    {
      'id': 3,
      'title': 'Read 20 Pages',
      'description':
          'Build a reading habit to expand your knowledge every day.',
      'icon': Icons.menu_book_rounded,
      'color': 0xFFED8936,
      'category': 'Learning',
      'duration': '20 min',
      'difficulty': 'Easy',
      'popularity': 4.7,
      'users': '98K',
      'isAdded': true,
    },
    {
      'id': 4,
      'title': 'Evening Walk',
      'description':
          'A 30-minute walk to unwind and improve cardiovascular health.',
      'icon': Icons.directions_walk_rounded,
      'color': 0xFF00C896,
      'category': 'Fitness',
      'duration': '30 min',
      'difficulty': 'Easy',
      'popularity': 4.6,
      'users': '87K',
      'isAdded': true,
    },
    {
      'id': 5,
      'title': 'Gratitude Journal',
      'description': 'Write 3 things you\'re grateful for to boost positivity.',
      'icon': Icons.edit_note_rounded,
      'color': 0xFFEC4899,
      'category': 'Mindfulness',
      'duration': '5 min',
      'difficulty': 'Easy',
      'popularity': 4.8,
      'users': '156K',
      'isAdded': true,
    },
    {
      'id': 6,
      'title': '7-Minute Workout',
      'description':
          'High-intensity circuit training for a quick daily fitness boost.',
      'icon': Icons.fitness_center_rounded,
      'color': 0xFFFF6B35,
      'category': 'Fitness',
      'duration': '7 min',
      'difficulty': 'Medium',
      'popularity': 4.5,
      'users': '73K',
      'isAdded': false,
    },
    {
      'id': 7,
      'title': 'No Phone First Hour',
      'description': 'Avoid screens for the first hour after waking up.',
      'icon': Icons.phone_disabled_rounded,
      'color': 0xFF64748B,
      'category': 'Productivity',
      'duration': '1 hour',
      'difficulty': 'Hard',
      'popularity': 4.4,
      'users': 'New',
      'isAdded': false,
    },
    {
      'id': 8,
      'title': 'Cold Shower',
      'description':
          'Build mental toughness and boost alertness with cold water.',
      'icon': Icons.shower_rounded,
      'color': 0xFF0EA5E9,
      'category': 'Health',
      'duration': '5 min',
      'difficulty': 'Hard',
      'popularity': 4.3,
      'users': '45K',
      'isAdded': false,
    },
    {
      'id': 9,
      'title': 'Sleep by 10 PM',
      'description':
          'Maintain a consistent sleep schedule for better recovery.',
      'icon': Icons.bedtime_rounded,
      'color': 0xFF6366F1,
      'category': 'Sleep',
      'duration': 'Evening',
      'difficulty': 'Medium',
      'popularity': 4.6,
      'users': '112K',
      'isAdded': false,
    },
    {
      'id': 10,
      'title': 'Learn a New Word',
      'description': 'Expand your vocabulary by learning one new word daily.',
      'icon': Icons.translate_rounded,
      'color': 0xFFED8936,
      'category': 'Learning',
      'duration': '5 min',
      'difficulty': 'Easy',
      'popularity': 4.2,
      'users': '34K',
      'isAdded': false,
    },
    {
      'id': 11,
      'title': 'Deep Work Session',
      'description':
          '90 minutes of focused, distraction-free work on important tasks.',
      'icon': Icons.psychology_rounded,
      'color': 0xFF7C3AED,
      'category': 'Productivity',
      'duration': '90 min',
      'difficulty': 'Hard',
      'popularity': 4.7,
      'users': '67K',
      'isAdded': false,
    },
    {
      'id': 12,
      'title': 'Stretching Routine',
      'description':
          'Daily stretching to improve flexibility and reduce tension.',
      'icon': Icons.accessibility_new_rounded,
      'color': 0xFF00C896,
      'category': 'Fitness',
      'duration': '15 min',
      'difficulty': 'Easy',
      'popularity': 4.5,
      'users': '89K',
      'isAdded': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredHabits {
    return _allHabits.where((habit) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          (habit['title'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategory == 'All' || habit['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Map<String, dynamic>> get _myHabits =>
      _allHabits.where((h) => h['isAdded'] == true).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleHabit(int id) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _allHabits.indexWhere((h) => h['id'] == id);
      if (index != -1) {
        _allHabits[index]['isAdded'] = !(_allHabits[index]['isAdded'] as bool);
      }
    });
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
          'Habits',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
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
            Tab(text: 'My Habits'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyHabitsTab(theme), _buildDiscoverTab(theme)],
      ),
    );
  }

  Widget _buildMyHabitsTab(ThemeData theme) {
    if (_myHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No habits yet',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover habits to add to your routine',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myHabits.length,
      itemBuilder: (context, index) {
        return _buildHabitListCard(theme, _myHabits[index], showRemove: true);
      },
    );
  }

  Widget _buildDiscoverTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search habits...',
              hintStyle: GoogleFonts.dmSans(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedCategory = cat);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredHabits.isEmpty
              ? Center(
                  child: Text(
                    'No habits found',
                    style: GoogleFonts.dmSans(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredHabits.length,
                  itemBuilder: (context, index) {
                    return _buildHabitListCard(
                      theme,
                      _filteredHabits[index],
                      showRemove: false,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHabitListCard(
    ThemeData theme,
    Map<String, dynamic> habit, {
    required bool showRemove,
  }) {
    final color = Color(habit['color'] as int);
    final isAdded = habit['isAdded'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(habit['icon'] as IconData, color: color, size: 26),
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
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  habit['description'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildChip(
                      theme,
                      habit['duration'] as String,
                      Icons.access_time_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      theme,
                      habit['difficulty'] as String,
                      Icons.bar_chart_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      theme,
                      '${habit['users']} users',
                      Icons.people_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _toggleHabit(habit['id'] as int),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isAdded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAdded ? Icons.check_rounded : Icons.add_rounded,
                color: isAdded ? Colors.white : theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(ThemeData theme, String label, IconData icon) {
    return Row(
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
    );
  }
}
