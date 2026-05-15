import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final HabitRepository _habitRepository = HabitRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aiController = TextEditingController();

  bool _useAI = false;
  bool _isParsing = false;
  bool _isSaving = false;
  String? _aiError;
  String _parsedDescription = '';

  late final List<HabitCategory> _categories;
  late final List<FrequencyOption> _frequencies;

  String _selectedCategory = 'Health';
  String _selectedFrequency = 'Daily';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _categories = _habitRepository.formCategories;
    _frequencies = _habitRepository.frequencies;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  Future<void> _parseWithAI() async {
    final text = _aiController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isParsing = true;
      _aiError = null;
    });

    try {
      final result = await AIService.parseHabitFromText(text);
      if (!mounted) return;

      _nameController.text = result['title'] ?? '';
      _parsedDescription = result['description'] ?? '';
      final category = result['category'] ?? 'Other';
      final validCategories = _categories.map((c) => c.label).toList();
      _selectedCategory = validCategories.contains(category) ? category : 'Other';
      _selectedFrequency = ['Daily', 'Weekdays', 'Weekends', 'Weekly', '3x / Week', 'Custom']
          .contains(result['duration'])
          ? result['duration']!
          : 'Daily';

      setState(() {
        _useAI = false;
        _isParsing = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('AI parse error: $e');
      setState(() {
        _isParsing = false;
        _aiError = 'Could not parse. Please try again or use manual mode.';
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticUtil.mediumImpact();

    final currentCount = _habitRepository.getMyHabits().length;
    final canAdd = await SubscriptionService().canAddHabit(currentCount: currentCount);
    if (!canAdd && mounted) {
      final upgrade = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Habit Limit Reached'),
          content: Text('You\'ve reached the free limit of ${SubscriptionService.freeMaxHabits} habits. Upgrade to Premium to add unlimited habits.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Upgrade', style: TextStyle(color: Colors.blue))),
          ],
        ),
      );

      if (upgrade == true && mounted) {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRoutes.paywallScreen);
      }
      return;
    }

    setState(() => _isSaving = true);

    String description = _parsedDescription;
    if (description.isEmpty) {
      try {
        description = await AIService.generateHabitDescription(
          _nameController.text.trim(), _selectedCategory, _selectedFrequency,
        );
      } catch (_) {
        description = 'A $_selectedFrequency $_selectedCategory habit.';
      }
    }

    final habitData = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'frequency': _selectedFrequency,
      'description': description,
      'reminderEnabled': _reminderEnabled,
      'reminderTime': _reminderEnabled ? _reminderTime.format(context) : null,
    };

    if (mounted) {
      Navigator.pop(context, habitData);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: theme.colorScheme.onSurface),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_useAI ? 'Quick Add' : 'New Habit', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: _useAI ? _buildAIMode(theme) : _buildManualMode(theme),
    );
  }

  Widget _buildModeToggle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _useAI = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_useAI ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, size: 16, color: !_useAI ? Colors.white : theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Manual', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: !_useAI ? Colors.white : theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _useAI = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _useAI ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: _useAI ? Colors.white : theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('AI Quick Add', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: _useAI ? Colors.white : theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMode(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildModeToggle(theme),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary.withValues(alpha: 0.08), theme.colorScheme.primaryContainer.withValues(alpha: 0.15)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Describe your habit', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Just type naturally and I\'ll set it up for you', style: GoogleFonts.dmSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              TextField(
                controller: _aiController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g., "I want to meditate for 10 minutes every morning"',
                  hintStyle: GoogleFonts.dmSans(fontSize: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              if (_aiError != null) ...[
                const SizedBox(height: 8),
                Text(_aiError!, style: GoogleFonts.dmSans(fontSize: 12, color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isParsing ? null : _parseWithAI,
                  icon: _isParsing
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(_isParsing ? 'Parsing...' : 'Parse Habit', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Try phrases like:', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        ...['"Read 20 pages before bed every night"', '"Go for a run on weekend mornings"', '"Practice guitar for 15 minutes daily"', '"Drink 8 glasses of water every day"'].map((example) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => _aiController.text = example.replaceAll('"', ''),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Text(example, style: GoogleFonts.dmSans(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildManualMode(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildModeToggle(theme),
          const SizedBox(height: 16),
          _buildSectionLabel(theme, 'Habit Name'),
          const SizedBox(height: 10),
          _buildNameField(theme),
          const SizedBox(height: 24),
          _buildSectionLabel(theme, 'Category'),
          const SizedBox(height: 12),
          _buildCategoryGrid(theme),
          const SizedBox(height: 24),
          _buildSectionLabel(theme, 'Frequency'),
          const SizedBox(height: 12),
          _buildFrequencyList(theme),
          const SizedBox(height: 24),
          _buildSectionLabel(theme, 'Reminder'),
          const SizedBox(height: 12),
          _buildReminderSection(theme),
          SizedBox(height: 3.h),
          _buildSaveButton(theme),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.8));
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'e.g., Morning Meditation',
        hintStyle: GoogleFonts.dmSans(fontSize: 15, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.primary),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.colorScheme.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.colorScheme.error, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter a habit name';
        if (value.trim().length < 3) return 'Name must be at least 3 characters';
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
      maxLength: 50,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
        return Text('$currentLength/$maxLength', style: GoogleFonts.dmSans(fontSize: 11, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)));
      },
    );
  }

  Widget _buildCategoryGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat.label;
        final color = cat.color;
        return GestureDetector(
          onTap: () { HapticUtil.selectionClick(); setState(() => _selectedCategory = cat.label); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
              boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, color: isSelected ? color : theme.colorScheme.onSurfaceVariant, size: 22),
                const SizedBox(height: 6),
                Text(cat.label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? color : theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrequencyList(ThemeData theme) {
    return Column(
      children: _frequencies.map((freq) {
        final isSelected = _selectedFrequency == freq.label;
        return GestureDetector(
          onTap: () { HapticUtil.selectionClick(); setState(() => _selectedFrequency = freq.label); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2), width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(freq.icon, size: 18, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(freq.label, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
                      Text(freq.description, style: GoogleFonts.dmSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.notifications_active_rounded, size: 18, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Reminder', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      Text('Get notified at your chosen time', style: GoogleFonts.dmSans(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Switch(
                  value: _reminderEnabled,
                  onChanged: (val) { HapticUtil.selectionClick(); setState(() => _reminderEnabled = val); },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          if (_reminderEnabled) ...[
            Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.15)),
            InkWell(
              onTap: _pickReminderTime,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text('Reminder Time', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3))),
                      child: Text(_formatTime(_reminderTime), style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF7C3AED))),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 10),
                  Text('Creating...', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text('Create Habit', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                ],
              ),
      ),
    );
  }
}
