class RelativeCategory {
  final int? id;
  final int userId;
  final String name;
  final String icon;

  RelativeCategory({
    this.id,
    required this.userId,
    required this.name,
    this.icon = 'people',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
    };
  }

  factory RelativeCategory.fromMap(Map<String, dynamic> map) {
    return RelativeCategory(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String? ?? 'people',
    );
  }

  RelativeCategory copyWith({
    int? id,
    int? userId,
    String? name,
    String? icon,
  }) {
    return RelativeCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}
