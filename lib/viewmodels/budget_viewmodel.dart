import 'package:flutter/material.dart';
import '../data/models/budget_goal.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/transaction_repository.dart';

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepo = BudgetRepository();
  final TransactionRepository _transRepo = TransactionRepository();

  BudgetGoal? _currentGoal;
  double _totalSpent = 0;
  bool _isLoading = false;

  BudgetGoal? get currentGoal => _currentGoal;
  double get totalSpent => _totalSpent;
  double get remaining => (_currentGoal?.targetAmount ?? 0) - _totalSpent;
  double get progress => _currentGoal != null && _currentGoal!.targetAmount > 0
      ? (_totalSpent / _currentGoal!.targetAmount).clamp(0.0, 1.0)
      : 0.0;
  bool get isLoading => _isLoading;
  bool get hasGoal => _currentGoal != null;

  Future<void> loadBudget(int userId, int year) async {
    _isLoading = true;
    notifyListeners();

    _currentGoal = await _budgetRepo.getByYear(userId, year);
    _totalSpent = await _transRepo.getTotalGiven(userId, year: year);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setGoal(int userId, int year, double amount) async {
    final existing = await _budgetRepo.getByYear(userId, year);
    if (existing != null) {
      await _budgetRepo.update(BudgetGoal(
        id: existing.id,
        userId: userId,
        year: year,
        targetAmount: amount,
      ));
    } else {
      await _budgetRepo.insert(BudgetGoal(
        userId: userId,
        year: year,
        targetAmount: amount,
      ));
    }
    await loadBudget(userId, year);
  }

  Future<void> deleteGoal(int id, int userId, int year) async {
    await _budgetRepo.delete(id);
    await loadBudget(userId, year);
  }
}
