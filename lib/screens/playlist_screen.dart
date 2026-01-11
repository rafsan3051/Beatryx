import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../services/theme_manager.dart';
import '../services/music_provider.dart';
import '../services/ui_manager.dart';
import '../services/audio_service.dart';
import 'themed_player_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context) {
    final playlistService = Provider.of<PlaylistService>(context, listen: false);
    final theme = Provider.of<ThemeManager>(context, listen: false);
    final uiManager = Provider.of<UIManager>(context, listen: false);
    final isAura = uiManager.currentUI.isAura;
    final isDark = theme.isDarkMode;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : (isAura ? Colors.white : theme.surfaceColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('New Playlist', style: TextStyle(color: isDark ? Colors.white : (isAura ? Colors.black87 : theme.textColor))),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : (isAura ? Colors.black87 : theme.textColor)),
          decoration: InputDecoration(
            hintText: 'Enter playlist name',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : (isAura ? Colors.black45 : theme.subtitleColor)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? Colors.white10 : (isAura ? Colors.black12 : theme.subtitleColor)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.accentColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white38 : (isAura ? Colors.black45 : theme.subtitleColor))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                playlistService.createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, String playlistId, String playlistName) {
    final playlistService = Provider.of<PlaylistService>(context, listen: false);
    final theme = Provider.of<ThemeManager>(context, listen: false);
    final isDark = theme.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(2)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete Playlist', style: TextStyle(color: Colors.red)),
            onTap: () {
              playlistService.deletePlaylist(playlistId);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    final uiManager = Provider.of<UIManager>(context);
    final isAura = uiManager.currentUI.isAura;
    final isDark = theme.isDarkMode;

    return Scaffold(
      backgroundColor: isAura ? Colors.transparent : theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: isAura ? null : IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Playlists',
          style: TextStyle(
            color: isAura ? (isDark ? Colors.white : Colors.black87) : theme.textColor,
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
                  Icon(Icons.playlist_add_rounded, size: 64, color: isDark ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: TextStyle(color: isDark ? Colors.white38 : (isAura ? Colors.black45 : theme.textColor), fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showCreatePlaylistDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                    ),
                    child: const Text('Create Playlist'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 150, left: 16, right: 16),
              itemCount: playlistService.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistService.playlists[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.music_note_rounded, color: theme.accentColor),
                  ),
                  title: Text(
                    playlist.name,
                    style: TextStyle(color: isDark ? Colors.white : (isAura ? Colors.black87 : theme.textColor), fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${playlist.songIds.length} songs',
                    style: TextStyle(color: isDark ? Colors.white38 : (isAura ? Colors.black45 : theme.subtitleColor)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: isDark ? Colors.white24 : Colors.black26),
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
    final isDark = theme.isDarkMode;
    
    final playlist = playlistService.playlists.firstWhere((p) => p.id == widget.playlistId);
    final availableSongs = musicProvider.songs.where((s) => !playlist.songIds.contains(s.id.toString())).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              child: Text('Add Songs', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: availableSongs.isEmpty
                ? Center(child: Text('All songs are already in this playlist', style: TextStyle(color: isDark ? Colors.white38 : Colors.black45)))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: availableSongs.length,
                    itemBuilder: (context, index) {
                      final song = availableSongs[index];
                      return ListTile(
                        leading: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Icon(Icons.music_note, color: isDark ? Colors.white24 : Colors.black12),
                        ),
                        title: Text(song.title, style: TextStyle(color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(song.artist ?? 'Unknown', style: TextStyle(color: isDark ? Colors.white38 : Colors.black45)),
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
    final uiManager = Provider.of<UIManager>(context);
    final audioService = Provider.of<AudioPlayerService>(context);
    final isAura = uiManager.currentUI.isAura;
    final isDark = theme.isDarkMode;
    
    final playlist = playlistService.playlists.firstWhere((p) => p.id == widget.playlistId);
    final playlistSongs = musicProvider.songs.where((s) => playlist.songIds.contains(s.id.toString())).toList();

    return Scaffold(
      backgroundColor: isAura ? (isDark ? theme.backgroundColor : Colors.white) : theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(playlist.name, style: TextStyle(color: isDark ? Colors.white : (isAura ? Colors.black87 : theme.textColor))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : (isAura ? Colors.black87 : theme.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: playlistSongs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note_rounded, size: 64, color: isDark ? Colors.white10 : Colors.black12),
                const SizedBox(height: 16),
                Text('Empty Playlist', style: TextStyle(color: isDark ? Colors.white38 : (isAura ? Colors.black45 : theme.textColor), fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showAddSongsDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
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
              final isPlaying = audioService.currentSong?.id == song.id;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
                        borderRadius: BorderRadius.circular(8),
                        child: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Icon(Icons.music_note, color: isDark ? Colors.white24 : Colors.black12),
                        ),
                      ),
                      if (isPlaying)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
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
                    style: TextStyle(
                      color: isPlaying 
                          ? theme.accentColor 
                          : (isDark ? Colors.white : (isAura ? Colors.black87 : theme.textColor)),
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600
                    ), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  subtitle: Text(
                    song.artist ?? 'Unknown', 
                    style: TextStyle(
                      color: isPlaying 
                          ? theme.accentColor.withValues(alpha: 0.7) 
                          : (isDark ? Colors.white38 : (isAura ? Colors.black45 : theme.subtitleColor))
                    )
                  ),
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
                ),
              );
            },
          ),
      floatingActionButton: playlistSongs.isNotEmpty ? FloatingActionButton(
        onPressed: _showAddSongsDialog,
        backgroundColor: theme.accentColor,
        child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
      ) : null,
    );
  }
}
