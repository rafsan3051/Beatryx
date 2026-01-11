import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/audio_service.dart';
import '../services/theme_manager.dart';
import '../screens/themed_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioPlayerService, ThemeManager>(
      builder: (context, audio, themeManager, child) {
        final song = audio.currentSong;
        if (song == null || !audio.showMiniPlayer) return const SizedBox.shrink();

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < -10) {
              _openPlayer(context, audio);
            } else if (details.primaryDelta! > 10) {
              // Pause playback when miniplayer is dismissed via swipe down
              if (audio.isPlaying) {
                audio.pause();
              }
              audio.setShowMiniPlayer(false);
            }
          },
          onTap: () => _openPlayer(context, audio),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'player_${song.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkWidth: 48,
                            artworkHeight: 48,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: Container(
                              width: 48,
                              height: 48,
                              color: Colors.white10,
                              child: const Icon(Icons.music_note_rounded, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 14,
                                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                              ),
                            ),
                            Text(
                              song.artist ?? 'Unknown Artist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7), 
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: themeManager.accentColor,
                          size: 30,
                        ),
                        onPressed: audio.togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
                        onPressed: audio.playNext,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openPlayer(BuildContext context, AudioPlayerService audio) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ThemedPlayerScreen(
          songs: audio.playlist,
          initialIndex: audio.currentIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
