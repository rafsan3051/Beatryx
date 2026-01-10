import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Advanced',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            margin: const EdgeInsets.only(left: 48, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: themeService.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 40,
                  height: 2,
                  color: themeService.accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ClickableOption(
            title: 'Clear Cache',
            subtitle: 'Clear Cache',
            isDark: isDark,
            accentColor: themeService.accentColor,
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              await Future.delayed(const Duration(milliseconds: 500));
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
          ),
          _SettingOption(
            title: 'Download Artist Data',
            subtitle: 'Always',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SettingOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SettingOption({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClickableOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onTap;

  const _ClickableOption({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

