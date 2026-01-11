import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/audio_service.dart';
import '../services/theme_manager.dart';
import '../services/ui_manager.dart';

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

        final isAura = uiManager.currentUI.isAura;

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
                      vertical: isAura ? 48 : 32),
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
    final isAura = uiManager.currentUI.isAura;
    final panelColor = isAura
        ? Colors.white.withValues(alpha: 0.1)
        : themeManager.surfaceColor.withValues(alpha: 0.82);
    final panelRadius = isAura ? 32.0 : 22.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(panelRadius),
        boxShadow: isAura ? [] : themeManager.cardShadows,
        border: isAura ? Border.all(color: Colors.white.withValues(alpha: 0.1)) : null,
      ),
      child: Column(
        children: [
          // Artwork
          ClipRRect(
            borderRadius: BorderRadius.circular(isAura ? 100 : 20),
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
                  borderRadius: BorderRadius.circular(isAura ? 100 : 20),
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
