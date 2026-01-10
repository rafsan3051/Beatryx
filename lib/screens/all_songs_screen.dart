import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/music_provider.dart';
import '../services/playlist_service.dart';
import '../services/theme_manager.dart';
import 'themed_player_screen.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final Set<int> _selectedSongIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(int songId) {
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
        if (_selectedSongIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedSongIds.add(songId);
        _isSelectionMode = true;
      }
    });
  }

  void _showPlaylistDialog(List<SongModel> selectedSongs) {
    final playlistService = Provider.of<PlaylistService>(context, listen: false);
    final theme = Provider.of<ThemeManager>(context, listen: false);
    
    if (playlistService.playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No playlists found. Create one in the Playlists tab.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceColor,
        title: Text('Add to Playlist', style: TextStyle(color: theme.textColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlistService.playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlistService.playlists[index];
              return ListTile(
                title: Text(playlist.name, style: TextStyle(color: theme.textColor)),
                onTap: () {
                  for (var song in selectedSongs) {
                    playlistService.addSongToPlaylist(playlist.id, song.id.toString());
                  }
                  setState(() {
                    _selectedSongIds.clear();
                    _isSelectionMode = false;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${selectedSongs.length} songs to ${playlist.name}')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleBulkDelete(List<SongModel> selectedSongs) {
    // In a real app, this would delete files. For now, we'll just show a snackbar
    // as deleting local files requires specific permissions and logic.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete feature for ${selectedSongs.length} songs coming soon!')),
    );
    setState(() {
      _selectedSongIds.clear();
      _isSelectionMode = false;
    });
  }

  void _handleBulkFavorite(List<SongModel> selectedSongs) {
    final playlistService = Provider.of<PlaylistService>(context, listen: false);
    for (var song in selectedSongs) {
      if (!playlistService.isFavorite(song.id.toString())) {
        playlistService.toggleFavorite(song.id.toString());
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${selectedSongs.length} songs to Favourites')),
    );
    setState(() {
      _selectedSongIds.clear();
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: _isSelectionMode ? theme.surfaceColor : Colors.transparent,
        elevation: 0,
        leading: _isSelectionMode 
          ? IconButton(
              icon: Icon(Icons.close, color: theme.textColor),
              onPressed: () => setState(() {
                _selectedSongIds.clear();
                _isSelectionMode = false;
              }),
            )
          : IconButton(
              icon: Icon(Icons.arrow_back, color: theme.textColor),
              onPressed: () => Navigator.pop(context),
            ),
        title: Text(
          _isSelectionMode ? '${_selectedSongIds.length} Selected' : 'All Songs',
          style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
        ),
        actions: _isSelectionMode ? [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.textColor),
            onSelected: (value) {
              final selectedSongs = musicProvider.songs
                  .where((s) => _selectedSongIds.contains(s.id))
                  .toList();
              
              if (value == 'add_to_playlist') {
                _showPlaylistDialog(selectedSongs);
              } else if (value == 'delete') {
                _handleBulkDelete(selectedSongs);
              } else if (value == 'favorite') {
                _handleBulkFavorite(selectedSongs);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_to_playlist',
                child: Row(
                  children: [
                    Icon(Icons.playlist_add, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Add to Playlist'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Favourite All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ] : [],
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          if (!musicProvider.permissionGranted) {
            return Center(child: Text('Permission not granted.', style: TextStyle(color: theme.textColor)));
          }

          if (musicProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (musicProvider.songs.isEmpty) {
            return Center(child: Text("No Songs Found", style: TextStyle(color: theme.textColor)));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: musicProvider.songs.length,
            itemBuilder: (context, index) {
              final song = musicProvider.songs[index];
              final isSelected = _selectedSongIds.contains(song.id);

              return ListTile(
                selected: isSelected,
                selectedTileColor: theme.accentColor.withValues(alpha: 0.1),
                leading: Stack(
                  children: [
                    QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: theme.subtitleColor),
                      ),
                    ),
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  song.title, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(color: theme.textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
                ),
                subtitle: Text(
                  song.artist ?? "Unknown Artist", 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(color: theme.subtitleColor)
                ),
                onLongPress: () => _toggleSelection(song.id),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(song.id);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThemedPlayerScreen(
                          songs: musicProvider.songs,
                          initialIndex: index,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
