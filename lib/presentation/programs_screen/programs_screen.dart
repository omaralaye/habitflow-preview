import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_settings.dart';
import '../../core/challenge_manager.dart';
import '../../data/repositories/challenge_repository.dart';
import '../../data/models/challenge.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen>
    with SingleTickerProviderStateMixin {
  final ChallengeRepository _challengeRepository = ChallengeRepository();
  late TabController _tabController;
  late final List<Challenge> _availableChallenges;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _availableChallenges = _challengeRepository.getAvailableChallenges();
    ChallengeManager.addListener(_onChallengesChanged);
  }

  @override
  void dispose() {
    ChallengeManager.removeListener(_onChallengesChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onChallengesChanged() {
    if (mounted) setState(() {});
  }

  Map<String, dynamic> _challengeToMap(Challenge c) {
    return {
      'id': c.id,
      'title': c.title,
      'description': c.description,
      'icon': c.icon,
      'color': c.colorValue,
      'duration': c.duration,
      'difficulty': c.difficulty,
      'participants': c.participants,
      'rating': c.rating,
      'category': c.category,
    };
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
          tabs: [
            Tab(text: 'Active (${ChallengeManager.activeChallenges.length})'),
            const Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveTab(theme),
          _buildDiscoverTab(theme),
        ],
      ),
    );
  }

  Widget _buildActiveTab(ThemeData theme) {
    final activeList = ChallengeManager.activeChallenges;
    if (activeList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded,
                  size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text('No active challenges',
                  style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('Join a challenge from the Discover tab to get started!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeList.length,
      itemBuilder: (context, index) {
        final challenge = activeList[index];
        final color = Color(challenge['color'] as int);
        final currentDay = challenge['currentDay'] as int;
        final totalDays = challenge['totalDays'] as int;
        final progress = totalDays > 0 ? currentDay / totalDays : 0.0;
        final todayDone = ChallengeManager.isTodayComplete(challenge['id'] as int);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
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
                        IconData(challenge['icon'] as int,
                            fontFamily: 'MaterialIcons'),
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
                                horizontal: 8, vertical: 3),
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
                            challenge['title'] as String,
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
                      'Day $currentDay of $totalDays',
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
                    value: progress.clamp(0.0, 1.0),
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
                      Icon(
                        todayDone ? Icons.check_circle_rounded : Icons.task_alt_rounded,
                        color: todayDone ? color : color,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        todayDone
                            ? 'Completed! 🎉'
                            : (challenge['dailyTask'] as String? ??
                                'Complete today\'s challenge'),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: todayDone
                              ? color
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showChallengeDetail(theme, challenge, color),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: Text('Details',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: todayDone
                            ? null
                            : () {
                                HapticUtil.mediumImpact();
                                ChallengeManager.markDayComplete(
                                    challenge['id'] as int);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Day ${(challenge['currentDay'] as int) + 1} complete! 🎉',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                        icon: Icon(
                            todayDone
                                ? Icons.check_circle_rounded
                                : Icons.check_rounded,
                            size: 18),
                        label: Text(
                            todayDone ? 'Done ✓' : 'Mark Done',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              color.withValues(alpha: 0.3),
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Leave Challenge'),
                          content: Text('Are you sure you want to leave "${challenge['title']}"? Your progress will be lost.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        ChallengeManager.leaveChallenge(challenge['id'] as int);
                      }
                    },
                    icon: Icon(Icons.logout_rounded, size: 16, color: Colors.red.shade400),
                    label: Text('Leave Challenge', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.red.shade400)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscoverTab(ThemeData theme) {
    final activeIds =
        ChallengeManager.activeChallenges.map((c) => c['id'] as int).toSet();
    final available =
        _availableChallenges.where((c) => !activeIds.contains(c.id)).toList();

    if (available.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration_rounded,
                  size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('All challenges joined!',
                  style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('Great job! Check back for new challenges soon.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: available.length,
      itemBuilder: (context, index) {
        final challenge = available[index];
        final color = challenge.color;

        return GestureDetector(
          onTap: () => _showChallengeDetail(theme, _challengeToMap(challenge), color),
          child: Container(
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
                        challenge.icon,
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
                            challenge.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.people_rounded,
                                  size: 13,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 3),
                              Text('${challenge.participants} joined',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color:
                                          theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 10),
                              Icon(Icons.star_rounded,
                                  size: 13, color: const Color(0xFFFBBF24)),
                              const SizedBox(width: 3),
                              Text('${challenge.rating}',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color:
                                          theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  challenge.description,
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
                    _buildTag(theme, challenge.duration,
                        Icons.calendar_today_rounded),
                    const SizedBox(width: 8),
                    _buildTag(theme, challenge.difficulty,
                        Icons.bar_chart_rounded),
                    const SizedBox(width: 8),
                    _buildTag(theme, challenge.category,
                        Icons.label_rounded),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        HapticUtil.lightImpact();
                        ChallengeManager.joinChallenge(_challengeToMap(challenge));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Joined ${challenge.title}! 🎉'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Join',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
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
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _showChallengeDetail(
      ThemeData theme, Map<String, dynamic> challenge, Color color) {
    final isActive = ChallengeManager.isJoined(challenge['id'] as int);
    final totalDays = isActive
        ? challenge['totalDays'] as int
        : _extractDays(challenge['duration'] as String? ?? '30 days');
    final currentDay =
        isActive ? challenge['currentDay'] as int : 0;
    final progress = totalDays > 0 ? currentDay / totalDays : 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
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
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isActive
                          ? IconData(challenge['icon'] as int,
                              fontFamily: 'MaterialIcons')
                          : challenge['icon'] as IconData,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(challenge['title'] as String,
                            style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(
                            '${challenge['participants']} participants',
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color:
                                    theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(challenge['description'] as String,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4)),
              if (isActive) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildDetailStat(
                        theme, 'Day $currentDay', 'of $totalDays'),
                    const SizedBox(width: 24),
                    _buildDetailStat(
                        theme, '${(progress * 100).toInt()}%', 'Complete'),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildDetailStat(
                        theme, challenge['duration'] as String, 'Duration'),
                    const SizedBox(width: 24),
                    _buildDetailStat(
                        theme, challenge['difficulty'] as String,
                        'Difficulty'),
                    const SizedBox(width: 24),
                    _buildDetailStat(
                        theme, challenge['category'] as String, 'Category'),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (!isActive) {
                      ChallengeManager.joinChallenge(challenge);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Joined ${challenge['title']}! 🎉'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isActive ? 'Continue Challenge' : 'Join Challenge',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Leave Challenge'),
                          content: Text('Are you sure you want to leave "${challenge['title']}"? Your progress will be lost.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                      ).then((confirmed) {
                        if (confirmed == true) {
                          ChallengeManager.leaveChallenge(challenge['id'] as int);
                        }
                      });
                    },
                    icon: Icon(Icons.logout_rounded, size: 16, color: Colors.red.shade400),
                    label: Text('Leave Challenge', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.red.shade400)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(ThemeData theme, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface)),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  int _extractDays(String duration) {
    final match = RegExp(r'(\d+)').firstMatch(duration);
    return match != null ? int.parse(match.group(1)!) : 30;
  }
}
