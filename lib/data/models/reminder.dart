class Reminder {
  final int? id;
  final int userId;
  final String personName;
  final double? amount;
  final String remindDate;
  final String? note;
  final bool isDone;

  Reminder({
    this.id,
    required this.userId,
    required this.personName,
    this.amount,
    required this.remindDate,
    this.note,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'person_name': personName,
      'amount': amount,
      'remind_date': remindDate,
      'note': note,
      'is_done': isDone ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      personName: map['person_name'] as String,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      remindDate: map['remind_date'] as String,
      note: map['note'] as String?,
      isDone: (map['is_done'] as int?) == 1,
    );
  }

  Reminder copyWith({
    int? id,
    int? userId,
    String? personName,
    double? amount,
    String? remindDate,
    String? note,
    bool? isDone,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      remindDate: remindDate ?? this.remindDate,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
    );
  }
}
