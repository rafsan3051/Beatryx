import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_manager.dart';
import 'look_feel_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.isDarkMode;

    return Scaffold(
      backgroundColor: themeManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: themeManager.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: themeManager.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Theme Toggle Tile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeManager.surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: themeManager.accentColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: themeManager.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        style: TextStyle(
                          color: themeManager.subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDark,
                  activeThumbColor: themeManager.accentColor,
                  onChanged: (value) {
                    themeManager.toggleTheme();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'General', themeManager: themeManager),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Look & Feel',
            subtitle: 'Themes, Colors, Animations',
            themeManager: themeManager,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LookFeelScreen()),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.volume_up_outlined,
            title: 'Audio',
            subtitle: 'Equalizer and quality',
            themeManager: themeManager,
            onTap: () {
              // Add navigation to AudioSettingsScreen when implemented
            },
          ),
          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'About', themeManager: themeManager),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: '1.0.0 (Beatryx)',
            themeManager: themeManager,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  final ThemeManager themeManager;

  const _SettingsSectionHeader({required this.title, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: themeManager.accentColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeManager themeManager;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeManager,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: themeManager.textColor.withValues(alpha: 0.7),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: themeManager.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: themeManager.subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: themeManager.textColor.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
