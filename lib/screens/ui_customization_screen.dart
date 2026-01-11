import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ui_manager.dart';
import '../services/theme_manager.dart';
import '../models/ui_config.dart';

class UICustomizationScreen extends StatelessWidget {
  const UICustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UIManager, ThemeManager>(
      builder: (context, uiManager, themeManager, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('UI Customization')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Dark Mode Toggle
              SwitchListTile(
                secondary: Icon(
                  uiManager.darkMode ? Icons.dark_mode : Icons.light_mode,
                  color: themeManager.accentColor,
                ),
                title: const Text('Dark Mode'),
                value: uiManager.darkMode,
                onChanged: (value) {
                  uiManager.setDarkMode(value);
                },
              ),
              const Divider(),

              // UI Presets
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'UI Presets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeManager.textColor,
                  ),
                ),
              ),
              ...UIConfig.allPresets.map((ui) {
                final isSelected = uiManager.currentUI.name == ui.name;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => uiManager.setUI(ui),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeManager.accentColor.withValues(alpha: 0.2)
                            : themeManager.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? themeManager.accentColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ui.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: themeManager.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        ui.isDarkMode ? 'Dark' : 'Light',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 8),
                                    if (ui.isAura)
                                      Chip(
                                        label: const Text('Aura',
                                            style: TextStyle(fontSize: 10)),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: themeManager.accentColor,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
              const Divider(),

              // Player Features
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Player Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeManager.textColor,
                  ),
                ),
              ),
              SwitchListTile(
                secondary:
                    Icon(Icons.music_note, color: themeManager.accentColor),
                title: const Text('Show Visualizer'),
                value: uiManager.showVisualizer,
                onChanged: (_) => uiManager.toggleShowVisualizer(),
              ),
              SwitchListTile(
                secondary: Icon(Icons.lyrics, color: themeManager.accentColor),
                title: const Text('Show Lyrics'),
                value: uiManager.showLyrics,
                onChanged: (_) => uiManager.toggleShowLyrics(),
              ),
              SwitchListTile(
                secondary:
                    Icon(Icons.equalizer, color: themeManager.accentColor),
                title: const Text('Show Equalizer'),
                value: uiManager.showEQ,
                onChanged: (_) => uiManager.toggleShowEQ(),
              ),
              SwitchListTile(
                secondary: Icon(Icons.repeat, color: themeManager.accentColor),
                title: const Text('Repeat Mode'),
                value: uiManager.repeatMode,
                onChanged: (_) => uiManager.toggleRepeatMode(),
              ),
            ],
          ),
        );
      },
    );
  }
}
