class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.membershipTier,
    required this.loyaltyPoints,
  });

  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String
  membershipTier; // 'Silver Explorer', 'Gold Nomad', 'Platinum Voyager'
  final int loyaltyPoints;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? membershipTier,
    int? loyaltyPoints,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      membershipTier: membershipTier ?? this.membershipTier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }

  factory UserProfile.defaultUser() {
    return const UserProfile(
      id: 'usr_001',
      name: 'Elena Rostova',
      email: 'elena.rostova@flutter.dev',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
      membershipTier: 'Platinum Voyager',
      loyaltyPoints: 4850,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserProfile && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
