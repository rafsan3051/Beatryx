import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../services/theme_manager.dart';
import '../services/music_provider.dart';
import 'themed_player_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(playlistId: playlist.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  void _showAddSongsDialog() {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final playlistService = Provider.of<PlaylistService>(context, listen: false);
    final theme = Provider.of<ThemeManager>(context, listen: false);
    
    final playlist = playlistService.playlists.firstWhere((p) => p.id == widget.playlistId);
    final availableSongs = musicProvider.songs.where((s) => !playlist.songIds.contains(s.id.toString())).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Add Songs', style: TextStyle(color: theme.textColor, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: availableSongs.isEmpty
                ? Center(child: Text('All songs are already in this playlist', style: TextStyle(color: theme.subtitleColor)))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: availableSongs.length,
                    itemBuilder: (context, index) {
                      final song = availableSongs[index];
                      return ListTile(
                        leading: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Icon(Icons.music_note, color: theme.subtitleColor),
                        ),
                        title: Text(song.title, style: TextStyle(color: theme.textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(song.artist ?? 'Unknown', style: TextStyle(color: theme.subtitleColor)),
                        onTap: () {
                          playlistService.addSongToPlaylist(widget.playlistId, song.id.toString());
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${song.title}')));
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    
    final playlist = playlistService.playlists.firstWhere((p) => p.id == widget.playlistId);
    final playlistSongs = musicProvider.songs.where((s) => playlist.songIds.contains(s.id.toString())).toList();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(playlist.name, style: TextStyle(color: theme.textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: playlistSongs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note_rounded, size: 64, color: theme.subtitleColor),
                const SizedBox(height: 16),
                Text('Empty Playlist', style: TextStyle(color: theme.textColor, fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showAddSongsDialog,
                  child: const Text('Add Songs'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: playlistSongs.length,
            itemBuilder: (context, index) {
              final song = playlistSongs[index];
              return ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Icon(Icons.music_note, color: theme.subtitleColor),
                ),
                title: Text(song.title, style: TextStyle(color: theme.textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(song.artist ?? 'Unknown', style: TextStyle(color: theme.subtitleColor)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  onPressed: () => playlistService.removeSongFromPlaylist(widget.playlistId, song.id.toString()),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThemedPlayerScreen(songs: playlistSongs, initialIndex: index),
                    ),
                  );
                },
              );
            },
          ),
      floatingActionButton: playlistSongs.isNotEmpty ? FloatingActionButton(
        onPressed: _showAddSongsDialog,
        backgroundColor: theme.accentColor,
        child: const Icon(Icons.add, color: Colors.black),
      ) : null,
    );
  }
}
