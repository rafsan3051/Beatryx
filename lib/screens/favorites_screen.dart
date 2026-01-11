import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/music_provider.dart';
import '../services/playlist_service.dart';
import '../services/theme_manager.dart';
import '../services/ui_manager.dart';
import '../services/audio_service.dart';
import 'themed_player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final uiManager = Provider.of<UIManager>(context);
    final audioService = Provider.of<AudioPlayerService>(context);
    final isAura = uiManager.currentUI.isAura;
    final isDark = theme.isDarkMode;
    
    final favoriteSongs = musicProvider.songs.where((song) => 
      playlistService.isFavorite(song.id.toString())
    ).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: isAura ? null : IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Favourites',
          style: TextStyle(
            color: isAura ? (isDark ? Colors.white : Colors.black87) : theme.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteSongs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded, 
                    size: 64, 
                    color: isAura ? (isDark ? Colors.white10 : Colors.black12) : theme.subtitleColor
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: isAura ? (isDark ? Colors.white38 : Colors.black45) : theme.textColor, 
                      fontSize: 18
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 150, left: 16, right: 16),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                final isPlaying = audioService.currentSong?.id == song.id;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isPlaying 
                        ? theme.accentColor.withValues(alpha: isAura ? 0.08 : 0.05) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    leading: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isAura ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)) : theme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.music_note_rounded, 
                                color: isAura ? (isDark ? Colors.white24 : Colors.black26) : theme.subtitleColor
                              ),
                            ),
                          ),
                        ),
                        if (isPlaying)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.bar_chart_rounded,
                                color: theme.accentColor,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isPlaying 
                            ? theme.accentColor 
                            : (isAura ? (isDark ? Colors.white : Colors.black87) : theme.textColor), 
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600
                      ),
                    ),
                    subtitle: Text(
                      song.artist ?? "Unknown Artist",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isPlaying 
                            ? theme.accentColor.withValues(alpha: 0.7) 
                            : (isAura ? (isDark ? Colors.white38 : Colors.black45) : theme.subtitleColor)
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite, 
                        color: isAura ? theme.accentColor : Colors.red
                      ),
                      onPressed: () => playlistService.toggleFavorite(song.id.toString()),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThemedPlayerScreen(
                            songs: favoriteSongs,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
