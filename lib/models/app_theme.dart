import 'package:flutter/material.dart';

enum AppThemeStyle {
  minimal, // Beige/pink minimalist design
  gradient, // Purple/pink gradient design
  modernDark, // Dark modern design
  vibrantDark, // Dark with vibrant colors
}

class AppTheme {
  final String name;
  final AppThemeStyle style;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color subtitleColor;
  final Color accentColor;
  final bool isDark;
  final LinearGradient? backgroundGradient;
  final double borderRadius;
  final double cardElevation;
  // Typography
  final double headlineLarge;
  final FontWeight headlineWeight;
  final double bodyLarge;
  final double bodySmall;
  // Shapes & Shadows
  final List<BoxShadow> cardShadows;
  final List<BoxShadow> neumorphicShadows;

  const AppTheme({
    required this.name,
    required this.style,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.subtitleColor,
    required this.accentColor,
    required this.isDark,
    this.backgroundGradient,
    this.borderRadius = 16,
    this.cardElevation = 2,
    this.headlineLarge = 32,
    this.headlineWeight = FontWeight.bold,
    this.bodyLarge = 16,
    this.bodySmall = 12,
    this.cardShadows = const [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
    ],
    this.neumorphicShadows = const [
      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(10, 10)),
      BoxShadow(color: Colors.white, blurRadius: 20, offset: Offset(-5, -5))
    ],
  });

  // Minimal Theme (Beige/Pink)
  static const minimal = AppTheme(
    name: 'Minimal',
    style: AppThemeStyle.minimal,
    primaryColor: Color(0xFFE8AFA0),
    secondaryColor: Color(0xFFF5E6D3),
    backgroundColor: Color(0xFFF5E6D3),
    surfaceColor: Colors.white,
    textColor: Color(0xFF2D2D2D),
    subtitleColor: Color(0xFF757575),
    accentColor: Color(0xFFE8AFA0),
    isDark: false,
    borderRadius: 24,
    cardElevation: 0,
    headlineLarge: 36,
    headlineWeight: FontWeight.w700,
    bodyLarge: 16,
    bodySmall: 12,
    cardShadows: [
      BoxShadow(color: Color(0xFF2D2D2D), blurRadius: 12, offset: Offset(0, 4))
    ],
  );

  // Gradient Theme (Purple/Pink)
  static final gradient = AppTheme(
    name: 'Gradient',
    style: AppThemeStyle.gradient,
    primaryColor: const Color(0xFF8B5CF6),
    secondaryColor: const Color(0xFFEC4899),
    backgroundColor: const Color(0xFFF3E8FF),
    surfaceColor: Colors.white,
    textColor: const Color(0xFF1F2937),
    subtitleColor: const Color(0xFF6B7280),
    accentColor: const Color(0xFF8B5CF6),
    isDark: false,
    backgroundGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
    ),
    borderRadius: 20,
    cardElevation: 4,
    headlineLarge: 34,
    headlineWeight: FontWeight.w700,
    bodyLarge: 15,
    bodySmall: 12,
    cardShadows: [
      BoxShadow(color: Color(0x338B5CF6), blurRadius: 12, offset: Offset(0, 6))
    ],
    neumorphicShadows: [
      BoxShadow(color: Color(0x228B5CF6), blurRadius: 16, offset: Offset(8, 8)),
      BoxShadow(
          color: Color(0x11FFFFFF), blurRadius: 16, offset: Offset(-6, -6))
    ],
  );

  // Modern Dark Theme
  static const modernDark = AppTheme(
    name: 'Modern Dark',
    style: AppThemeStyle.modernDark,
    primaryColor: Color(0xFFA8FF76),
    secondaryColor: Color(0xFF1F2937),
    backgroundColor: Color(0xFF111827),
    surfaceColor: Color(0xFF1F2937),
    textColor: Colors.white,
    subtitleColor: Color(0xFF9CA3AF),
    accentColor: Color(0xFFA8FF76),
    isDark: true,
    borderRadius: 16,
    cardElevation: 2,
    headlineLarge: 32,
    headlineWeight: FontWeight.w700,
    bodyLarge: 15,
    bodySmall: 12,
    cardShadows: [
      BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))
    ],
    neumorphicShadows: [
      BoxShadow(
          color: Color(0xFFA8FF76), blurRadius: 20, offset: Offset(10, 10)),
      BoxShadow(
          color: Color(0xFF111827), blurRadius: 20, offset: Offset(-5, -5))
    ],
  );

  // Vibrant Dark Theme
  static const vibrantDark = AppTheme(
    name: 'Vibrant Dark',
    style: AppThemeStyle.vibrantDark,
    primaryColor: Color(0xFFFF4757),
    secondaryColor: Color(0xFF1A1A2E),
    backgroundColor: Color(0xFF0F0F1E),
    surfaceColor: Color(0xFF1A1A2E),
    textColor: Colors.white,
    subtitleColor: Color(0xFFB8B8D1),
    accentColor: Color(0xFF00D9FF),
    isDark: true,
    borderRadius: 20,
    cardElevation: 6,
    headlineLarge: 36,
    headlineWeight: FontWeight.w700,
    bodyLarge: 16,
    bodySmall: 13,
    cardShadows: [
      BoxShadow(color: Color(0x4000D9FF), blurRadius: 12, offset: Offset(0, 6))
    ],
    neumorphicShadows: [
      BoxShadow(color: Color(0x3300D9FF), blurRadius: 18, offset: Offset(8, 8)),
      BoxShadow(
          color: Color(0x4D0F0F1E), blurRadius: 18, offset: Offset(-6, -6))
    ],
  );

  static List<AppTheme> get allThemes => [
        minimal,
        gradient,
        modernDark,
        vibrantDark,
      ];

  ThemeData toThemeData() {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: secondaryColor,
        onSecondary: isDark ? Colors.white : Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius / 2),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        thumbColor: accentColor,
        inactiveTrackColor: subtitleColor.withValues(alpha: 0.3),
      ),
      iconTheme: IconThemeData(color: textColor),
    );
  }
}
