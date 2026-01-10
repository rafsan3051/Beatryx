import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../services/theme_manager.dart';
import '../services/ui_manager.dart';
import 'theme_selection_screen.dart';
import 'ui_customization_screen.dart';

class SimpleSettingsScreen extends StatelessWidget {
  const SimpleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AudioPlayerService, ThemeManager, UIManager>(
      builder: (context, audio, themeManager, uiManager, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              // UI Customization
              ListTile(
                leading: Icon(Icons.dashboard, color: themeManager.accentColor),
                title: const Text('UI Customization'),
                subtitle: Text(uiManager.currentUI.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const UICustomizationScreen()),
                  );
                },
              ),
              const Divider(),

              // Theme (Color scheme)
              ListTile(
                leading: Icon(Icons.palette, color: themeManager.accentColor),
                title: const Text('Color Theme'),
                subtitle: Text(themeManager.currentTheme.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ThemeSelectionScreen()),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                secondary:
                    Icon(Icons.skip_next, color: themeManager.accentColor),
                title: const Text('Autoplay Next'),
                subtitle: const Text('Automatically play the next song'),
                value: audio.autoplayNext,
                onChanged: audio.setAutoplayNext,
              ),
              SwitchListTile(
                secondary:
                    Icon(Icons.music_note, color: themeManager.accentColor),
                title: const Text('Show Mini Player'),
                subtitle: const Text('Display mini player above bottom nav'),
                value: audio.showMiniPlayer,
                onChanged: audio.setShowMiniPlayer,
              ),
            ],
          ),
        );
      },
    );
  }
}
