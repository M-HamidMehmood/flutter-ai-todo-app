import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class ThemeService with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(StorageKeys.themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.themeKey, mode.index);
  }

  // Toggle between light, dark, and system mode
  Future<void> toggleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
    }
    
    await saveThemeMode(_themeMode);
    notifyListeners();
  }

  // Set a specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await saveThemeMode(_themeMode);
    notifyListeners();
  }

  // Check if dark mode is currently active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Get theme data
  ThemeData getLightTheme() => AppTheme.getLightTheme();
  ThemeData getDarkTheme() => AppTheme.getDarkTheme();
} 