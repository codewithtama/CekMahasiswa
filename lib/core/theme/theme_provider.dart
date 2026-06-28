import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _keyTheme = 'pddikti_theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeStr = prefs.getString(_keyTheme);
      if (themeStr != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.name == themeStr,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e, stack) {
      debugPrint('Error loading theme mode: $e\n$stack');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      state = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, mode.name);
    } catch (e, stack) {
      debugPrint('Error setting theme mode: $e\n$stack');
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
