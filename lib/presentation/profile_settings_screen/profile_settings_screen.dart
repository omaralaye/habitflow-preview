import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_settings.dart';
import '../../routes/app_routes.dart';
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
    "avatarIsFile": false,
    "avatarType": "url",
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
  bool _motivationalQuotes = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _resetTime = const TimeOfDay(hour: 0, minute: 0);

  bool _darkMode = false;
  bool _hapticFeedback = true;
  bool _showStreak = true;

  String _lastSyncDisplay = "Last synced: 2 hours ago";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _motivationalQuotes = AppSettings.motivationalQuotes;
    _darkMode = AppSettings.themeModeNotifier.value == ThemeMode.dark;
    _hapticFeedback = AppSettings.hapticEnabled;
    _showStreak = AppSettings.showStreak;
    _resetTime = TimeOfDay(hour: AppSettings.resetHour, minute: AppSettings.resetMinute);
  }

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
            ProfileHeaderWidget(
              userData: _userData,
              onEditPhoto: () => _showPhotoSourcePicker(context),
            ),
            const SizedBox(height: 8),
            _buildStatsRow(theme),
            const SizedBox(height: 24),
            _buildBadgesSection(theme),
            const SizedBox(height: 24),
            _buildHabitSettingsSection(theme),
            const SizedBox(height: 24),
            _buildNotificationsSection(theme),
            const SizedBox(height: 24),
            _buildAppearanceSection(theme),
            const SizedBox(height: 24),
            _buildDataPrivacySection(theme),
            const SizedBox(height: 24),
            _buildAboutSection(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitSettingsSection(ThemeData theme) {
    return SettingsSectionWidget(
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
          onTap: () => _showHabitCategories(context),
        ),
        SettingItemWidget(
          icon: "schedule",
          title: "Reset Time",
          subtitle: _resetTime.format(context),
          onTap: () => _showResetTimePicker(context),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(ThemeData theme) {
    return SettingsSectionWidget(
      title: "Notifications",
      children: [
        SettingItemWidget(
          icon: "notifications",
          title: "Habit Reminders",
          trailing: Switch(
            value: _habitReminders,
            onChanged: (value) {
              HapticUtil.lightImpact();
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
              HapticUtil.lightImpact();
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
              HapticUtil.lightImpact();
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
              HapticUtil.lightImpact();
              AppSettings.setMotivationalQuotes(value);
              setState(() => _motivationalQuotes = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(ThemeData theme) {
    return SettingsSectionWidget(
      title: "Appearance",
      children: [
        SettingItemWidget(
          icon: "dark_mode",
          title: "Dark Mode",
          trailing: Switch(
            value: _darkMode,
            onChanged: (value) {
              HapticUtil.lightImpact();
              AppSettings.setDarkMode(value);
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
              HapticUtil.lightImpact();
              AppSettings.setHapticEnabled(value);
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
              HapticUtil.lightImpact();
              AppSettings.setShowStreak(value);
              setState(() => _showStreak = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataPrivacySection(ThemeData theme) {
    return SettingsSectionWidget(
      title: "Data & Privacy",
      children: [
        SettingItemWidget(
          icon: "backup",
          title: "Backup & Sync",
          subtitle: _lastSyncDisplay,
          onTap: () => _showBackupSync(context),
        ),
        SettingItemWidget(
          icon: "download",
          title: "Export Data",
          subtitle: "Download your habit history",
          onTap: () => _exportData(context),
        ),
        SettingItemWidget(
          icon: "delete_outline",
          title: "Reset All Habits",
          subtitle: "This cannot be undone",
          onTap: () => _showResetConfirmation(context),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return SettingsSectionWidget(
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
          onTap: () => _rateApp(context),
        ),
        SettingItemWidget(
          icon: "share",
          title: "Share with Friends",
          onTap: () => _shareApp(context),
        ),
      ],
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

  void _showPhotoSourcePicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
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
            Text('Change Profile Photo',
                style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 20),
            _photoOption(ctx, theme, Icons.camera_alt_rounded, 'Take Photo',
                () => _pickFromCamera(ctx)),
            _photoOption(ctx, theme, Icons.photo_library_rounded,
                'Choose from Gallery', () => _pickFromGallery(ctx)),
            _photoOption(ctx, theme, Icons.emoji_emotions_rounded,
                'Choose Emoji', () => _showEmojiPicker(ctx)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(BuildContext ctx, ThemeData theme, IconData icon,
      String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title:
          Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  void _pickFromCamera(BuildContext ctx) async {
    Navigator.pop(ctx);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (picked != null && mounted) {
      setState(() {
        _userData['avatar'] = picked.path;
        _userData['avatarIsFile'] = true;
        _userData['avatarType'] = 'file';
      });
    }
  }

  void _pickFromGallery(BuildContext ctx) async {
    Navigator.pop(ctx);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
    );
    if (picked != null && mounted) {
      setState(() {
        _userData['avatar'] = picked.path;
        _userData['avatarIsFile'] = true;
        _userData['avatarType'] = 'file';
      });
    }
  }

  final List<String> _avatarEmojis = [
    '😀', '😎', '🔥', '💪', '🧠', '🌟', '🎯', '🚀',
    '🌈', '🦋', '🌻', '🍀', '🐉', '🦅', '🐺', '🦁',
    '👨‍💻', '👩‍🎨', '🧘', '🏃', '🧗', '🤸', '🎨', '📚',
  ];

  void _showEmojiPicker(BuildContext ctx) {
    final theme = Theme.of(ctx);
    Navigator.pop(ctx);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text('Choose an Emoji',
                style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _avatarEmojis.map((emoji) {
                final isSelected = _userData['avatarType'] == 'emoji' &&
                    _userData['avatar'] == emoji;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _userData['avatar'] = emoji;
                      _userData['avatarIsFile'] = false;
                      _userData['avatarType'] = 'emoji';
                    });
                    Navigator.pop(sheetCtx);
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 28))),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final theme = Theme.of(context);
    final nameController =
        TextEditingController(text: _userData['name'] as String);

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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      color: theme.colorScheme.primary, size: 20),
                ),
                title: Text('Change Profile Photo',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _showPhotoSourcePicker(context);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
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
                  onPressed: () {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      setState(() => _userData['name'] = newName);
                    }
                    Navigator.pop(context);
                  },
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

  void _showHabitCategories(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      {"name": "Health", "icon": "favorite", "enabled": true},
      {"name": "Mindfulness", "icon": "self_improvement", "enabled": true},
      {"name": "Learning", "icon": "menu_book", "enabled": true},
      {"name": "Fitness", "icon": "directions_walk", "enabled": true},
      {"name": "Productivity", "icon": "trending_up", "enabled": true},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Habit Categories',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ...categories.asMap().entries.map((entry) {
                final cat = entry.value;
                final enabled = cat['enabled'] as bool;
                return ListTile(
                  leading: Icon(
                    Icons.check_circle_rounded,
                    color: enabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  title: Text(
                    cat['name'] as String,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Switch(
                    value: enabled,
                    onChanged: (v) {
                      HapticUtil.lightImpact();
                      setSheetState(() => cat['enabled'] = v);
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Done',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _resetTime,
      helpText: 'Select reset time',
    );
    if (picked != null) {
      await AppSettings.setResetTime(picked.hour, picked.minute);
      setState(() => _resetTime = picked);
    }
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

  void _showBackupSync(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Backup & Sync',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.cloud_done_rounded,
                    color: theme.colorScheme.primary, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cloud Backup',
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_lastSyncDisplay,
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticUtil.lightImpact();
                  setState(() {
                    final now = DateTime.now();
                    _lastSyncDisplay =
                        'Last synced: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync completed successfully')),
                  );
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.sync_rounded),
                label: Text('Sync Now',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final data = '''
HabitFlow Data Export - $dateStr

User: ${_userData['name']}
Current Streak: ${_userData['currentStreak']} days
Longest Streak: ${_userData['longestStreak']} days
Total Habits Completed: ${_userData['totalCompleted']}

Generated by HabitFlow v1.0.0
''';

    await SharePlus.instance.share(
      ShareParams(
        text: data,
        subject: 'HabitFlow Data Export - $dateStr',
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Habits'),
        content: const Text(
          'This will permanently delete all your habits and streaks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _userData['currentStreak'] = 0;
                _userData['longestStreak'] = 0;
                _userData['totalCompleted'] = 0;
              });
              AppSettings.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _rateApp(BuildContext context) async {
    final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.habitflow.app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open app store')),
        );
      }
    }
  }

  void _shareApp(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out HabitFlow - the best habit tracking app!',
        subject: 'Join me on HabitFlow',
      ),
    );
  }
}
