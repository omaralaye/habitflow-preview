import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';

class HabitAnalysisScreen extends StatefulWidget {
  const HabitAnalysisScreen({super.key});

  @override
  State<HabitAnalysisScreen> createState() => _HabitAnalysisScreenState();
}

class _HabitAnalysisScreenState extends State<HabitAnalysisScreen> {
  String? _analysis;
  String? _scheduleSuggestion;
  bool _isLoadingAnalysis = true;
  bool _isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = HabitRepository();
    final progress = ProgressRepository();
    final habits = repo.getTodayHabits();
    final stats = progress.getOverallStats();

    try {
      final analysis = await AIService.analyzeHabits(habits: habits, stats: stats);
      if (mounted) setState(() { _analysis = analysis; _isLoadingAnalysis = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingAnalysis = false);
    }

    try {
      final schedule = await AIService.suggestSchedule(habits: habits, stats: stats);
      if (mounted) setState(() { _scheduleSuggestion = schedule; _isLoadingSchedule = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingSchedule = false);
    }
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
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Habit Analysis', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPatternCard(theme),
            SizedBox(height: 2.h),
            _buildScheduleCard(theme),
            SizedBox(height: 2.h),
            _buildCoachCard(theme),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.insights_rounded, color: Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 12),
              Text('Pattern Analysis', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingAnalysis)
            Row(
              children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
                const SizedBox(width: 10),
                Text('Analyzing your patterns...', style: GoogleFonts.dmSans(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ],
            )
          else if (_analysis != null && _analysis!.isNotEmpty)
            Text(_analysis!, style: GoogleFonts.dmSans(fontSize: 14, color: theme.colorScheme.onSurface, height: 1.6))
          else
            Text('Add some habits and track them for a few days to get personalized analysis.', style: GoogleFonts.dmSans(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF00C896).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.schedule_rounded, color: Color(0xFF00C896), size: 22),
              ),
              const SizedBox(width: 12),
              Text('Schedule Suggestions', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingSchedule)
            Row(
              children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
                const SizedBox(width: 10),
                Text('Optimizing your schedule...', style: GoogleFonts.dmSans(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
              ],
            )
          else if (_scheduleSuggestion != null && _scheduleSuggestion!.isNotEmpty)
            Text(_scheduleSuggestion!, style: GoogleFonts.dmSans(fontSize: 14, color: theme.colorScheme.onSurface, height: 1.6))
          else
            Text('Keep tracking to get personalized schedule recommendations.', style: GoogleFonts.dmSans(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildCoachCard(ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.aiCoachScreen),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.chat_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Want to dig deeper?', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Chat with your AI Coach about these patterns', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
