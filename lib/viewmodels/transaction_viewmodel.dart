import 'package:flutter/material.dart';
import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

enum TransactionFilter { all, received, given }
enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc, nameAsc, nameDesc }

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();

  List<LixiTransaction> _transactions = [];
  List<LixiTransaction> _filteredTransactions = [];
  double _totalReceived = 0;
  double _totalGiven = 0;
  bool _isLoading = false;
  String _searchQuery = '';
  TransactionFilter _filter = TransactionFilter.all;
  TransactionSort _sort = TransactionSort.dateDesc;
  int? _selectedYear;

  List<LixiTransaction> get transactions => _filteredTransactions;
  double get totalReceived => _totalReceived;
  double get totalGiven => _totalGiven;
  double get balance => _totalReceived - _totalGiven;
  bool get isLoading => _isLoading;
  TransactionFilter get filter => _filter;
  TransactionSort get sort => _sort;
  int? get selectedYear => _selectedYear;
  String get searchQuery => _searchQuery;

  Future<void> loadTransactions(int userId, {int? year}) async {
    _isLoading = true;
    notifyListeners();

    _selectedYear = year;
    _transactions = await _repo.getAll(userId, year: year);
    _totalReceived = await _repo.getTotalReceived(userId, year: year);
    _totalGiven = await _repo.getTotalGiven(userId, year: year);
    _applyFilterAndSort();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(LixiTransaction transaction) async {
    await _repo.insert(transaction);
    await loadTransactions(transaction.userId, year: _selectedYear);
  }

  Future<void> updateTransaction(LixiTransaction transaction) async {
    await _repo.update(transaction);
    await loadTransactions(transaction.userId, year: _selectedYear);
  }

  Future<void> deleteTransaction(int id, int userId) async {
    await _repo.delete(id);
    await loadTransactions(userId, year: _selectedYear);
  }

  Future<List<LixiTransaction>> getRecentTransactions(int userId, {int limit = 5}) async {
    return await _repo.getRecentTransactions(userId, limit: limit);
  }

  Future<double> getSuggestedAmount(int userId, int categoryId) async {
    return await _repo.getAverageByCategory(userId, categoryId);
  }

  Future<List<int>> getAvailableYears(int userId) async {
    return await _repo.getAvailableYears(userId);
  }

  void setFilter(TransactionFilter filter) {
    _filter = filter;
    _applyFilterAndSort();
    notifyListeners();
  }

  void setSort(TransactionSort sort) {
    _sort = sort;
    _applyFilterAndSort();
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    _applyFilterAndSort();
    notifyListeners();
  }

  void _applyFilterAndSort() {
    var list = List<LixiTransaction>.from(_transactions);

    // Apply filter
    switch (_filter) {
      case TransactionFilter.received:
        list = list.where((t) => t.isReceived).toList();
        break;
      case TransactionFilter.given:
        list = list.where((t) => t.isGiven).toList();
        break;
      case TransactionFilter.all:
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
        t.personName.toLowerCase().contains(q) ||
        (t.note?.toLowerCase().contains(q) ?? false) ||
        (t.categoryName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    // Apply sort
    switch (_sort) {
      case TransactionSort.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSort.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSort.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSort.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case TransactionSort.nameAsc:
        list.sort((a, b) => a.personName.compareTo(b.personName));
        break;
      case TransactionSort.nameDesc:
        list.sort((a, b) => b.personName.compareTo(a.personName));
        break;
    }

    _filteredTransactions = list;
  }
}
