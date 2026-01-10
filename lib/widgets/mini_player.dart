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
        if (song == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ThemedPlayerScreen(
                          songs: audio.playlist,
                          initialIndex: audio.currentIndex,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          artworkWidth: 56,
                          artworkHeight: 56,
                          artworkFit: BoxFit.cover,
                          nullArtworkWidget: Container(
                            width: 56,
                            height: 56,
                            color: Colors.white10,
                            child: const Icon(Icons.music_note_rounded, color: Colors.white24),
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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            Text(
                              song.artist ?? 'Unknown Artist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: const Color(0xFF00C2A0),
                          size: 32,
                        ),
                        onPressed: audio.togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
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
}
