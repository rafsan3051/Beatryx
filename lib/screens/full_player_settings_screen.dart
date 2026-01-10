import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class FullPlayerSettingsScreen extends StatefulWidget {
  const FullPlayerSettingsScreen({super.key});

  @override
  State<FullPlayerSettingsScreen> createState() => _FullPlayerSettingsScreenState();
}

class _FullPlayerSettingsScreenState extends State<FullPlayerSettingsScreen> {
  bool _fullScreenMode = false;

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
          'Full Player',
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
          _SettingOption(
            title: 'Buttons Position',
            subtitle: 'Above Art Image',
            isDark: isDark,
          ),
          _SettingOption(
            title: 'Seek Time Position',
            subtitle: 'Below Seekbar',
            isDark: isDark,
          ),
          _SettingOption(
            title: 'Visualizer Height',
            subtitle: 'Small',
            isDark: isDark,
          ),
          _SettingOption(
            title: 'Art Style',
            subtitle: 'Carousel',
            isDark: isDark,
          ),
          _SettingOption(
            title: 'Bottom Padding',
            subtitle: 'Medium',
            isDark: isDark,
          ),
          _ToggleOption(
            title: 'Full Screen Mode',
            subtitle: 'Disabled',
            value: _fullScreenMode,
            isDark: isDark,
            accentColor: themeService.accentColor,
            onChanged: (value) => setState(() => _fullScreenMode = value),
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

class _ToggleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final Color accentColor;
  final ValueChanged<bool> onChanged;

  const _ToggleOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: accentColor,
          ),
        ],
      ),
    );
  }
}

