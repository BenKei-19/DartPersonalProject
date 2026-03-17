import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _key = 'dark_mode';
  bool _isDarkMode = false;
  bool _isFirstLaunch = true;

  bool get isDarkMode => _isDarkMode;
  bool get isFirstLaunch => _isFirstLaunch;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    _isFirstLaunch = prefs.getBool('first_launch') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
    notifyListeners();
  }

  Future<void> setFirstLaunchDone() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    notifyListeners();
  }
}
