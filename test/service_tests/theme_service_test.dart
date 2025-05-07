import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeService Tests', () {
    late ThemeService themeService;

    setUp(() async {
      // Initialize shared preferences for testing
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService();
    });

    test('Initial theme is system', () {
      expect(themeService.themeMode, ThemeMode.system);
    });

    test('toggleThemeMode changes between system and dark mode', () async {
      // Initially it's system
      expect(themeService.themeMode, ThemeMode.system);
      
      // Toggle to dark
      await themeService.toggleThemeMode();
      expect(themeService.themeMode, ThemeMode.dark);
      
      // Toggle back to system
      await themeService.toggleThemeMode();
      expect(themeService.themeMode, ThemeMode.system);
    });

    test('saveThemeMode persists theme mode to shared preferences', () async {
      // Save dark mode
      await themeService.saveThemeMode(ThemeMode.dark);
      
      // Create a new instance to test loading
      final newService = ThemeService();
      // Wait for async loading operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      // The new instance should have loaded the dark mode
      expect(newService.themeMode, ThemeMode.dark);
    });

    test('getLightTheme returns a ThemeData instance', () {
      final theme = themeService.getLightTheme();
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.light);
    });

    test('getDarkTheme returns a ThemeData instance', () {
      final theme = themeService.getDarkTheme();
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
    });
  });
} 