import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowfit/routes/app_routes.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/setting_item_widget.dart';
import './widgets/settings_section_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final Map<String, dynamic> _userData = {
    "name": "Alex Johnson",
    "avatar":
        "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
    "semanticLabel":
        "Profile photo of a young man with short brown hair wearing a casual shirt, smiling confidently",
    "habitGoal": "Build 6 daily habits",
    "currentStreak": 14,
    "longestStreak": 21,
    "totalCompleted": 287,
    "badges": [
      {
        "icon": "local_fire_department",
        "label": "14 Day Streak",
        "color": 0xFFFF6B35,
      },
      {"icon": "emoji_events", "label": "100 Habits Done", "color": 0xFFFBBF24},
      {"icon": "check_circle", "label": "Perfect Week", "color": 0xFF00C896},
    ],
  };

  bool _habitReminders = true;
  bool _streakAlerts = true;
  bool _weeklyReport = true;
  bool _motivationalQuotes = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  bool _darkMode = false;
  bool _hapticFeedback = true;
  bool _showStreak = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Profile & Settings',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notificationsScreen),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ProfileHeaderWidget(userData: _userData),
            const SizedBox(height: 8),
            _buildStatsRow(theme),
            const SizedBox(height: 24),
            _buildBadgesSection(theme),
            const SizedBox(height: 24),
            SettingsSectionWidget(
              title: "Habit Settings",
              children: [
                SettingItemWidget(
                  icon: "track_changes",
                  title: "Daily Habit Goal",
                  subtitle: _userData["habitGoal"],
                  onTap: () => _showGoalPicker(context),
                ),
                SettingItemWidget(
                  icon: "category",
                  title: "Habit Categories",
                  subtitle: "Health, Mindfulness, Learning",
                  onTap: () {},
                ),
                SettingItemWidget(
                  icon: "schedule",
                  title: "Reset Time",
                  subtitle: "Midnight (12:00 AM)",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSectionWidget(
              title: "Notifications",
              children: [
                SettingItemWidget(
                  icon: "notifications",
                  title: "Habit Reminders",
                  trailing: Switch(
                    value: _habitReminders,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _habitReminders = value);
                    },
                  ),
                ),
                SettingItemWidget(
                  icon: "schedule",
                  title: "Reminder Time",
                  subtitle: _reminderTime.format(context),
                  onTap: () => _showTimePicker(context),
                  enabled: _habitReminders,
                ),
                SettingItemWidget(
                  icon: "local_fire_department",
                  title: "Streak Alerts",
                  subtitle: "Get notified before losing your streak",
                  trailing: Switch(
                    value: _streakAlerts,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _streakAlerts = value);
                    },
                  ),
                ),
                SettingItemWidget(
                  icon: "bar_chart",
                  title: "Weekly Report",
                  subtitle: "Summary every Sunday",
                  trailing: Switch(
                    value: _weeklyReport,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _weeklyReport = value);
                    },
                  ),
                ),
                SettingItemWidget(
                  icon: "format_quote",
                  title: "Motivational Quotes",
                  trailing: Switch(
                    value: _motivationalQuotes,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _motivationalQuotes = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSectionWidget(
              title: "Appearance",
              children: [
                SettingItemWidget(
                  icon: "dark_mode",
                  title: "Dark Mode",
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _darkMode = value);
                    },
                  ),
                ),
                SettingItemWidget(
                  icon: "vibration",
                  title: "Haptic Feedback",
                  trailing: Switch(
                    value: _hapticFeedback,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _hapticFeedback = value);
                    },
                  ),
                ),
                SettingItemWidget(
                  icon: "local_fire_department",
                  title: "Show Streak Counter",
                  trailing: Switch(
                    value: _showStreak,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _showStreak = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSectionWidget(
              title: "Data & Privacy",
              children: [
                SettingItemWidget(
                  icon: "backup",
                  title: "Backup & Sync",
                  subtitle: "Last synced: 2 hours ago",
                  onTap: () {},
                ),
                SettingItemWidget(
                  icon: "download",
                  title: "Export Data",
                  subtitle: "Download your habit history",
                  onTap: () {},
                ),
                SettingItemWidget(
                  icon: "delete_outline",
                  title: "Reset All Habits",
                  subtitle: "This cannot be undone",
                  onTap: () => _showResetConfirmation(context),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSectionWidget(
              title: "About",
              children: [
                SettingItemWidget(
                  icon: "info_outline",
                  title: "App Version",
                  subtitle: "HabitFlow v1.0.0",
                ),
                SettingItemWidget(
                  icon: "star_outline",
                  title: "Rate HabitFlow",
                  onTap: () {},
                ),
                SettingItemWidget(
                  icon: "share",
                  title: "Share with Friends",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem(
            theme,
            '${_userData['currentStreak']}',
            'Current\nStreak',
            '🔥',
          ),
          _buildStatDivider(theme),
          _buildStatItem(
            theme,
            '${_userData['longestStreak']}',
            'Best\nStreak',
            '🏆',
          ),
          _buildStatDivider(theme),
          _buildStatItem(
            theme,
            '${_userData['totalCompleted']}',
            'Total\nDone',
            '✅',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label,
    String emoji,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.colorScheme.outline.withValues(alpha: 0.15),
    );
  }

  Widget _buildBadgesSection(ThemeData theme) {
    final badges = _userData['badges'] as List<Map<String, dynamic>>;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: badges.map((badge) {
              final color = Color(badge['color'] as int);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: badge['icon'] as String,
                        color: color,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge['label'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
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

  void _showEditProfile(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit Profile',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: _userData['name'] as String,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalPicker(BuildContext context) {
    final theme = Theme.of(context);
    final goals = [
      '3 habits/day',
      '4 habits/day',
      '5 habits/day',
      '6 habits/day',
      '7+ habits/day',
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Habit Goal',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...goals.map(
                (goal) => ListTile(
                  title: Text(goal, style: GoogleFonts.dmSans()),
                  trailing: _userData['habitGoal'] == 'Build $goal'
                      ? Icon(
                          Icons.check_rounded,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() => _userData['habitGoal'] = 'Build $goal');
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset All Habits?',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete all your habits and progress. This cannot be undone.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Reset', style: GoogleFonts.dmSans(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {}
}
