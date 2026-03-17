class BudgetGoal {
  final int? id;
  final int userId;
  final int year;
  final double targetAmount;

  BudgetGoal({
    this.id,
    required this.userId,
    required this.year,
    required this.targetAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'year': year,
      'target_amount': targetAmount,
    };
  }

  factory BudgetGoal.fromMap(Map<String, dynamic> map) {
    return BudgetGoal(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      year: map['year'] as int,
      targetAmount: (map['target_amount'] as num).toDouble(),
    );
  }
}
