class UserProfile {
  final String name;
  final String bio;
  final String avatarKey;
  final bool hasCompletedOnboarding;
  final DateTime joinedDate;

  UserProfile({
    this.name = 'Alex Morgan',
    this.bio = 'Habit building enthusiast striving for 1% improvement every day.',
    this.avatarKey = 'default',
    this.hasCompletedOnboarding = false,
    DateTime? joinedDate,
  }) : joinedDate = joinedDate ?? DateTime.now();

  UserProfile copyWith({
    String? name,
    String? bio,
    String? avatarKey,
    bool? hasCompletedOnboarding,
    DateTime? joinedDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarKey: avatarKey ?? this.avatarKey,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'avatarKey': avatarKey,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'joinedDate': joinedDate.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?) ?? 'Alex Morgan',
      bio: (json['bio'] as String?) ??
          'Habit building enthusiast striving for 1% improvement every day.',
      avatarKey: (json['avatarKey'] as String?) ?? 'default',
      hasCompletedOnboarding:
          (json['hasCompletedOnboarding'] as bool?) ?? false,
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : DateTime.now(),
    );
  }
}

