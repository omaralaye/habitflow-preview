import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_settings.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit.dart';
import '../../data/models/user_subscription.dart';
import '../../services/subscription_service.dart';
import '../../routes/app_routes.dart';

/// Habits Library Screen - Browse and manage all habits
class WorkoutsLibraryScreen extends StatefulWidget {
  const WorkoutsLibraryScreen({super.key});

  @override
  State<WorkoutsLibraryScreen> createState() => _WorkoutsLibraryScreenState();
}

class _WorkoutsLibraryScreenState extends State<WorkoutsLibraryScreen>
    with SingleTickerProviderStateMixin {
  final HabitRepository _habitRepository = HabitRepository();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _filterDifficulty = 'All';
  String _sortBy = 'Popularity';

  late final List<String> _categories;

  List<Habit> get _allHabits => _habitRepository.getAllHabits();

  List<Habit> get _filteredHabits {
    return _habitRepository.filteredHabits(
      query: _searchQuery,
      category: _selectedCategory,
      difficulty: _filterDifficulty,
    );
  }

  List<Habit> get _myHabits =>
      _habitRepository.getMyHabits();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _categories = _habitRepository.categories;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Filter Habits',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Difficulty',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Easy', 'Medium', 'Hard'].map((d) {
                        final selected = _filterDifficulty == d;
                        return ChoiceChip(
                          label: Text(d),
                          selected: selected,
                          onSelected: (_) {
                            setSheetState(() => _filterDifficulty = d);
                            setState(() => _filterDifficulty = d);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Sort by',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Popularity', 'Duration', 'A-Z'].map((s) {
                        final selected = _sortBy == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: selected,
                          onSelected: (_) {
                            setSheetState(() => _sortBy = s);
                            setState(() => _sortBy = s);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleHabit(int id) {
    HapticUtil.lightImpact();
    _habitRepository.toggleAdded(id);
    setState(() {});
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
            onPressed: () => _showFilterSheet(theme),
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
      return Column(
        children: [
          _buildHabitLimitBar(theme),
          Expanded(
            child: Center(
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
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHabitLimitBar(theme),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _myHabits.length,
            itemBuilder: (context, index) {
              return _buildHabitListCard(theme, _myHabits[index], showRemove: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHabitLimitBar(ThemeData theme) {
    return FutureBuilder<UserSubscription>(
      future: SubscriptionService().getSubscription(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final sub = snapshot.data!;
        if (sub.isPremium) return const SizedBox.shrink();

        final count = _myHabits.length;
        final limit = SubscriptionService.freeMaxHabits;
        final ratio = count / limit;
        final isNearLimit = count >= limit - 1;
        final isAtLimit = count >= limit;

        if (count == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.paywallScreen),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isAtLimit
                  ? theme.colorScheme.error.withValues(alpha: 0.1)
                  : isNearLimit
                      ? Colors.orange.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isAtLimit ? Icons.block_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: isAtLimit
                      ? theme.colorScheme.error
                      : isNearLimit
                          ? Colors.orange
                          : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAtLimit
                        ? 'Habit limit reached. Upgrade for unlimited.'
                        : '$count of $limit habits used',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isAtLimit
                          ? theme.colorScheme.error
                          : isNearLimit
                              ? Colors.orange.shade800
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAtLimit
                            ? theme.colorScheme.error
                            : isNearLimit
                                ? Colors.orange
                                : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
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
                  HapticUtil.lightImpact();
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
    Habit habit, {
    required bool showRemove,
  }) {
    final color = habit.color;
    final isAdded = habit.isAdded;

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
            child: Icon(habit.icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  habit.description,
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
                      habit.duration,
                      Icons.access_time_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      theme,
                      habit.difficulty,
                      Icons.bar_chart_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      theme,
                      '${habit.users} users',
                      Icons.people_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _toggleHabit(habit.id),
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
