import 'package:flutter/material.dart';
import '../data/models/relative_category.dart';
import '../data/repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<RelativeCategory> _categories = [];
  bool _isLoading = false;

  List<RelativeCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories(int userId) async {
    _isLoading = true;
    notifyListeners();

    _categories = await _repo.getAll(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(RelativeCategory category) async {
    await _repo.insert(category);
    await loadCategories(category.userId);
  }

  Future<void> updateCategory(RelativeCategory category) async {
    await _repo.update(category);
    await loadCategories(category.userId);
  }

  Future<void> deleteCategory(int id, int userId) async {
    await _repo.delete(id);
    await loadCategories(userId);
  }
}
