import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class VisualizerSettingsScreen extends StatefulWidget {
  const VisualizerSettingsScreen({super.key});

  @override
  State<VisualizerSettingsScreen> createState() => _VisualizerSettingsScreenState();
}

class _VisualizerSettingsScreenState extends State<VisualizerSettingsScreen> {
  bool _visualizerEnabled = true;
  bool _lockScreenVisualizer = false;
  bool _waveSmoothing = true;

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
          'Visualizer',
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
            title: 'Visualizer',
            subtitle: _visualizerEnabled ? 'On' : 'Off',
            value: _visualizerEnabled,
            isDark: isDark,
            accentColor: themeService.accentColor,
            onChanged: (value) => setState(() => _visualizerEnabled = value),
          ),
          _ToggleOption(
            title: 'Visualizer In Lock Screen',
            subtitle: _lockScreenVisualizer ? 'On' : 'Off',
            value: _lockScreenVisualizer,
            isDark: isDark,
            accentColor: themeService.accentColor,
            enabled: _visualizerEnabled,
            onChanged: (value) => setState(() => _lockScreenVisualizer = value),
          ),
          _SettingOption(
            title: 'Style',
            subtitle: 'Variable Wave',
            isDark: isDark,
            enabled: _visualizerEnabled,
          ),
          _SettingOption(
            title: 'Visualizer Wave Frequency',
            subtitle: 'Set Wave Frequency',
            isDark: isDark,
            enabled: false,
          ),
          _ToggleOption(
            title: 'Wave Smoothing',
            subtitle: _waveSmoothing ? 'On' : 'Off',
            value: _waveSmoothing,
            isDark: isDark,
            accentColor: themeService.accentColor,
            enabled: _visualizerEnabled,
            onChanged: (value) => setState(() => _waveSmoothing = value),
          ),
          _SettingOption(
            title: 'Wave Smoothing',
            subtitle: 'Smooth',
            isDark: isDark,
            enabled: false,
          ),
          _SettingOption(
            title: 'Wave Points',
            subtitle: 'Set No. of points in waves',
            isDark: isDark,
            enabled: false,
          ),
          _SettingOption(
            title: 'Wave Scaling',
            subtitle: 'Set wave Scaling',
            isDark: isDark,
            enabled: false,
          ),
          _SettingOption(
            title: 'Wave Size',
            subtitle: 'Set wave start size',
            isDark: isDark,
            enabled: false,
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
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.accentColor,
    this.enabled = true,
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
                    color: enabled ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white54 : Colors.black38),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: enabled ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? Colors.white38 : Colors.black26),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
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
  final bool enabled;

  const _SettingOption({
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.enabled = true,
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
              color: enabled ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white54 : Colors.black38),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: enabled ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? Colors.white38 : Colors.black26),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

