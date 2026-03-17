import 'package:flutter/material.dart';
import '../data/repositories/transaction_repository.dart';

class StatisticsViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();

  Map<String, double> _categoryStats = {};
  Map<int, Map<String, double>> _monthlyStats = {};
  double _totalReceived = 0;
  double _totalGiven = 0;
  int _selectedYear = DateTime.now().year;
  int? _compareYear;
  Map<int, Map<String, double>>? _compareMonthlyStats;
  bool _isLoading = false;

  Map<String, double> get categoryStats => _categoryStats;
  Map<int, Map<String, double>> get monthlyStats => _monthlyStats;
  double get totalReceived => _totalReceived;
  double get totalGiven => _totalGiven;
  int get selectedYear => _selectedYear;
  int? get compareYear => _compareYear;
  Map<int, Map<String, double>>? get compareMonthlyStats => _compareMonthlyStats;
  bool get isLoading => _isLoading;

  Future<void> loadStatistics(int userId, int year) async {
    _isLoading = true;
    _selectedYear = year;
    notifyListeners();

    _categoryStats = await _repo.getStatsByCategory(userId, year: year);
    _monthlyStats = await _repo.getStatsByMonth(userId, year);
    _totalReceived = await _repo.getTotalReceived(userId, year: year);
    _totalGiven = await _repo.getTotalGiven(userId, year: year);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCompareYear(int userId, int year) async {
    _compareYear = year;
    _compareMonthlyStats = await _repo.getStatsByMonth(userId, year);
    notifyListeners();
  }

  void clearCompare() {
    _compareYear = null;
    _compareMonthlyStats = null;
    notifyListeners();
  }

  Future<List<int>> getAvailableYears(int userId) async {
    return await _repo.getAvailableYears(userId);
  }
}
