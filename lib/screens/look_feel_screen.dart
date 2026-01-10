import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_manager.dart';
import '../models/app_theme.dart';

class LookFeelScreen extends StatelessWidget {
  const LookFeelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeManager.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Look & Feel',
          style: TextStyle(
            color: themeManager.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'THEMES', themeManager: themeManager),
          const SizedBox(height: 8),
          ...AppTheme.allThemes.map((theme) => _ThemeTile(
                theme: theme,
                isSelected: themeManager.currentTheme.name == theme.name,
                onTap: () => themeManager.setTheme(theme),
                themeManager: themeManager,
              )),
          const SizedBox(height: 24),
          _SectionHeader(title: 'ACCENT COLOR', themeManager: themeManager),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getAccentColors().length,
              itemBuilder: (context, index) {
                final color = _getAccentColors()[index];
                final isSelected = themeManager.accentColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => themeManager.setAccentColor(color),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: themeManager.textColor, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: themeManager.isDarkMode ? Colors.black : Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getAccentColors() {
    return [
      const Color(0xFF00C2A0),
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFFF4757),
      const Color(0xFFFFD93D),
      const Color(0xFF4ECDC4),
      const Color(0xFFFF8C42),
      const Color(0xFF00D9FF),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeManager themeManager;

  const _SectionHeader({required this.title, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: themeManager.accentColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final AppTheme theme;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeManager themeManager;

  const _ThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeManager.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: themeManager.accentColor, width: 2) : null,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.textColor.withOpacity(0.1)),
          ),
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        title: Text(
          theme.name,
          style: TextStyle(
            color: themeManager.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          theme.isDark ? 'Dark Theme' : 'Light Theme',
          style: TextStyle(color: themeManager.subtitleColor),
        ),
        trailing: isSelected
            ? Icon(Icons.radio_button_checked, color: themeManager.accentColor)
            : Icon(Icons.radio_button_unchecked, color: themeManager.subtitleColor),
      ),
    );
  }
}
