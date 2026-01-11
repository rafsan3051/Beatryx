enum UIPreset {
  harmoniq, // Dark, modern (Default)
  aura,     // Light, glassmorphic (Image design)
}

class UIConfig {
  final String name;
  final UIPreset preset;
  final bool isDarkMode;
  final double cornerRadius;
  final bool isAura;

  const UIConfig({
    required this.name,
    required this.preset,
    required this.isDarkMode,
    this.cornerRadius = 16,
    this.isAura = false,
  });

  bool get isGlassmorphic => isAura;

  static const harmoniq = UIConfig(
    name: 'Harmoniq',
    preset: UIPreset.harmoniq,
    isDarkMode: true,
    cornerRadius: 16,
    isAura: false,
  );

  static const aura = UIConfig(
    name: 'Aura',
    preset: UIPreset.aura,
    isDarkMode: false,
    cornerRadius: 32,
    isAura: true,
  );

  static List<UIConfig> get allPresets => [harmoniq, aura];
}
