import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onEditPhoto;

  const ProfileHeaderWidget({super.key, required this.userData, this.onEditPhoto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _buildAvatarContent(theme),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    HapticUtil.lightImpact();
                    onEditPhoto?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            userData["name"] as String,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 4),

          // Email / logged-in indicator
          if (userData["email"] != null && (userData["email"] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                userData["email"] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          const SizedBox(height: 6),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                "${userData["currentStreak"]} day streak",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              const Text('✅', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                "${userData["totalCompleted"]} habits done",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Achievement badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (userData["badges"] as List).map((badge) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildBadge(
                  context,
                  badge["icon"] as String,
                  badge["label"] as String,
                  Color(badge["color"] as int),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(ThemeData theme) {
    final avatarType = userData['avatarType'] as String? ?? 'url';
    if (avatarType == 'emoji') {
      return Container(
        width: 100,
        height: 100,
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: Center(
          child: Text(
            userData['avatar'] as String? ?? '😀',
            style: const TextStyle(fontSize: 44),
          ),
        ),
      );
    }
    return CustomImageWidget(
      imageUrl: userData["avatar"] as String,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      semanticLabel: userData["semanticLabel"] as String? ?? 'Profile photo',
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String icon,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomIconWidget(iconName: icon, color: color, size: 24),
      ),
    );
  }
}
