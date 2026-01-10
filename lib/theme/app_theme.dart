import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFF0F0F23);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color cardColor = Color(0xFF16213E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4B8);
  static const Color accentColor = Color(0xFF06FFA5);

  // Light mode colors
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFF5F5F5);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static ThemeData getDarkTheme([Color? accentColor]) {
    final accent = accentColor ?? AppTheme.accentColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: secondaryColor,
        surface: surfaceColor,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData getLightTheme([Color? accentColor]) {
    final accent = accentColor ?? AppTheme.primaryColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackgroundColor,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: secondaryColor,
        surface: lightSurfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        TextTheme(
          displayLarge: const TextStyle(color: lightTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: const TextStyle(color: lightTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: const TextStyle(color: lightTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(color: lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          titleLarge: const TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          titleMedium: const TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
          bodyLarge: const TextStyle(color: lightTextPrimary, fontSize: 16),
          bodyMedium: const TextStyle(color: lightTextSecondary, fontSize: 14),
          bodySmall: const TextStyle(color: lightTextSecondary, fontSize: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: lightTextPrimary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
    );
  }

  static BoxDecoration getGradientBackground(bool isDark) {
    if (isDark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightBackgroundColor,
            lightSurfaceColor,
            lightBackgroundColor,
          ],
        ),
      );
    }
  }

  static BoxDecoration getCardGradient(bool isDark) {
    if (isDark) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      );
    } else {
      return BoxDecoration(
        color: lightCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
  }

  // Accent color options
  static List<Color> get accentColors => [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF06FFA5), // Green
    const Color(0xFFFF6B6B), // Red
    const Color(0xFFFFD93D), // Yellow
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFFFF8C42), // Orange
    const Color(0xFF9B59B6), // Deep Purple
  ];
}
