import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/music_provider.dart';
import '../services/playlist_service.dart';
import '../services/theme_manager.dart';
import 'themed_player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    
    // Filter musicProvider songs to get only favorites
    final favoriteSongs = musicProvider.songs.where((song) => 
      playlistService.isFavorite(song.id.toString())
    ).toList();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Favourites',
          style: TextStyle(
            color: theme.textColor,
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
                  Icon(Icons.favorite_border_rounded, size: 64, color: theme.subtitleColor),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(color: theme.textColor, fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 150, left: 16, right: 16),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.music_note_rounded, color: theme.subtitleColor),
                    ),
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    song.artist ?? "Unknown Artist",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.subtitleColor),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
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
                );
              },
            ),
    );
  }
}
