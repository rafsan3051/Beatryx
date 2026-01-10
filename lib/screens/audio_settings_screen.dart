import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/theme_service.dart';
import 'equalizer_screen.dart';

class AudioSettingsScreen extends StatelessWidget {
  const AudioSettingsScreen({super.key});

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
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Audio',
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
          Consumer<AudioPlayerService>(
            builder: (context, audio, _) {
              return Column(
                children: [
                  _ToggleOption(
                    title: 'Autoplay Next',
                    subtitle: 'Play next song automatically when current ends',
                    value: audio.autoplayNext,
                    isDark: isDark,
                    accentColor: themeService.accentColor,
                    onChanged: (v) => audio.setAutoplayNext(v),
                  ),
                  _ToggleOption(
                    title: 'Show Mini Player',
                    subtitle: 'Display mini player across the app',
                    value: audio.showMiniPlayer,
                    isDark: isDark,
                    accentColor: themeService.accentColor,
                    onChanged: (v) => audio.setShowMiniPlayer(v),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
          _SettingOption(
            title: '3D Audio',
            subtitle: 'Small Room',
            isDark: isDark,
          ),
          _SettingOption(
            title: '3D Audio Mode',
            subtitle: 'Normal',
            isDark: isDark,
          ),
          _ToggleOption(
            title: 'Remember Shuffle',
            subtitle: 'Remember Shuffle',
            value: false,
            isDark: isDark,
            accentColor: themeService.accentColor,
            onChanged: (value) {},
          ),
          _ToggleOption(
            title: 'Fade Audio',
            subtitle: 'Fade in Play/Pause only',
            value: false,
            isDark: isDark,
            accentColor: themeService.accentColor,
            onChanged: (value) {},
          ),
          _SettingOption(
            title: 'Audio Fade Effect',
            subtitle: 'None',
            isDark: isDark,
          ),
          _SettingOption(
            title: 'Audio Fade Mode',
            subtitle: 'Manual Switch',
            isDark: isDark,
          ),
          _SettingOption(
            title: 'Audio Fade Duration',
            subtitle: 'Duration 0 ms',
            isDark: isDark,
          ),
          _ToggleOption(
            title: 'System Equalizer',
            subtitle: 'Turn On To Use System Equalizer',
            value: false,
            isDark: isDark,
            accentColor: themeService.accentColor,
            onChanged: (value) {},
          ),
          _SettingOption(
            title: 'Equalizer Mode',
            subtitle: 'Normal',
            isDark: isDark,
          ),
          _ClickableOption(
            title: 'Open Default Equalizer',
            isDark: isDark,
            accentColor: themeService.accentColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EqualizerScreen()),
              );
            },
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

class _ClickableOption extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onTap;

  const _ClickableOption({
    required this.title,
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
        child: Text(
          title,
          style: TextStyle(
            color: accentColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
