import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar style variants
enum CustomAppBarStyle {
  /// Standard app bar with title and actions
  standard,

  /// Centered title with back button
  centered,

  /// Large title for main screens
  large,

  /// Transparent overlay for video player
  transparent,
}

/// Custom app bar optimized for workout context with clean minimal design
/// Implements top navigation pattern with contextual actions
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text
  final String? title;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Action widgets on the right
  final List<Widget>? actions;

  /// App bar style variant
  final CustomAppBarStyle style;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Background color override
  final Color? backgroundColor;

  /// Foreground color override
  final Color? foregroundColor;

  /// Elevation override
  final double? elevation;

  /// Bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  /// Custom height
  final double? height;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.style = CustomAppBarStyle.standard,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on style
    final bgColor =
        backgroundColor ??
        (style == CustomAppBarStyle.transparent
            ? Colors.transparent
            : colorScheme.surface);

    final fgColor = foregroundColor ?? colorScheme.onSurface;

    // Build based on style
    switch (style) {
      case CustomAppBarStyle.large:
        return _buildLargeAppBar(context, bgColor, fgColor);
      case CustomAppBarStyle.transparent:
        return _buildTransparentAppBar(context, fgColor);
      case CustomAppBarStyle.centered:
        return _buildCenteredAppBar(context, bgColor, fgColor);
      case CustomAppBarStyle.standard:
      default:
        return _buildStandardAppBar(context, bgColor, fgColor);
    }
  }

  Widget _buildStandardAppBar(
    BuildContext context,
    Color bgColor,
    Color fgColor,
  ) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation ?? 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? _buildDefaultLeading(context, fgColor),
      title:
          title != null
              ? Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(color: fgColor),
              )
              : null,
      actions: _buildActions(context, fgColor),
      bottom: bottom,
      systemOverlayStyle: _getSystemOverlayStyle(context),
    );
  }

  Widget _buildCenteredAppBar(
    BuildContext context,
    Color bgColor,
    Color fgColor,
  ) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation ?? 0,
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? _buildDefaultLeading(context, fgColor),
      title:
          title != null
              ? Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              )
              : null,
      actions: _buildActions(context, fgColor),
      bottom: bottom,
      systemOverlayStyle: _getSystemOverlayStyle(context),
    );
  }

  Widget _buildLargeAppBar(BuildContext context, Color bgColor, Color fgColor) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: fgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: height ?? 80,
        leading: leading,
        title:
            title != null
                ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    title!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                )
                : null,
        actions: _buildEnhancedActions(context, fgColor),
        bottom: bottom,
        systemOverlayStyle: _getSystemOverlayStyle(context),
      ),
    );
  }

  Widget _buildTransparentAppBar(BuildContext context, Color fgColor) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: fgColor,
      elevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? _buildTransparentLeading(context, fgColor),
      title:
          title != null
              ? Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
              )
              : null,
      actions: _buildTransparentActions(context, fgColor),
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget? _buildDefaultLeading(BuildContext context, Color color) {
    if (!automaticallyImplyLeading) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      color: color,
      iconSize: 24,
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
    );
  }

  Widget? _buildTransparentLeading(BuildContext context, Color color) {
    if (!automaticallyImplyLeading) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: color,
        iconSize: 24,
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context, Color color) {
    if (actions == null || actions!.isEmpty) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          color: color,
          iconSize: 24,
          onPressed: () {
            HapticFeedback.lightImpact();
            if (action.onPressed != null) action.onPressed!();
          },
        );
      }
      return action;
    }).toList();
  }

  List<Widget>? _buildTransparentActions(BuildContext context, Color color) {
    if (actions == null || actions!.isEmpty) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: action.icon,
            color: color,
            iconSize: 24,
            onPressed: () {
              HapticFeedback.lightImpact();
              if (action.onPressed != null) action.onPressed!();
            },
          ),
        );
      }
      return action;
    }).toList();
  }

  List<Widget>? _buildEnhancedActions(BuildContext context, Color color) {
    if (actions == null || actions!.isEmpty) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return Container(
          margin: const EdgeInsets.only(right: 4, left: 4),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: action.icon,
            color: color,
            iconSize: 22,
            onPressed: () {
              HapticFeedback.lightImpact();
              if (action.onPressed != null) action.onPressed!();
            },
          ),
        );
      }
      return action;
    }).toList();
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (style == CustomAppBarStyle.transparent) {
      return SystemUiOverlayStyle.light;
    }

    return brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    final toolbarHeight = height ?? kToolbarHeight;
    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
}

/// Workout-specific app bar with timer and controls
class CustomWorkoutAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Workout title
  final String workoutTitle;

  /// Current exercise name
  final String? currentExercise;

  /// Timer display
  final String? timerText;

  /// Whether workout is paused
  final bool isPaused;

  /// Callback for pause/resume
  final VoidCallback? onPauseResume;

  /// Callback for stop/exit
  final VoidCallback? onStop;

  const CustomWorkoutAppBar({
    super.key,
    required this.workoutTitle,
    this.currentExercise,
    this.timerText,
    this.isPaused = false,
    this.onPauseResume,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.close_rounded),
                iconSize: 24,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (onStop != null) {
                    onStop!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),

              const SizedBox(width: 8),

              // Workout info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workoutTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (currentExercise != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        currentExercise!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Timer
              if (timerText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    timerText!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],

              // Pause/Resume button
              if (onPauseResume != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                  iconSize: 24,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onPauseResume!();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
