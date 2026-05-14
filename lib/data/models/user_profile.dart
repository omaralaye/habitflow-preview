class UserProfile {
  final String name;
  final String avatar;
  final bool avatarIsFile;
  final String avatarType;
  final String semanticLabel;

  const UserProfile({
    required this.name,
    required this.avatar,
    this.avatarIsFile = false,
    this.avatarType = 'url',
    this.semanticLabel = '',
  });

  UserProfile copyWith({
    String? name,
    String? avatar,
    bool? avatarIsFile,
    String? avatarType,
    String? semanticLabel,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      avatarIsFile: avatarIsFile ?? this.avatarIsFile,
      avatarType: avatarType ?? this.avatarType,
      semanticLabel: semanticLabel ?? this.semanticLabel,
    );
  }
}

class Badge {
  final String icon;
  final String label;
  final int colorValue;

  const Badge({required this.icon, required this.label, required this.colorValue});
}
