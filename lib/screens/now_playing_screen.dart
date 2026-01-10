import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_service.dart';
import '../services/theme_service.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import '../widgets/audio_visualizer.dart';
import '../theme/app_theme.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isRotating = true;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerService, ThemeService>(
      builder: (context, playerService, themeService, _) {
        final currentSong = playerService.currentSong;
        final isDark = themeService.isDarkMode;

        if (currentSong == null) {
          return Scaffold(
            body: Container(
              decoration: AppTheme.getGradientBackground(isDark),
              child: Center(
                child: Text(
                  'No song playing',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
            ),
          );
        }

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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Now Playing',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'from ${currentSong.album}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final isFav = playerService.isFavorite(currentSong.id);
                        return IconButton(
                          icon: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            playerService.toggleFavorite(currentSong.id);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Album Art with Visualizer
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRotating = !_isRotating;
                              if (_isRotating) {
                                _rotationController.repeat();
                              } else {
                                _rotationController.stop();
                              }
                            });
                          },
                          child: AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _isRotating
                                    ? _rotationController.value * 2 * math.pi
                                    : 0,
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        themeService.accentColor,
                                        themeService.accentColor.withValues(alpha: 0.7),
                                        themeService.accentColor.withValues(alpha: 0.5),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themeService.accentColor.withValues(alpha: 0.5),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 80,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Audio Visualizer
                    Container(
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const AudioVisualizer(
                        barCount: 30, // Reduced for better performance
                        color: Colors.white,
                        barWidth: 3.0,
                        barSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Song Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: [
                    Text(
                      currentSong.title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentSong.artist,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ProgressBar(),
              ),

              const SizedBox(height: 32),

              // Player Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PlayerControls(),
              ),

              const SizedBox(height: 24),

              // Volume Control
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    const Icon(Icons.volume_down, color: Colors.white70, size: 20),
                    Expanded(
                      child: StreamBuilder<Duration>(
                        stream: playerService.positionStream,
                        builder: (context, snapshot) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              activeTrackColor: Colors.white.withValues(alpha: 0.7),
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: 0.7,
                              onChanged: (value) {
                                playerService.setVolume(value);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up, color: Colors.white70, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
        );
      },
    );
  }
}

