import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/equalizer_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EqualizerService, ThemeService>(
      builder: (context, equalizerService, themeService, _) {
        final isDark = themeService.isDarkMode;
        final accentColor = themeService.accentColor;

        return Scaffold(
          body: Container(
            decoration: AppTheme.getGradientBackground(isDark),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: Theme.of(context).iconTheme.color,
                        ),
                        Text(
                          'Equalizer',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Enable/Disable Switch
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Equalizer',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    equalizerService.enabled
                                        ? 'Enabled'
                                        : 'Disabled',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Switch(
                                value: equalizerService.enabled,
                                onChanged: (value) {
                                  equalizerService.setEnabled(value);
                                },
                                activeThumbColor: accentColor,
                              ),
                            ],
                          ),
                        ),

                        // Presets
                        Text(
                          'Presets',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: equalizerService.presetNames.length,
                            itemBuilder: (context, index) {
                              final presetName = equalizerService.presetNames[index];
                              final isSelected =
                                  equalizerService.currentPreset == presetName;
                              return GestureDetector(
                                onTap: () {
                                  equalizerService.setPreset(presetName);
                                },
                                child: Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accentColor.withValues(alpha: 0.3)
                                        : Theme.of(context)
                                            .cardColor
                                            .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? accentColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.music_note,
                                          color: isSelected
                                              ? accentColor
                                              : Theme.of(context).iconTheme.color,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          presetName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? accentColor
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Bass Boost
                        _EqualizerSlider(
                          title: 'Bass Boost',
                          icon: Icons.volume_down,
                          value: equalizerService.bassBoost,
                          onChanged: (value) {
                            equalizerService.setBassBoost(value);
                          },
                          isDark: isDark,
                          accentColor: accentColor,
                        ),

                        const SizedBox(height: 24),

                        // Treble
                        _EqualizerSlider(
                          title: 'Treble',
                          icon: Icons.graphic_eq,
                          value: equalizerService.treble,
                          onChanged: (value) {
                            equalizerService.setTreble(value);
                          },
                          isDark: isDark,
                          accentColor: accentColor,
                        ),

                        const SizedBox(height: 24),

                        // 3D Surround
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.surround_sound,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '3D Surround',
                                        style:
                                            Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        'Enhanced audio experience',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: equalizerService.surround3D,
                                onChanged: (value) {
                                  equalizerService.setSurround3D(value);
                                },
                                activeThumbColor: accentColor,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EqualizerSlider extends StatelessWidget {
  final String title;
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;
  final bool isDark;
  final Color accentColor;

  const _EqualizerSlider({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor.withValues(alpha: 0.5)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '-100%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accentColor,
                    inactiveTrackColor:
                        accentColor.withValues(alpha: 0.2),
                    thumbColor: accentColor,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: value,
                    min: -1.0,
                    max: 1.0,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text(
                '+100%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Center(
            child: Text(
              '${(value * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

