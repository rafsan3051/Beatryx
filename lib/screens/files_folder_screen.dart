import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/music_scanner_service.dart';

class FilesFolderScreen extends StatefulWidget {
  const FilesFolderScreen({super.key});

  @override
  State<FilesFolderScreen> createState() => _FilesFolderScreenState();
}

class _FilesFolderScreenState extends State<FilesFolderScreen> {
  bool _saveLastDirectory = false;
  double _hideSongsDuration = 30.0;

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
          'Files & Folder',
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
          _ToggleOption(
            title: 'Save Last Directory',
            subtitle: _saveLastDirectory ? 'On' : 'Off',
            value: _saveLastDirectory,
            isDark: isDark,
            accentColor: themeService.accentColor,
            onChanged: (value) => setState(() => _saveLastDirectory = value),
          ),
          _SettingOption(
            title: 'Show Folders',
            subtitle: 'Add all the folder you want to show files from',
            isDark: isDark,
          ),
          _SettingOption(
            title: 'Hide Folders',
            subtitle: 'Add all the folder you want to hide files from',
            isDark: isDark,
          ),
          _SliderOption(
            title: 'Hide Songs',
            subtitle: 'Hides songs below the set duration',
            value: _hideSongsDuration,
            isDark: isDark,
            accentColor: themeService.accentColor,
            onChanged: (value) => setState(() => _hideSongsDuration = value),
          ),
          _ClickableOption(
            title: 'Scan Music Files',
            subtitle: 'Scan for newly added or undetected songs',
            isDark: isDark,
            accentColor: themeService.accentColor,
            onTap: () {
              final scannerService = Provider.of<MusicScannerService>(context, listen: false);
              scannerService.scanMusic();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scanning music files...')),
              );
            },
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

class _SliderOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final bool isDark;
  final Color accentColor;
  final ValueChanged<double> onChanged;

  const _SliderOption({
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: 0,
                  max: 300,
                  divisions: 30,
                  activeColor: accentColor,
                  onChanged: onChanged,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
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
                color: accentColor,
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

