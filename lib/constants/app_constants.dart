import 'package:flutter/material.dart';

// Category related constants
class CategoryConstants {
  static const List<String> categories = ['Work', 'Study', 'Personal'];
  static const List<String> categoriesWithAll = ['All', 'Work', 'Study', 'Personal'];
  
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Study':
        return Colors.purple;
      case 'Personal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Priority related constants
class PriorityConstants {
  static const int low = 1;
  static const int medium = 2;
  static const int high = 3;
  
  static const Map<int, String> priorityLabels = {
    low: 'Low',
    medium: 'Medium',
    high: 'High',
  };
  
  static const Map<int, Color> priorityColors = {
    low: Colors.green,
    medium: Colors.orange,
    high: Colors.red,
  };
}

// UI constants
class UIConstants {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double cardBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
}

// Storage keys
class StorageKeys {
  static const String tasksKey = 'tasks';
  static const String themeKey = 'theme_mode';
} 