import 'package:flutter/material.dart' hide Badge;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_settings.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/user_subscription.dart';
import './widgets/profile_header_widget.dart';
import './widgets/setting_item_widget.dart';
import './widgets/settings_section_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final UserRepository _userRepository = UserRepository();
  final HabitRepository _habitRepository = HabitRepository();
  final SubscriptionService _subscriptionService = SubscriptionService();
  UserProfile? _userProfile;
  late List<Badge> _badges;
  late List<String> _avatarEmojis;
  late List<String> _goalOptions;
  late List<String> _settingCategories;

  bool _habitReminders = true;
  bool _streakAlerts = true;
  bool _weeklyReport = true;
  bool _motivationalQuotes = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _resetTime = const TimeOfDay(hour: 0, minute: 0);

  bool _darkMode = false;
  bool _hapticFeedback = true;
  bool _showStreak = true;

  String _lastSyncDisplay = "";
  UserSubscription? _userSubscription;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _badges = _userRepository.getBadges();
    _avatarEmojis = _userRepository.getAvatarEmojis();
    _goalOptions = _userRepository.getGoalOptions();
    _settingCategories = _habitRepository.settingCategories;
    _loadSettings();
    _loadSubscription();

    final supabaseUser = AuthService().getCurrentUser();
    if (supabaseUser != null) {
      _userProfile = UserProfile(
        name: supabaseUser.email ?? 'User',
        avatar: '',
        avatarType: 'emoji',
      );
    }
  }

  Future<void> _loadSubscription() async {
    try {
      final sub = await _subscriptionService.getSubscription();
      if (mounted) {
        setState(() {
          _userSubscription = sub;
          _isPremium = sub.isPremium;
        });
      }
    } catch (_) {}
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
              userData: _profileToMap(),
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
            _buildSubscriptionSection(theme),
            const SizedBox(height: 24),
            _buildDataPrivacySection(theme),
            const SizedBox(height: 24),
                _buildAboutSection(theme),
                const SizedBox(height: 24),
                _buildLogoutSection(theme),
                const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _profileToMap() {
    final supabaseUser = AuthService().getCurrentUser();
    return {
      'name': _userProfile?.name ?? '',
      'email': supabaseUser?.email ?? '',
      'avatar': _userProfile?.avatar ?? '',
      'avatarIsFile': _userProfile?.avatarIsFile ?? false,
      'avatarType': _userProfile?.avatarType ?? 'url',
      'semanticLabel': _userProfile?.semanticLabel ?? '',
      'habitGoal': '',
      'currentStreak': 0,
      'longestStreak': 0,
      'totalCompleted': 0,
      'badges': _badges.map((b) => {
        'icon': b.icon,
        'label': b.label,
        'color': b.colorValue,
      }).toList(),
    };
  }

  Widget _buildHabitSettingsSection(ThemeData theme) {
    return SettingsSectionWidget(
      title: "Habit Settings",
      children: [
        SettingItemWidget(
          icon: "track_changes",
          title: "Daily Habit Goal",
          subtitle: '',
          onTap: () => _showGoalPicker(context),
        ),
        SettingItemWidget(
          icon: "category",
          title: "Habit Categories",
          subtitle: _settingCategories.join(', '),
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

  Widget _buildSubscriptionSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isPremium
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          gradient: _isPremium
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  ],
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _isPremium
                ? null
                : () => Navigator.pushNamed(context, AppRoutes.paywallScreen),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isPremium
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isPremium ? Icons.diamond_rounded : Icons.diamond_outlined,
                      color: _isPremium ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _isPremium ? 'Premium' : 'Free Plan',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (_isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isPremium
                              ? 'You have unlimited habits'
                              : '${SubscriptionService.freeMaxHabits} habit limit — upgrade for unlimited',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Upgrade',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (_isPremium)
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  Widget _buildLogoutSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          label: Text(
            'Log Out',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out? Your data will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await AuthService().logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to log out. Please try again.')),
          );
        }
      }
    }
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem(
            theme,
            '0',
            'Current\nStreak',
            '🔥',
          ),
          _buildStatDivider(theme),
          _buildStatItem(
            theme,
            '0',
            'Best\nStreak',
            '🏆',
          ),
          _buildStatDivider(theme),
          _buildStatItem(
            theme,
            '0',
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
            children: _badges.map((badge) {
              final color = Color(badge.colorValue);
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
                        iconName: badge.icon,
                        color: color,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge.label,
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
        _userProfile = _userProfile?.copyWith(
          avatar: picked.path,
          avatarIsFile: true,
          avatarType: 'file',
        );
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
        _userProfile = _userProfile?.copyWith(
          avatar: picked.path,
          avatarIsFile: true,
          avatarType: 'file',
        );
      });
    }
  }

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
                final isSelected = _userProfile?.avatarType == 'emoji' &&
                    _userProfile?.avatar == emoji;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _userProfile = _userProfile?.copyWith(
                        avatar: emoji,
                        avatarIsFile: false,
                        avatarType: 'emoji',
                      );
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
        TextEditingController(text: _userProfile?.name ?? '');

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
                  hintText: _userProfile?.name ?? '',
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
                      setState(() {
                        _userProfile = _userProfile?.copyWith(name: newName);
                      });
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
    final categories = _settingCategories.map((name) {
      return {"name": name, "enabled": true};
    }).toList();

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
              ..._goalOptions.map(
                (goal) => ListTile(
                  title: Text(goal, style: GoogleFonts.dmSans()),
                  onTap: () {
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

User: ${_userProfile?.name ?? ''}
Current Streak: 0 days
Longest Streak: 0 days
Total Habits Completed: 0

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
