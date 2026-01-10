import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_manager.dart';
import '../services/ui_manager.dart';
import 'look_feel_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final uiManager = Provider.of<UIManager>(context);
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
                  activeTrackColor:
                      themeManager.accentColor.withValues(alpha: 0.5),
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

          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'Gestures', themeManager: themeManager),
          // Swipe Toggle
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('Enable Swipe Gestures',
                  style: TextStyle(color: themeManager.textColor)),
              subtitle: Text('Swipe songs to trigger actions',
                  style: TextStyle(color: themeManager.subtitleColor)),
              trailing: Switch(
                value: uiManager.swipeEnabled,
                activeTrackColor:
                    themeManager.accentColor.withValues(alpha: 0.5),
                activeThumbColor: themeManager.accentColor,
                onChanged: (value) => uiManager.setSwipeEnabled(value),
              ),
            ),
          ),
          if (uiManager.swipeEnabled) ...[
            _SwipeActionTile(
              title: 'Swipe Right',
              currentAction: uiManager.leftToRightAction,
              onChanged: (action) => uiManager.setLeftToRightAction(action),
              themeManager: themeManager,
            ),
            _SwipeActionTile(
              title: 'Swipe Left',
              currentAction: uiManager.rightToLeftAction,
              onChanged: (action) => uiManager.setRightToLeftAction(action),
              themeManager: themeManager,
            ),
          ],

          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'Audio', themeManager: themeManager),
          _SettingsTile(
            icon: Icons.volume_up_outlined,
            title: 'Audio Settings',
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
            subtitle: '1.1 (Beatryx)',
            themeManager: themeManager,
            onTap: null,
          ),
          // Added space at bottom to ensure items aren't hidden by navigation bar
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _SwipeActionTile extends StatelessWidget {
  final String title;
  final SwipeAction currentAction;
  final Function(SwipeAction) onChanged;
  final ThemeManager themeManager;

  const _SwipeActionTile({
    required this.title,
    required this.currentAction,
    required this.onChanged,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(color: themeManager.textColor)),
      subtitle: Text(_actionToString(currentAction),
          style: TextStyle(color: themeManager.subtitleColor)),
      trailing:
          Icon(Icons.chevron_right_rounded, color: themeManager.subtitleColor),
      onTap: () => _showActionPicker(context),
    );
  }

  String _actionToString(SwipeAction action) {
    switch (action) {
      case SwipeAction.none:
        return 'None';
      case SwipeAction.favorite:
        return 'Add to Favourites';
      case SwipeAction.playlist:
        return 'Add to Playlist';
      case SwipeAction.delete:
        return 'Delete';
    }
  }

  void _showActionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeManager.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Theme(
          data: Theme.of(context).copyWith(
            radioTheme: RadioThemeData(
              fillColor: WidgetStateProperty.all(themeManager.accentColor),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var action in SwipeAction.values)
                GestureDetector(
                  onTap: () {
                    onChanged(action);
                    Navigator.pop(context);
                  },
                  child: ListTile(
                    title: Text(_actionToString(action),
                        style: const TextStyle(color: Colors.white)),
                    leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: themeManager.accentColor),
                          color: action == currentAction
                              ? themeManager.accentColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  final ThemeManager themeManager;

  const _SettingsSectionHeader(
      {required this.title, required this.themeManager});

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
