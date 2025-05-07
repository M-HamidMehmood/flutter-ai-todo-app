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

  // Toggle between system and dark mode
  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.system
        ? ThemeMode.dark
        : ThemeMode.system;
    
    await saveThemeMode(_themeMode);
    notifyListeners();
  }

  // Get theme data
  ThemeData getLightTheme() => AppTheme.getLightTheme();
  ThemeData getDarkTheme() => AppTheme.getDarkTheme();
} 