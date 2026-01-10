import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  
  ThemeMode _themeMode = ThemeMode.dark;
  Color _accentColor = const Color(0xFF6366F1);

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    final accentColorValue = prefs.getInt(_accentColorKey) ?? 0xFF6366F1;
    
    _themeMode = ThemeMode.values[themeIndex];
    _accentColor = Color(accentColorValue);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.toARGB32());
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
}

