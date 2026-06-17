import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'rc0_theme_mode';

class ThemeModeNotifier extends ChangeNotifier {
  ThemeModeNotifier._();

  static final ThemeModeNotifier instance = ThemeModeNotifier._();

  ThemeMode _themeMode = ThemeMode.dark;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    _themeMode = _parseThemeMode(stored) ?? ThemeMode.dark;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  Future<void> toggleDarkLight() async {
    final next = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(next);
  }

  ThemeMode? _parseThemeMode(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final mode in ThemeMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }
}
