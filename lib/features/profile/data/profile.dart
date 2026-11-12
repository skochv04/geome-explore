/// Model wiersza z tabeli `profiles`.
class Profile {
  const Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
