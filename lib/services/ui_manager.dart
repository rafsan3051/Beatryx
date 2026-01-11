import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ui_config.dart';

enum SwipeAction {
  none,
  favorite,
  playlist,
  delete
}

class UIManager extends ChangeNotifier {
  UIConfig _currentUI = UIConfig.harmoniq;
  bool _darkMode = true;
  bool _showLyrics = false;
  bool _showVisualizer = true;
  bool _showEQ = false;
  bool _repeatMode = false;
  bool _shuffleMode = false;
  bool _favoriteMode = false;

  // Swipe Action Settings
  bool _swipeEnabled = true;
  SwipeAction _leftToRightAction = SwipeAction.favorite;
  SwipeAction _rightToLeftAction = SwipeAction.playlist;

  UIConfig get currentUI => _currentUI;
  bool get darkMode => _darkMode;
  bool get showLyrics => _showLyrics;
  bool get showVisualizer => _showVisualizer;
  bool get showEQ => _showEQ;
  bool get repeatMode => _repeatMode;
  bool get shuffleMode => _shuffleMode;
  bool get favoriteMode => _favoriteMode;

  bool get swipeEnabled => _swipeEnabled;
  SwipeAction get leftToRightAction => _leftToRightAction;
  SwipeAction get rightToLeftAction => _rightToLeftAction;

  UIManager() {
    _loadUI();
  }

  Future<void> _loadUI() async {
    final prefs = await SharedPreferences.getInstance();
    final uiName = prefs.getString('ui_preset') ?? 'Harmoniq';
    final isDark = prefs.getBool('dark_mode') ?? true;

    _currentUI = UIConfig.allPresets.firstWhere(
      (ui) => ui.name == uiName,
      orElse: () => UIConfig.harmoniq,
    );
    _darkMode = isDark;

    _showLyrics = prefs.getBool('show_lyrics') ?? false;
    _showVisualizer = prefs.getBool('show_visualizer') ?? true;
    _showEQ = prefs.getBool('show_eq') ?? false;
    _repeatMode = prefs.getBool('repeat_mode') ?? false;
    _shuffleMode = prefs.getBool('shuffle_mode') ?? false;
    _favoriteMode = prefs.getBool('favorite_mode') ?? false;

    // Load Swipe Actions
    _swipeEnabled = prefs.getBool('swipe_enabled') ?? true;
    _leftToRightAction = SwipeAction.values[prefs.getInt('ltr_action') ?? SwipeAction.favorite.index];
    _rightToLeftAction = SwipeAction.values[prefs.getInt('rtl_action') ?? SwipeAction.playlist.index];

    notifyListeners();
  }

  Future<void> setSwipeEnabled(bool value) async {
    _swipeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('swipe_enabled', value);
    notifyListeners();
  }

  Future<void> setLeftToRightAction(SwipeAction action) async {
    _leftToRightAction = action;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ltr_action', action.index);
    notifyListeners();
  }

  Future<void> setRightToLeftAction(SwipeAction action) async {
    _rightToLeftAction = action;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rtl_action', action.index);
    notifyListeners();
  }

  Future<void> setUI(UIConfig ui) async {
    _currentUI = ui;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ui_preset', ui.name);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> toggleShowLyrics() async {
    _showLyrics = !_showLyrics;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_lyrics', _showLyrics);
    notifyListeners();
  }

  Future<void> toggleShowVisualizer() async {
    _showVisualizer = !_showVisualizer;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_visualizer', _showVisualizer);
    notifyListeners();
  }

  Future<void> toggleShowEQ() async {
    _showEQ = !_showEQ;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_eq', _showEQ);
    notifyListeners();
  }

  Future<void> toggleRepeatMode() async {
    _repeatMode = !_repeatMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('repeat_mode', _repeatMode);
    notifyListeners();
  }

  Future<void> toggleShuffleMode() async {
    _shuffleMode = !_shuffleMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shuffle_mode', _shuffleMode);
    notifyListeners();
  }

  Future<void> toggleFavoriteMode() async {
    _favoriteMode = !_favoriteMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('favorite_mode', _favoriteMode);
    notifyListeners();
  }
}
