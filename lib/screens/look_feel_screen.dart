import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_manager.dart';
import '../services/ui_manager.dart';
import '../models/app_theme.dart';

class LookFeelScreen extends StatelessWidget {
  const LookFeelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final uiManager = Provider.of<UIManager>(context);
    final isAura = uiManager.currentUI.isAura;
    final isDark = themeManager.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? themeManager.backgroundColor : (isAura ? Colors.white : themeManager.backgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : (isAura ? Colors.black87 : themeManager.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Look & Feel',
          style: TextStyle(
            color: isDark ? Colors.white : (isAura ? Colors.black87 : themeManager.textColor),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'THEMES', themeManager: themeManager, isAura: isAura, isDark: isDark),
          const SizedBox(height: 8),
          ...AppTheme.allThemes.map((theme) => _ThemeTile(
                theme: theme,
                isSelected: themeManager.currentTheme.name == theme.name,
                onTap: () => themeManager.setTheme(theme),
                themeManager: themeManager,
                isAura: isAura,
                isDark: isDark,
              )),
          const SizedBox(height: 24),
          _SectionHeader(title: 'ACCENT COLOR', themeManager: themeManager, isAura: isAura, isDark: isDark),
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
                          ? Border.all(color: isDark ? Colors.white : (isAura ? Colors.black87 : themeManager.textColor), width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: isDark ? Colors.black : Colors.white)
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
      const Color(0xFFD81B60),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeManager themeManager;
  final bool isAura;
  final bool isDark;

  const _SectionHeader({required this.title, required this.themeManager, required this.isAura, required this.isDark});

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
  final bool isAura;
  final bool isDark;

  const _ThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    required this.themeManager,
    required this.isAura,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : (isAura ? Colors.black.withValues(alpha: 0.05) : themeManager.surfaceColor),
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
            border: Border.all(color: theme.textColor.withValues(alpha: 0.1)),
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
            color: isDark ? Colors.white : (isAura ? Colors.black87 : themeManager.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          theme.isDark ? 'Dark Theme' : 'Light Theme',
          style: TextStyle(color: isDark ? Colors.white38 : (isAura ? Colors.black45 : themeManager.subtitleColor)),
        ),
        trailing: isSelected
            ? Icon(Icons.radio_button_checked, color: themeManager.accentColor)
            : Icon(Icons.radio_button_unchecked, color: isDark ? Colors.white24 : (isAura ? Colors.black26 : themeManager.subtitleColor)),
      ),
    );
  }
}
