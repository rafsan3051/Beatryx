import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/music_provider.dart';
import '../services/theme_manager.dart';
import '../services/user_provider.dart';
import '../services/playlist_service.dart';
import '../services/ui_manager.dart';
import '../services/audio_service.dart';
import '../models/song.dart';
import 'themed_player_screen.dart';

enum SongSortOrder { newest, oldest, alphabetical, artist }

class AuraHomeScreen extends StatefulWidget {
  const AuraHomeScreen({super.key});

  @override
  State<AuraHomeScreen> createState() => _AuraHomeScreenState();
}

class _AuraHomeScreenState extends State<AuraHomeScreen> {
  SongSortOrder _currentSortOrder = SongSortOrder.newest;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  void _showSearchDialog(
      BuildContext context, MusicProvider musicProvider, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      pageBuilder: (context, anim1, anim2) =>
          _SearchOverlay(musicProvider: musicProvider, isDark: isDark),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  void _showProfileMenu(BuildContext context, UserProvider userProvider,
      ThemeManager theme, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileOption(
                  icon: Icons.person_outline_rounded,
                  title: 'Set Profile Manually',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _showManualProfileDialog(
                        context, userProvider, theme, isDark);
                  },
                ),
                const SizedBox(height: 12),
                _buildProfileOption(
                  icon: Icons.login_rounded,
                  title: 'Sign in with Google',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    userProvider.signInWithGoogle();
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close',
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black45)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD81B60)),
            const SizedBox(width: 16),
            Text(title,
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showManualProfileDialog(BuildContext context, UserProvider userProvider,
      ThemeManager theme, bool isDark) {
    final nameController =
        TextEditingController(text: userProvider.displayName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Set Profile',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                await userProvider.pickLocalAvatar();
              },
              borderRadius: BorderRadius.circular(50),
              child: Consumer<UserProvider>(
                builder: (context, user, _) => CircleAvatar(
                  radius: 40,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  backgroundImage:
                      user.photoUrl != null && File(user.photoUrl!).existsSync()
                          ? FileImage(File(user.photoUrl!))
                          : null,
                  child: user.photoUrl == null ||
                          !File(user.photoUrl!).existsSync()
                      ? const Icon(Icons.add_a_photo_rounded,
                          color: Color(0xFFD81B60))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle:
                    TextStyle(color: isDark ? Colors.white38 : Colors.black45),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              userProvider.setLocalProfile(
                  nameController.text, userProvider.photoUrl);
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<SongModel> _getSortedSongs(List<SongModel> songs) {
    List<SongModel> sortedSongs = List.from(songs);
    switch (_currentSortOrder) {
      case SongSortOrder.newest:
        sortedSongs
            .sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
      case SongSortOrder.oldest:
        sortedSongs
            .sort((a, b) => (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0));
        break;
      case SongSortOrder.alphabetical:
        sortedSongs.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSortOrder.artist:
        sortedSongs.sort((a, b) => (a.artist ?? '')
            .toLowerCase()
            .compareTo((b.artist ?? '').toLowerCase()));
        break;
    }
    return sortedSongs;
  }

  void _showSortOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort By',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 16),
            _buildSortOption('Recently Added', SongSortOrder.newest, isDark),
            _buildSortOption('Oldest First', SongSortOrder.oldest, isDark),
            _buildSortOption(
                'Alphabetical', SongSortOrder.alphabetical, isDark),
            _buildSortOption('Artist Name', SongSortOrder.artist, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, SongSortOrder order, bool isDark) {
    final isSelected = _currentSortOrder == order;
    return ListTile(
      title: Text(title,
          style: TextStyle(
              color: isSelected
                  ? const Color(0xFFD81B60)
                  : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFFD81B60))
          : null,
      onTap: () {
        setState(() => _currentSortOrder = order);
        Navigator.pop(context);
      },
    );
  }

  void _handleSwipeAction(SongModel song, SwipeAction action,
      PlaylistService playlistService, MusicProvider musicProvider) {
    switch (action) {
      case SwipeAction.favorite:
        playlistService.toggleFavorite(song.id.toString());
        break;
      case SwipeAction.playlist:
        _showAddToPlaylistDialog(song, playlistService);
        break;
      case SwipeAction.delete:
        _showDeleteConfirmDialog(song, musicProvider);
        break;
      case SwipeAction.none:
        break;
    }
  }

  void _showAddToPlaylistDialog(
      SongModel song, PlaylistService playlistService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add to Playlist',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (playlistService.playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No playlists created yet',
                    style: TextStyle(color: Colors.white54)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlistService.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlistService.playlists[index];
                    return ListTile(
                      leading: const Icon(Icons.playlist_add,
                          color: Color(0xFFD81B60)),
                      title: Text(playlist.name,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        playlistService.addSongToPlaylist(
                            playlist.id, song.id.toString());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Added to ${playlist.name}')));
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

  void _showDeleteConfirmDialog(SongModel song, MusicProvider musicProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "${song.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Request permissions first
                  final status =
                      await Permission.manageExternalStorage.request();

                  if (!status.isGranted) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Permission denied. Cannot delete file without storage access.')),
                      );
                    }
                    return;
                  }

                  const platform = MethodChannel('com.example.beatryx/files');
                  bool deleted = false;

                  // Try native deletion first (works with MediaStore)
                  try {
                    deleted = await platform
                        .invokeMethod('deleteFile', {'path': song.data});
                  } catch (e) {
                    debugPrint('Native delete failed: $e');
                    // Fallback to direct file deletion
                    try {
                      final file = File(song.data);
                      if (await file.exists()) {
                        await file.delete();
                        deleted = true;
                      }
                    } catch (e) {
                      debugPrint('Direct delete also failed: $e');
                    }
                  }

                  if (deleted) {
                    await musicProvider.fetchSongs();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Song deleted successfully')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Could not delete file. Try again or check storage permissions.')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(SwipeAction action, bool isRight,
      PlaylistService playlistService, SongModel song, bool isDark) {
    IconData icon;
    String label;
    Color color;

    switch (action) {
      case SwipeAction.favorite:
        final isFav = playlistService.isFavorite(song.id.toString());
        icon = isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded;
        label = isFav ? 'Remove' : 'Favorite';
        color = const Color(0xFFD81B60);
        break;
      case SwipeAction.playlist:
        icon = Icons.playlist_add_rounded;
        label = 'Playlist';
        color = const Color(0xFF6C63FF);
        break;
      case SwipeAction.delete:
        icon = Icons.delete_outline_rounded;
        label = 'Delete';
        color = Colors.redAccent;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      alignment: isRight ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRight) Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              )),
          const SizedBox(width: 12),
          if (!isRight) Icon(icon, color: color),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    final theme = Provider.of<ThemeManager>(context);
    final uiManager = Provider.of<UIManager>(context);
    final audioService = Provider.of<AudioPlayerService>(context);
    final isDark = theme.isDarkMode;

    final allSongsForStats = musicProvider.songs
        .map((s) => Song(
              id: s.id.toString(),
              title: s.title,
              artist: s.artist ?? 'Unknown',
              album: s.album ?? 'Unknown',
              duration: s.duration.toString(),
              filePath: s.data,
            ))
        .toList();

    final mostPlayed = playlistService.getMostPlayed(allSongsForStats);
    final topSong = mostPlayed.isNotEmpty
        ? musicProvider.songs
            .firstWhere((s) => s.id.toString() == mostPlayed.first.id)
        : (musicProvider.songs.isNotEmpty ? musicProvider.songs.first : null);

    final sortedSongs = _getSortedSongs(musicProvider.songs);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${userProvider.displayName} !',
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(_getGreeting(),
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.white38 : Colors.black45,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () =>
                        _showSearchDialog(context, musicProvider, isDark),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle),
                      child: Icon(Icons.search_rounded,
                          color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        _showProfileMenu(context, userProvider, theme, isDark),
                    child: Consumer<UserProvider>(
                      builder: (context, user, _) => CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                        backgroundImage: user.photoUrl != null
                            ? (user.isSignedIn
                                ? NetworkImage(user.photoUrl!)
                                : (File(user.photoUrl!).existsSync()
                                    ? FileImage(File(user.photoUrl!))
                                    : null) as ImageProvider?)
                            : null,
                        child: user.photoUrl == null ||
                                (!user.isSignedIn &&
                                    !File(user.photoUrl!).existsSync())
                            ? Icon(Icons.person_rounded,
                                color: isDark ? Colors.white38 : Colors.black45)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Banner Card
          if (topSong != null)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text('Most Played',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ThemedPlayerScreen(songs: [topSong], initialIndex: 0),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFFD81B60)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -30,
                              top: -30,
                              child: Opacity(
                                opacity: 0.15,
                                child: QueryArtworkWidget(
                                  id: topSong.id,
                                  type: ArtworkType.AUDIO,
                                  artworkWidth: 220,
                                  artworkHeight: 220,
                                  nullArtworkWidget: const Icon(
                                      Icons.music_note_rounded,
                                      size: 200,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    topSong.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(topSong.artist ?? 'Unknown Artist',
                                      style:
                                          GoogleFonts.poppins(color: Colors.white70)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Text('Listen Now',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // All Songs with Sort Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 12, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All Songs',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87),
                  ),
                  IconButton(
                      icon: const Icon(Icons.sort_rounded,
                          color: Color(0xFFD81B60)),
                      onPressed: () => _showSortOptions(isDark)),
                ],
              ),
            ),
          ),

          musicProvider.isLoading
              ? const SliverToBoxAdapter(child: SizedBox.shrink())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = sortedSongs[index];
                      final isPlaying = audioService.currentSong?.id == song.id;

                      Widget tileContent = Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isPlaying 
                                ? theme.accentColor.withValues(alpha: 0.08) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ThemedPlayerScreen(
                                        songs: sortedSongs, initialIndex: index)),
                              );
                            },
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
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : Colors.black.withValues(alpha: 0.05),
                                        child: Icon(Icons.music_note_rounded,
                                            color: isDark
                                                ? Colors.white24
                                                : Colors.black12)),
                                  ),
                                ),
                                if (isPlaying)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                          Icons.bar_chart_rounded,
                                          color: theme.accentColor,
                                          size: 24),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                                    color: isPlaying ? theme.accentColor : (isDark ? Colors.white : Colors.black87))),
                            subtitle: Text(song.artist ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isPlaying 
                                        ? theme.accentColor.withValues(alpha: 0.7) 
                                        : (isDark ? Colors.white38 : Colors.black45))),
                            trailing: null, // Removed the 3 dots
                          ),
                        ),
                      );

                      // Add Swipe Gestures if enabled in settings
                      if (uiManager.swipeEnabled) {
                        return Dismissible(
                          key: Key('song_swipe_${song.id}'),
                          direction: DismissDirection.horizontal,
                          background: _buildSwipeBackground(
                              uiManager.leftToRightAction,
                              true,
                              playlistService,
                              song,
                              isDark),
                          secondaryBackground: _buildSwipeBackground(
                              uiManager.rightToLeftAction,
                              false,
                              playlistService,
                              song,
                              isDark),
                          confirmDismiss: (direction) async {
                            final action =
                                direction == DismissDirection.startToEnd
                                    ? uiManager.leftToRightAction
                                    : uiManager.rightToLeftAction;
                            _handleSwipeAction(
                                song, action, playlistService, musicProvider);
                            return false;
                          },
                          child: tileContent,
                        );
                      }

                      return tileContent;
                    },
                    childCount: sortedSongs.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 180)),
        ],
      ),
    );
  }
}

class _SearchOverlay extends StatefulWidget {
  final MusicProvider musicProvider;
  final bool isDark;
  const _SearchOverlay({required this.musicProvider, required this.isDark});

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  List<SongModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchResults = widget.musicProvider.songs;
  }

  void _search(String query) {
    setState(() {
      _searchResults = widget.musicProvider.songs
          .where((song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              (song.artist ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: widget.isDark ? Colors.white70 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _search,
          style:
              TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
              hintText: 'Search songs, artists...',
              hintStyle: TextStyle(
                  color: widget.isDark ? Colors.white38 : Colors.black45),
              border: InputBorder.none),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final song = _searchResults[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: QueryArtworkWidget(
                id: song.id,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: Container(
                    width: 45,
                    height: 45,
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    child: Icon(Icons.music_note,
                        color:
                            widget.isDark ? Colors.white24 : Colors.black12)),
              ),
            ),
            title: Text(song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: widget.isDark ? Colors.white : Colors.black87)),
            subtitle: Text(song.artist ?? 'Unknown',
                maxLines: 1,
                style: TextStyle(
                    color: widget.isDark ? Colors.white38 : Colors.black45)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ThemedPlayerScreen(
                        songs: widget.musicProvider.songs,
                        initialIndex:
                            widget.musicProvider.songs.indexOf(song))),
              );
            },
          );
        },
      ),
    );
  }
}
