import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EqualizerService extends ChangeNotifier {
  static const String _enabledKey = 'equalizer_enabled';
  static const String _bassBoostKey = 'bass_boost';
  static const String _trebleKey = 'treble';
  static const String _surround3DKey = 'surround_3d';
  static const String _presetKey = 'equalizer_preset';

  bool _enabled = false;
  double _bassBoost = 0.0; // -1.0 to 1.0
  double _treble = 0.0; // -1.0 to 1.0
  bool _surround3D = false;
  String _currentPreset = 'Custom';

  // Presets
  static const Map<String, Map<String, dynamic>> presets = {
    'Normal': {'bass': 0.0, 'treble': 0.0, 'surround3D': false},
    'Bass Boost': {'bass': 0.7, 'treble': 0.2, 'surround3D': false},
    'Treble Boost': {'bass': 0.2, 'treble': 0.7, 'surround3D': false},
    'Vocal': {'bass': 0.3, 'treble': 0.6, 'surround3D': false},
    'Rock': {'bass': 0.6, 'treble': 0.5, 'surround3D': true},
    'Pop': {'bass': 0.5, 'treble': 0.4, 'surround3D': false},
    'Jazz': {'bass': 0.4, 'treble': 0.5, 'surround3D': false},
    'Classical': {'bass': 0.3, 'treble': 0.6, 'surround3D': true},
    'Electronic': {'bass': 0.8, 'treble': 0.4, 'surround3D': true},
    '3D Surround': {'bass': 0.5, 'treble': 0.5, 'surround3D': true},
  };

  bool get enabled => _enabled;
  double get bassBoost => _bassBoost;
  double get treble => _treble;
  bool get surround3D => _surround3D;
  String get currentPreset => _currentPreset;
  List<String> get presetNames => presets.keys.toList();

  EqualizerService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _bassBoost = prefs.getDouble(_bassBoostKey) ?? 0.0;
    _treble = prefs.getDouble(_trebleKey) ?? 0.0;
    _surround3D = prefs.getBool(_surround3DKey) ?? false;
    _currentPreset = prefs.getString(_presetKey) ?? 'Custom';
    notifyListeners();
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    notifyListeners();
  }

  Future<void> setBassBoost(double value) async {
    _bassBoost = value.clamp(-1.0, 1.0);
    _currentPreset = 'Custom';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bassBoostKey, _bassBoost);
    await prefs.setString(_presetKey, 'Custom');
    notifyListeners();
  }

  Future<void> setTreble(double value) async {
    _treble = value.clamp(-1.0, 1.0);
    _currentPreset = 'Custom';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_trebleKey, _treble);
    await prefs.setString(_presetKey, 'Custom');
    notifyListeners();
  }

  Future<void> setSurround3D(bool enabled) async {
    _surround3D = enabled;
    _currentPreset = 'Custom';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_surround3DKey, enabled);
    await prefs.setString(_presetKey, 'Custom');
    notifyListeners();
  }

  Future<void> setPreset(String presetName) async {
    if (!presets.containsKey(presetName)) return;
    
    final preset = presets[presetName]!;
    _bassBoost = preset['bass'] as double;
    _treble = preset['treble'] as double;
    _surround3D = preset['surround3D'] as bool;
    _currentPreset = presetName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bassBoostKey, _bassBoost);
    await prefs.setDouble(_trebleKey, _treble);
    await prefs.setBool(_surround3DKey, _surround3D);
    await prefs.setString(_presetKey, presetName);
    notifyListeners();
  }

  void reset() {
    setPreset('Normal');
  }
}

