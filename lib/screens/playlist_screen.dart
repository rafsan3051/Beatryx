import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../services/theme_manager.dart';
import '../services/music_provider.dart';
import 'themed_player_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context) {
    final playlistService = Provider.of<PlaylistService>(context, listen: false);
    final theme = Provider.of<ThemeManager>(context, listen: false);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceColor,
        title: Text('New Playlist', style: TextStyle(color: theme.textColor)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: theme.textColor),
          decoration: InputDecoration(
            hintText: 'Enter playlist name',
            hintStyle: TextStyle(color: theme.subtitleColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.subtitleColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                playlistService.createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, String playlistId, String playlistName) {
    final playlistService = Provider.of<PlaylistService>(context, listen: false);
    final theme = Provider.of<ThemeManager>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete Playlist', style: TextStyle(color: Colors.red)),
            onTap: () {
              playlistService.deletePlaylist(playlistId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Playlists',
          style: TextStyle(
            color: theme.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_rounded, color: theme.accentColor),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
      body: playlistService.playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_add_rounded, size: 64, color: theme.subtitleColor),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: TextStyle(color: theme.textColor, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showCreatePlaylistDialog(context),
                    child: const Text('Create Playlist'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: playlistService.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistService.playlists[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.music_note_rounded, color: theme.accentColor),
                  ),
                  title: Text(
                    playlist.name,
                    style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${playlist.songIds.length} songs',
                    style: TextStyle(color: theme.subtitleColor),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: theme.subtitleColor),
                    onPressed: () => _showPlaylistOptions(context, playlist.id, playlist.name),
                  ),
                  onTap: () {
                    final playlistSongs = musicProvider.songs.where((song) => 
                      playlist.songIds.contains(song.id.toString())
                    ).toList();
                    
                    if (playlistSongs.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThemedPlayerScreen(
                            songs: playlistSongs,
                            initialIndex: 0,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Playlist is empty. Add songs from the Home screen.')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
