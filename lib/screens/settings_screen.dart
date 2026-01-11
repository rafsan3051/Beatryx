import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_manager.dart';
import '../services/ui_manager.dart';
import '../models/ui_config.dart';
import 'look_feel_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final uiManager = Provider.of<UIManager>(context);
    final isDark = themeManager.isDarkMode;
    final isAura = uiManager.currentUI.isAura;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isAura ? null : IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: themeManager.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isAura ? (isDark ? Colors.white : Colors.black87) : themeManager.textColor,
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
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isAura ? themeManager.accentColor : themeManager.accentColor,
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
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black45,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDark,
                  activeTrackColor: themeManager.accentColor.withValues(alpha: 0.5),
                  activeThumbColor: themeManager.accentColor,
                  onChanged: (value) {
                    themeManager.toggleTheme();
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'Customization', themeManager: themeManager, isAura: isAura, isDark: isDark),
          
          _SettingsTile(
            icon: Icons.dashboard_customize_outlined,
            title: 'Change UI',
            subtitle: 'Choose your preferred layout style',
            themeManager: themeManager,
            isAura: isAura,
            isDark: isDark,
            onTap: () => _showUIPicker(context, uiManager, themeManager, isDark),
          ),

          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Look & Feel',
            subtitle: 'Themes, Colors, Animations',
            themeManager: themeManager,
            isAura: isAura,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LookFeelScreen()),
              );
            },
          ),

          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'Gestures', themeManager: themeManager, isAura: isAura, isDark: isDark),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('Enable Swipe Gestures',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              subtitle: Text('Swipe songs to trigger actions',
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black45)),
              trailing: Switch(
                value: uiManager.swipeEnabled,
                activeTrackColor: themeManager.accentColor.withValues(alpha: 0.5),
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
              isAura: isAura,
              isDark: isDark,
            ),
            _SwipeActionTile(
              title: 'Swipe Left',
              currentAction: uiManager.rightToLeftAction,
              onChanged: (action) => uiManager.setRightToLeftAction(action),
              themeManager: themeManager,
              isAura: isAura,
              isDark: isDark,
            ),
          ],

          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'Audio', themeManager: themeManager, isAura: isAura, isDark: isDark),
          _SettingsTile(
            icon: Icons.volume_up_outlined,
            title: 'Audio Settings',
            subtitle: 'Equalizer and quality',
            themeManager: themeManager,
            isAura: isAura,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _SettingsSectionHeader(title: 'About', themeManager: themeManager, isAura: isAura, isDark: isDark),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: '1.1 (Beatryx)',
            themeManager: themeManager,
            isAura: isAura,
            isDark: isDark,
            onTap: null,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  void _showUIPicker(BuildContext context, UIManager uiManager, ThemeManager themeManager, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select UI Style',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: UIConfig.allPresets.length,
                itemBuilder: (context, index) {
                  final config = UIConfig.allPresets[index];
                  final isSelected = uiManager.currentUI.preset == config.preset;
                  
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: config.isDarkMode ? Colors.black : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        config.isGlassmorphic ? Icons.blur_on : Icons.crop_free,
                        color: themeManager.accentColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      config.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check_circle, color: themeManager.accentColor) : null,
                    onTap: () {
                      uiManager.setUI(config);
                      if (config.isDarkMode != themeManager.isDarkMode) {
                        themeManager.toggleTheme();
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeActionTile extends StatelessWidget {
  final String title;
  final SwipeAction currentAction;
  final Function(SwipeAction) onChanged;
  final ThemeManager themeManager;
  final bool isAura;
  final bool isDark;

  const _SwipeActionTile({
    required this.title,
    required this.currentAction,
    required this.onChanged,
    required this.themeManager,
    required this.isAura,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(_actionToString(currentAction),
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black45)),
      trailing:
          Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26),
      onTap: () => _showActionPicker(context),
    );
  }

  String _actionToString(SwipeAction action) {
    switch (action) {
      case SwipeAction.none: return 'None';
      case SwipeAction.favorite: return 'Add to Favourites';
      case SwipeAction.playlist: return 'Add to Playlist';
      case SwipeAction.delete: return 'Delete';
    }
  }

  void _showActionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var action in SwipeAction.values)
              ListTile(
                onTap: () {
                  onChanged(action);
                  Navigator.pop(context);
                },
                title: Text(_actionToString(action), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                leading: Icon(
                  action == currentAction ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: action == currentAction ? themeManager.accentColor : (isDark ? Colors.white24 : Colors.black26),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  final ThemeManager themeManager;
  final bool isAura;
  final bool isDark;

  const _SettingsSectionHeader({required this.title, required this.themeManager, required this.isAura, required this.isDark});

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
  final bool isAura;
  final bool isDark;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.themeManager, this.onTap, required this.isAura, required this.isDark});

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
                  color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.7),
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
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
