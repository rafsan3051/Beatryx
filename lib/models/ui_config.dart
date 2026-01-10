enum UIPreset {
  minimal, // Minimal beige/pink (light)
  gradient, // Gradient purple/pink (light)
  modernDark, // Modern dark (dark)
  vibrantDark, // Vibrant neon dark (dark)
}

class UIConfig {
  final String name;
  final UIPreset preset;
  final bool isDarkMode;
  final double cornerRadius;
  final bool useGradientBackground;
  final bool useNeumorphic;
  final double cardOpacity;
  final double shadowIntensity;

  const UIConfig({
    required this.name,
    required this.preset,
    required this.isDarkMode,
    this.cornerRadius = 16,
    this.useGradientBackground = false,
    this.useNeumorphic = false,
    this.cardOpacity = 1.0,
    this.shadowIntensity = 1.0,
  });

  // Minimal (Light)
  static const minimal = UIConfig(
    name: 'Minimal',
    preset: UIPreset.minimal,
    isDarkMode: false,
    cornerRadius: 24,
    useGradientBackground: false,
    useNeumorphic: false,
    cardOpacity: 0.95,
    shadowIntensity: 0.3,
  );

  // Gradient (Light)
  static const gradient = UIConfig(
    name: 'Gradient',
    preset: UIPreset.gradient,
    isDarkMode: false,
    cornerRadius: 20,
    useGradientBackground: true,
    useNeumorphic: false,
    cardOpacity: 1.0,
    shadowIntensity: 0.5,
  );

  // Modern Dark
  static const modernDark = UIConfig(
    name: 'Modern Dark',
    preset: UIPreset.modernDark,
    isDarkMode: true,
    cornerRadius: 16,
    useGradientBackground: false,
    useNeumorphic: true,
    cardOpacity: 0.9,
    shadowIntensity: 0.4,
  );

  // Vibrant Dark
  static const vibrantDark = UIConfig(
    name: 'Vibrant Dark',
    preset: UIPreset.vibrantDark,
    isDarkMode: true,
    cornerRadius: 20,
    useGradientBackground: false,
    useNeumorphic: true,
    cardOpacity: 1.0,
    shadowIntensity: 0.8,
  );

  static List<UIConfig> get allPresets => [
        minimal,
        gradient,
        modernDark,
        vibrantDark,
      ];

  // Custom creation with modifications
  UIConfig copyWith({
    double? cornerRadius,
    bool? useGradientBackground,
    bool? useNeumorphic,
    double? cardOpacity,
    double? shadowIntensity,
  }) {
    return UIConfig(
      name: '$name (Custom)',
      preset: preset,
      isDarkMode: isDarkMode,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      useGradientBackground:
          useGradientBackground ?? this.useGradientBackground,
      useNeumorphic: useNeumorphic ?? this.useNeumorphic,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      shadowIntensity: shadowIntensity ?? this.shadowIntensity,
    );
  }
}
