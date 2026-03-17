class User {
  final int? id;
  final String username;
  final String passwordHash;
  final String displayName;
  final String? avatarPath;
  final String createdAt;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.displayName,
    this.avatarPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'display_name': displayName,
      'avatar_path': avatarPath,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      displayName: map['display_name'] as String,
      avatarPath: map['avatar_path'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? displayName,
    String? avatarPath,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
