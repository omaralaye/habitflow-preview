import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';

/// Splash Screen for HabitFlow - Habit Tracker App
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  bool _isInitializing = true;
  String _statusMessage = 'Initializing...';
  final bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _setupBreathingAnimation();
    _initializeApp();
  }

  void _setupBreathingAnimation() {
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _breathingController.repeat(reverse: true);
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _statusMessage = 'Loading your habits...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _statusMessage = 'Checking streaks...');
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() => _statusMessage = 'Syncing progress...');
      await Future.delayed(const Duration(milliseconds: 700));

      setState(() => _statusMessage = 'Almost ready...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _isInitializing = false);

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          _hasCompletedOnboarding
              ? AppRoutes.navigationContainer
              : AppRoutes.onboardingFlow,
        );
      }
    } catch (e) {
      _handleInitializationError();
    }
  }

  void _handleInitializationError() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Issue'),
        content: const Text(
          'Unable to initialize HabitFlow. Please check your connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isInitializing = true;
                _statusMessage = 'Retrying...';
              });
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
              theme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'check_circle',
                      color: theme.colorScheme.primary,
                      size: 64,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'HabitFlow',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Build habits that last a lifetime',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 2),

              if (_isInitializing) ...[
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
