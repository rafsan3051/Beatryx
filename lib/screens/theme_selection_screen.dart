import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_manager.dart';
import '../models/app_theme.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Choose Theme'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: AppTheme.allThemes.length,
            itemBuilder: (context, index) {
              final theme = AppTheme.allThemes[index];
              final isSelected = themeManager.currentTheme.name == theme.name;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  onTap: () {
                    themeManager.setTheme(theme);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
          color:
              theme.backgroundGradient == null ? theme.backgroundColor : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.accentColor : Colors.transparent,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            // Preview colors
            Column(
              children: [
                Row(
                  children: [
                    _ColorCircle(color: theme.primaryColor, size: 32),
                    const SizedBox(width: 8),
                    _ColorCircle(color: theme.secondaryColor, size: 32),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ColorCircle(color: theme.surfaceColor, size: 32),
                    const SizedBox(width: 8),
                    _ColorCircle(color: theme.accentColor, size: 32),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Theme info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getThemeDescription(theme.style),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.accentColor,
                size: 32,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: theme.subtitleColor,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.minimal:
        return 'Soft & Elegant';
      case AppThemeStyle.gradient:
        return 'Colorful & Vibrant';
      case AppThemeStyle.modernDark:
        return 'Sleek & Modern';
      case AppThemeStyle.vibrantDark:
        return 'Bold & Dynamic';
    }
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _ColorCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
      ),
    );
  }
}
