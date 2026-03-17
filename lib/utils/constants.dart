import 'package:flutter/material.dart';

class AppConstants {
  static const String dbName = 'lixi_tracker.db';
  static const int dbVersion = 1;

  // App info
  static const String appName = 'Lì Xì Tracker';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFFFCDD2);
  static const Color receivedGreen = Color(0xFF4CAF50);
  static const Color givenOrange = Color(0xFFFF9800);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFFD32F2F),
    Color(0xFFFFD700),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF00BCD4),
    Color(0xFFE91E63),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];

  // Icon mapping
  static const Map<String, IconData> categoryIcons = {
    'people': Icons.people,
    'elderly': Icons.elderly,
    'family': Icons.family_restroom,
    'child': Icons.child_care,
    'friend': Icons.diversity_3,
    'work': Icons.work,
    'home': Icons.home,
    'other': Icons.category,
  };

  // Default Tết year
  static int get currentTetYear {
    final now = DateTime.now();
    // Tết usually falls in Jan-Feb, so if we're past Feb, next Tết is next year
    return now.month <= 2 ? now.year : now.year + 1;
  }
}
