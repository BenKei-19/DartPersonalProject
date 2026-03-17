import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/category_repository.dart';
import '../utils/password_hasher.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final passwordHash = PasswordHasher.hash(password);
      final user = await _userRepo.login(username, passwordHash);

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Tên đăng nhập hoặc mật khẩu không đúng';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if username exists
      final existing = await _userRepo.getUserByUsername(username);
      if (existing != null) {
        _error = 'Tên đăng nhập đã tồn tại';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final passwordHash = PasswordHasher.hash(password);
      final user = User(
        username: username,
        passwordHash: passwordHash,
        displayName: displayName,
        createdAt: DateTime.now().toIso8601String(),
      );

      final userId = await _userRepo.register(user);
      _currentUser = user.copyWith(id: userId);

      // Create default categories for new user
      await _categoryRepo.insertDefaultCategories(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String displayName) async {
    if (_currentUser == null) return false;

    try {
      await _userRepo.updateProfile(_currentUser!.id!, displayName);
      _currentUser = _currentUser!.copyWith(displayName: displayName);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAvatar(String avatarPath) async {
    if (_currentUser == null) return false;

    try {
      await _userRepo.updateAvatar(_currentUser!.id!, avatarPath);
      _currentUser = _currentUser!.copyWith(avatarPath: avatarPath);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    try {
      final oldHash = PasswordHasher.hash(oldPassword);
      if (oldHash != _currentUser!.passwordHash) {
        _error = 'Mật khẩu cũ không đúng';
        notifyListeners();
        return false;
      }

      final newHash = PasswordHasher.hash(newPassword);
      await _userRepo.changePassword(_currentUser!.id!, newHash);
      _currentUser = _currentUser!.copyWith(passwordHash: newHash);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Đã xảy ra lỗi: $e';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
