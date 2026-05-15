import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/models/exercise.dart';
import './widgets/breathing_guide_widget.dart';
import './widgets/exercise_timeline_widget.dart';
import './widgets/next_exercise_preview_widget.dart';
import './widgets/rep_counter_widget.dart';
import './widgets/timer_display_widget.dart';
import './widgets/video_player_widget.dart';

/// Workout Player Screen - Immersive full-screen exercise experience
class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  final ExerciseRepository _exerciseRepository = ExerciseRepository();
  late final List<Exercise> _exercises;

  // Workout state
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _currentReps = 0;
  bool _isResting = false;
  bool _isPaused = false;
  int _restTimeRemaining = 60;
  int _exerciseTimeElapsed = 0;

  // Timers
  Timer? _restTimer;
  Timer? _exerciseTimer;

  @override
  void initState() {
    super.initState();
    _exercises = _exerciseRepository.getExercises();
    _startExerciseTimer();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    super.dispose();
  }

  void _startExerciseTimer() {
    _exerciseTimer?.cancel();
    _exerciseTimeElapsed = 0;
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isResting) {
        setState(() {
          _exerciseTimeElapsed++;
        });
      }
    });
  }

  void _startRestTimer() {
    final currentExercise = _exercises[_currentExerciseIndex];
    _restTimeRemaining = currentExercise.restTime;

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _restTimeRemaining--;
        });

        if (_restTimeRemaining <= 0) {
          _completeRest();
        }
      }
    });
  }

  void _completeRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
    });
    _startExerciseTimer();
  }

  void _incrementRep() {
    final currentExercise = _exercises[_currentExerciseIndex];
    final targetReps = currentExercise.reps;

    setState(() {
      _currentReps++;
    });

    if (_currentReps >= targetReps) {
      _completeSet();
    }
  }

  void _decrementRep() {
    if (_currentReps > 0) {
      setState(() {
        _currentReps--;
      });
    }
  }

  void _completeSet() {
    final currentExercise = _exercises[_currentExerciseIndex];
    final totalSets = currentExercise.sets;

    if (_currentSet >= totalSets) {
      _moveToNextExercise();
    } else {
      setState(() {
        _currentSet++;
        _currentReps = 0;
        _isResting = true;
      });
      _exerciseTimer?.cancel();
      _startRestTimer();
      HapticUtil.heavyImpact();
    }
  }

  void _moveToNextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _currentReps = 0;
        _isResting = false;
      });
      _startExerciseTimer();
      HapticUtil.heavyImpact();
    } else {
      _completeWorkout();
    }
  }

  void _moveToPreviousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSet = 1;
        _currentReps = 0;
        _isResting = false;
      });
      _restTimer?.cancel();
      _startExerciseTimer();
      HapticUtil.lightImpact();
    }
  }

  void _skipRest() {
    _completeRest();
    HapticUtil.mediumImpact();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    HapticUtil.mediumImpact();
  }

  void _completeWorkout() {
    _exerciseTimer?.cancel();
    _restTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(),
    );
  }

  void _exitWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout?'),
        content:
            const Text('Your progress will be saved. You can resume later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildCompletionDialog() {
    final theme = Theme.of(context);
    final totalTime = _exerciseTimeElapsed;
    final totalExercises = _exercises.length;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'celebration',
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              'Workout Complete! ✨',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            Text(
              'Great job! You completed all exercises.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 3.h),

            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    icon: 'timer',
                    label: 'Total Time',
                    value: _formatTime(totalTime),
                    theme: theme,
                  ),
                  SizedBox(height: 2.h),
                  _buildStatRow(
                    icon: 'fitness_center',
                    label: 'Exercises',
                    value: '$totalExercises',
                    theme: theme,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentExercise = _exercises[_currentExerciseIndex];
    final nextExercise = _currentExerciseIndex < _exercises.length - 1
        ? _exercises[_currentExerciseIndex + 1]
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _exitWorkout,
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: theme.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Body Workout',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _togglePause,
                        icon: CustomIconWidget(
                          iconName: _isPaused ? 'play_arrow' : 'pause',
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Video player
                Expanded(
                  flex: 3,
                  child: _isResting
                      ? Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: BreathingGuideWidget(isActive: _isResting),
                        )
                      : VideoPlayerWidget(
                          videoUrl: currentExercise.videoUrl,
                        ),
                ),

                // Timer and controls
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        // Exercise name
                        Text(
                          currentExercise.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 2.h),

                        // Timer display
                        _isResting
                            ? TimerDisplayWidget(
                                timeText: _formatTime(_restTimeRemaining),
                                label: 'Rest Time',
                                isResting: true,
                              )
                            : TimerDisplayWidget(
                                timeText: _formatTime(_exerciseTimeElapsed),
                                label: 'Exercise Time',
                              ),

                        SizedBox(height: 3.h),

                        // Rep counter
                        if (!_isResting)
                          RepCounterWidget(
                            currentReps: _currentReps,
                            targetReps: currentExercise.reps,
                            currentSet: _currentSet,
                            totalSets: currentExercise.sets,
                            onRepIncrement: _incrementRep,
                            onRepDecrement: _decrementRep,
                          ),

                        SizedBox(height: 2.h),

                        // Navigation buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentExerciseIndex > 0
                                    ? _moveToPreviousExercise
                                    : null,
                                icon: CustomIconWidget(
                                  iconName: 'skip_previous',
                                  color: _currentExerciseIndex > 0
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.3),
                                  size: 20,
                                ),
                                label: const Text('Previous'),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _moveToNextExercise,
                                icon: CustomIconWidget(
                                  iconName: 'skip_next',
                                  color: theme.colorScheme.onPrimary,
                                  size: 20,
                                ),
                                label: const Text('Next'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Next exercise preview (during rest)
            if (_isResting && nextExercise != null)
              Positioned(
                bottom: 14.h,
                left: 0,
                right: 0,
                child: NextExercisePreviewWidget(
                  exerciseName: nextExercise.name,
                  imageUrl: nextExercise.imageUrl,
                  semanticLabel: nextExercise.semanticLabel,
                  sets: nextExercise.sets,
                  reps: nextExercise.reps,
                  onSkipRest: _skipRest,
                ),
              ),

            // Pause overlay
            if (_isPaused)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'pause_circle_outline',
                          color: Colors.white,
                          size: 80,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Paused',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        ElevatedButton.icon(
                          onPressed: _togglePause,
                          icon: CustomIconWidget(
                            iconName: 'play_arrow',
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                          label: const Text('Resume'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
