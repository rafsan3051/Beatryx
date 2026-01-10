import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeManager extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.modernDark;
  AppTheme get currentTheme => _currentTheme;

  Color _customAccentColor = const Color(0xFF00C2A0);
  Color get accentColor => _customAccentColor;

  bool get isDarkMode => _currentTheme.isDark;

  Color get backgroundColor => _currentTheme.backgroundColor;
  Color get surfaceColor => _currentTheme.surfaceColor;
  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
  Color get subtitleColor => isDarkMode ? Colors.white38 : const Color(0xFF666666);
  Color get primaryColor => _currentTheme.primaryColor;
  
  List<BoxShadow> get cardShadows => isDarkMode ? [] : [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))
  ];
  
  List<BoxShadow> get neumorphicShadows => _currentTheme.neumorphicShadows;
  
  LinearGradient? get backgroundGradient => _currentTheme.backgroundGradient;

  ThemeManager() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeName = prefs.getString('theme_name');
    if (themeName != null) {
      try {
        _currentTheme = AppTheme.allThemes.firstWhere((t) => t.name == themeName);
      } catch (_) {
        _currentTheme = AppTheme.modernDark;
      }
    }

    // Load accent color
    final accentValue = prefs.getInt('accent_color');
    if (accentValue != null) {
      _customAccentColor = Color(accentValue);
    }
    
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme.name == theme.name) return;
    _currentTheme = theme;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_name', theme.name);
    
    notifyListeners();
  }

  void toggleTheme() {
    if (isDarkMode) {
      setTheme(AppTheme.minimal); 
    } else {
      setTheme(AppTheme.modernDark);
    }
  }

  Future<void> setAccentColor(Color color) async {
    if (_customAccentColor.toARGB32() == color.toARGB32()) return;
    _customAccentColor = color;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.toARGB32());
    
    notifyListeners();
  }

  ThemeData toThemeData() {
    final baseTheme = _currentTheme.toThemeData();
    return baseTheme.copyWith(
      primaryColor: _customAccentColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _customAccentColor,
        secondary: _customAccentColor,
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: Colors.black,
        fillColor: _customAccentColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(_customAccentColor),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _customAccentColor.withValues(alpha: 0.5);
          return null;
        }),
      ),
      sliderTheme: baseTheme.sliderTheme.copyWith(
        activeTrackColor: _customAccentColor,
        thumbColor: _customAccentColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _customAccentColor,
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
        ),
      ),
      textTheme: _cachedTextTheme ??= GoogleFonts.poppinsTextTheme(),
    );
  }

  TextTheme? _cachedTextTheme;
}
