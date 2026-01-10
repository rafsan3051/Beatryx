import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/audio_service.dart';
import '../services/theme_manager.dart';
import '../services/ui_manager.dart';
import '../models/ui_config.dart';

class PlayerScreen extends StatefulWidget {
  final List<SongModel> songs;
  final int initialIndex;

  const PlayerScreen(
      {super.key, required this.songs, required this.initialIndex});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to interact with the provider after the widget has been built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioPlayerService>(context, listen: false)
          .playPlaylist(widget.songs, widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AudioPlayerService, ThemeManager, UIManager>(
      builder: (context, audioService, themeManager, uiManager, child) {
        final currentSong = audioService.currentSong;

        if (currentSong == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: themeManager.textColor),
            actions: [
              IconButton(
                icon: Icon(
                  uiManager.showLyrics ? Icons.lyrics : Icons.lyrics_outlined,
                  color: uiManager.showLyrics
                      ? themeManager.accentColor
                      : themeManager.textColor,
                ),
                onPressed: () => uiManager.toggleShowLyrics(),
              ),
              IconButton(
                icon: Icon(
                  uiManager.showVisualizer
                      ? Icons.graphic_eq
                      : Icons.graphic_eq_outlined,
                  color: uiManager.showVisualizer
                      ? themeManager.accentColor
                      : themeManager.textColor,
                ),
                onPressed: () => uiManager.toggleShowVisualizer(),
              ),
              IconButton(
                icon: Icon(
                  uiManager.showEQ ? Icons.equalizer : Icons.equalizer_outlined,
                  color: uiManager.showEQ
                      ? themeManager.accentColor
                      : themeManager.textColor,
                ),
                onPressed: () => uiManager.toggleShowEQ(),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: themeManager.backgroundGradient,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: uiManager.currentUI.preset == UIPreset.minimal
                          ? 48
                          : 32),
                  child: _buildPlayerPanel(context, themeManager, uiManager,
                      audioService, currentSong),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerPanel(
    BuildContext context,
    ThemeManager themeManager,
    UIManager uiManager,
    AudioPlayerService audioService,
    SongModel currentSong,
  ) {
    final preset = uiManager.currentUI.preset;
    final panelColor = preset == UIPreset.minimal
        ? const Color(0xFFF7EFE6)
        : preset == UIPreset.gradient
            ? Colors.white.withValues(alpha: 0.92)
            : themeManager.surfaceColor.withValues(alpha: 0.82);
    final panelRadius = preset == UIPreset.gradient ? 28.0 : 22.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(panelRadius),
        boxShadow: themeManager.cardShadows,
      ),
      child: Column(
        children: [
          // Artwork
          ClipRRect(
            borderRadius:
                BorderRadius.circular(preset == UIPreset.gradient ? 32 : 20),
            child: QueryArtworkWidget(
              id: currentSong.id,
              type: ArtworkType.AUDIO,
              artworkWidth: 220,
              artworkHeight: 220,
              nullArtworkWidget: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: themeManager.surfaceColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(
                      preset == UIPreset.gradient ? 32 : 20),
                ),
                child: Icon(Icons.music_note,
                    size: 100,
                    color: themeManager.textColor.withValues(alpha: 0.7)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title + actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.title,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: themeManager.textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentSong.artist ?? "Unknown Artist",
                        style: TextStyle(
                            fontSize: 14, color: themeManager.subtitleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    uiManager.favoriteMode
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: uiManager.favoriteMode
                        ? themeManager.accentColor
                        : themeManager.textColor,
                  ),
                  onPressed: () => uiManager.toggleFavoriteMode(),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: themeManager.textColor),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Seek bar
          StreamBuilder<Duration?>(
            stream: audioService.durationStream,
            builder: (context, durSnap) {
              final duration = durSnap.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, posSnap) {
                  final position = posSnap.data ?? Duration.zero;
                  final totalMs =
                      duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;
                  final value =
                      position.inMilliseconds.clamp(0, totalMs) / totalMs;
                  return Column(
                    children: [
                      Slider(
                        value: value,
                        onChanged: (v) {
                          audioService.seek(
                              Duration(milliseconds: (v * totalMs).toInt()));
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position),
                              style:
                                  TextStyle(color: themeManager.subtitleColor)),
                          Text(_formatDuration(duration),
                              style:
                                  TextStyle(color: themeManager.subtitleColor)),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Visualizer
          if (uiManager.showVisualizer)
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: themeManager.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    12,
                    (index) => Container(
                      width: 4,
                      height: 20 + (index % 3) * 15,
                      decoration: BoxDecoration(
                        color: themeManager.accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Lyrics
          if (uiManager.showLyrics)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeManager.surfaceColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Lyrics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeManager.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lyrics for "${currentSong.title}" by ${currentSong.artist ?? 'Unknown Artist'} coming soon...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeManager.subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // EQ
          if (uiManager.showEQ)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeManager.surfaceColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Equalizer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeManager.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['60Hz', '125Hz', '250Hz', '500Hz', '1k', '2k']
                        .map((freq) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: 0.5,
                                onChanged: (v) {},
                                activeColor: themeManager.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            freq,
                            style: TextStyle(
                              fontSize: 10,
                              color: themeManager.subtitleColor,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  uiManager.shuffleMode ? Icons.shuffle : Icons.shuffle,
                  color: uiManager.shuffleMode
                      ? themeManager.accentColor
                      : themeManager.textColor,
                ),
                onPressed: () => uiManager.toggleShuffleMode(),
              ),
              IconButton(
                icon: Icon(Icons.skip_previous,
                    color: themeManager.textColor, size: 34),
                onPressed: audioService.playPrevious,
              ),
              IconButton(
                icon: Icon(
                  audioService.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: themeManager.accentColor,
                  size: 70,
                ),
                onPressed: audioService.togglePlayPause,
              ),
              IconButton(
                icon: Icon(Icons.skip_next,
                    color: themeManager.textColor, size: 34),
                onPressed: audioService.playNext,
              ),
              IconButton(
                icon: Icon(
                  uiManager.repeatMode ? Icons.repeat_one : Icons.repeat,
                  color: uiManager.repeatMode
                      ? themeManager.accentColor
                      : themeManager.textColor,
                ),
                onPressed: () => uiManager.toggleRepeatMode(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
