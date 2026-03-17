class LixiTransaction {
  final int? id;
  final int userId;
  final String type; // 'received' or 'given'
  final double amount;
  final String personName;
  final int? categoryId;
  final String? note;
  final String? imagePath;
  final String date;
  final int year;
  final String createdAt;

  // Joined field (not stored in DB)
  final String? categoryName;

  LixiTransaction({
    this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.personName,
    this.categoryId,
    this.note,
    this.imagePath,
    required this.date,
    required this.year,
    required this.createdAt,
    this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'person_name': personName,
      'category_id': categoryId,
      'note': note,
      'image_path': imagePath,
      'date': date,
      'year': year,
      'created_at': createdAt,
    };
  }

  factory LixiTransaction.fromMap(Map<String, dynamic> map) {
    return LixiTransaction(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      personName: map['person_name'] as String,
      categoryId: map['category_id'] as int?,
      note: map['note'] as String?,
      imagePath: map['image_path'] as String?,
      date: map['date'] as String,
      year: map['year'] as int,
      createdAt: map['created_at'] as String,
      categoryName: map['category_name'] as String?,
    );
  }

  LixiTransaction copyWith({
    int? id,
    int? userId,
    String? type,
    double? amount,
    String? personName,
    int? categoryId,
    String? note,
    String? imagePath,
    String? date,
    int? year,
    String? createdAt,
    String? categoryName,
  }) {
    return LixiTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      personName: personName ?? this.personName,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  bool get isReceived => type == 'received';
  bool get isGiven => type == 'given';
}
