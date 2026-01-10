import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/music_provider.dart';
import '../services/theme_manager.dart';
import '../services/user_provider.dart';
import '../services/playlist_service.dart';
import '../services/ui_manager.dart';
import 'themed_player_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum SongSortOrder {
  newest,
  oldest,
  alphabetical,
  artist
}

class ThemedHomeScreen extends StatefulWidget {
  const ThemedHomeScreen({super.key});

  @override
  State<ThemedHomeScreen> createState() => _ThemedHomeScreenState();
}

class _ThemedHomeScreenState extends State<ThemedHomeScreen> {
  SongSortOrder _currentSortOrder = SongSortOrder.newest;
  final Set<int> _selectedSongIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedSongIds.contains(id)) {
        _selectedSongIds.remove(id);
        if (_selectedSongIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedSongIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedSongIds.clear();
      _isSelectionMode = false;
    });
  }

  void _showProfileMenu(BuildContext context, UserProvider userProvider, ThemeManager theme) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFloatingOption(
                  icon: Icons.person_outline_rounded,
                  title: 'Set Profile Manually',
                  onTap: () {
                    Navigator.pop(context);
                    _showManualProfileDialog(context, userProvider, theme);
                  },
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildFloatingOption(
                  imageAsset: 'assets/icons/google_logo.png',
                  title: 'Sign in with Google',
                  onTap: () {
                    Navigator.pop(context);
                    userProvider.signInWithGoogle();
                  },
                  theme: theme,
                ),
                if (userProvider.isSignedIn) ...[
                  const SizedBox(height: 12),
                  _buildFloatingOption(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    onTap: () {
                      Navigator.pop(context);
                      userProvider.signOut();
                    },
                    theme: theme,
                    isDestructive: true,
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: TextStyle(color: theme.subtitleColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingOption({
    IconData? icon,
    String? imageAsset,
    required String title,
    required VoidCallback onTap,
    required ThemeManager theme,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.textColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (imageAsset != null)
              Image.asset(imageAsset, width: 24, height: 24)
            else if (icon != null)
              Icon(icon, color: isDestructive ? Colors.redAccent : theme.accentColor),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isDestructive ? Colors.redAccent : theme.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualProfileDialog(BuildContext context, UserProvider userProvider, ThemeManager theme) {
    final nameController = TextEditingController(text: userProvider.displayName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Set Profile', style: TextStyle(color: theme.textColor)),
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
                  backgroundColor: theme.accentColor.withValues(alpha: 0.1),
                  backgroundImage: user.photoUrl != null && File(user.photoUrl!).existsSync()
                      ? FileImage(File(user.photoUrl!))
                      : null,
                  child: user.photoUrl == null || !File(user.photoUrl!).existsSync()
                      ? Icon(Icons.add_a_photo_rounded, color: theme.accentColor)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              style: TextStyle(color: theme.textColor),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: theme.subtitleColor),
                filled: true,
                fillColor: theme.textColor.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.setLocalProfile(nameController.text, userProvider.photoUrl);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        sortedSongs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
      case SongSortOrder.oldest:
        sortedSongs.sort((a, b) => (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0));
        break;
      case SongSortOrder.alphabetical:
        sortedSongs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSortOrder.artist:
        sortedSongs.sort((a, b) => (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase()));
        break;
    }
    return sortedSongs;
  }

  void _showSortOptions(BuildContext context, ThemeManager theme) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sort By', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor)),
                const SizedBox(height: 16),
                _buildSortOption('Recently Added', SongSortOrder.newest, theme),
                _buildSortOption('Oldest First', SongSortOrder.oldest, theme),
                _buildSortOption('Alphabetical (A-Z)', SongSortOrder.alphabetical, theme),
                _buildSortOption('Artist Name', SongSortOrder.artist, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, SongSortOrder order, ThemeManager theme) {
    final isSelected = _currentSortOrder == order;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.accentColor : theme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: theme.accentColor) : null,
      onTap: () {
        setState(() => _currentSortOrder = order);
        Navigator.pop(context);
      },
    );
  }

  void _handleSwipeAction(SongModel song, SwipeAction action, PlaylistService playlistService) {
    switch (action) {
      case SwipeAction.favorite:
        playlistService.toggleFavorite(song.id.toString());
        break;
      case SwipeAction.playlist:
        // TODO: Show playlist picker
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add to Playlist feature coming soon!')));
        break;
      case SwipeAction.delete:
        // Handle delete if needed
        break;
      case SwipeAction.none:
        break;
    }
  }

  Widget _buildSwipeBackground(SwipeAction action, bool isRight, ThemeManager theme, PlaylistService playlistService, SongModel song) {
    IconData icon;
    String label;
    Color color;

    switch (action) {
      case SwipeAction.favorite:
        final isFav = playlistService.isFavorite(song.id.toString());
        icon = isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded;
        label = isFav ? 'Remove Favorite' : 'Add Favorite';
        color = Colors.redAccent;
        break;
      case SwipeAction.playlist:
        icon = Icons.playlist_add_rounded;
        label = 'To Playlist';
        color = theme.accentColor;
        break;
      case SwipeAction.delete:
        icon = Icons.delete_outline_rounded;
        label = 'Delete';
        color = Colors.orangeAccent;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      alignment: isRight ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRight) Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          if (!isRight) Icon(icon, color: color),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    final uiManager = Provider.of<UIManager>(context);

    final sortedSongs = _getSortedSongs(musicProvider.songs);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Header
                        if (!_isSelectionMode)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hello, ${userProvider.displayName}!',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: theme.textColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showProfileMenu(context, userProvider, theme),
                              child: Consumer<UserProvider>(
                                builder: (context, user, _) => CircleAvatar(
                                  radius: 22,
                                  backgroundColor: theme.surfaceColor,
                                  backgroundImage: user.photoUrl != null 
                                      ? (user.isSignedIn 
                                          ? NetworkImage(user.photoUrl!) 
                                          : (File(user.photoUrl!).existsSync() ? FileImage(File(user.photoUrl!)) : null) as ImageProvider?)
                                      : null,
                                  child: user.photoUrl == null || (!user.isSignedIn && !File(user.photoUrl!).existsSync())
                                      ? Icon(Icons.person_rounded, color: theme.textColor.withValues(alpha: 0.7))
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ) else const SizedBox(height: 44),
                        const SizedBox(height: 28),
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: theme.surfaceColor,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: TextField(
                            style: TextStyle(color: theme.textColor),
                            decoration: InputDecoration(
                              hintText: 'Search for a song',
                              hintStyle: GoogleFonts.poppins(color: theme.subtitleColor, fontSize: 15),
                              suffixIcon: Icon(Icons.search_rounded, color: theme.subtitleColor, size: 24),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Sorting and Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Songs',
                              style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w600, color: theme.textColor),
                            ),
                            IconButton(
                              icon: Icon(Icons.sort_rounded, color: theme.accentColor),
                              onPressed: () => _showSortOptions(context, theme),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                
                musicProvider.isLoading
                  ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  : sortedSongs.isEmpty
                    ? SliverFillRemaining(child: Center(child: Text("No Songs Found", style: TextStyle(color: theme.textColor))))
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final song = sortedSongs[index];
                              final isSelected = _selectedSongIds.contains(song.id);
                              
                              Widget tileContent = Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.accentColor.withValues(alpha: 0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                            color: theme.surfaceColor,
                                            child: Icon(Icons.music_note_rounded, color: theme.subtitleColor),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: theme.accentColor.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.check, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: theme.textColor, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    song.artist ?? 'Unknown Artist',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: theme.subtitleColor, fontSize: 12),
                                  ),
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      _toggleSelection(song.id);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ThemedPlayerScreen(
                                            songs: sortedSongs,
                                            initialIndex: index,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onLongPress: () => _toggleSelection(song.id),
                                ),
                              );

                              // Only apply Dismissible if swipe is enabled in UIManager
                              if (uiManager.swipeEnabled && !_isSelectionMode) {
                                tileContent = Dismissible(
                                  key: Key('song_swipe_${song.id}'),
                                  direction: DismissDirection.horizontal,
                                  background: _buildSwipeBackground(uiManager.leftToRightAction, true, theme, playlistService, song),
                                  secondaryBackground: _buildSwipeBackground(uiManager.rightToLeftAction, false, theme, playlistService, song),
                                  confirmDismiss: (direction) async {
                                    final action = direction == DismissDirection.startToEnd 
                                        ? uiManager.leftToRightAction 
                                        : uiManager.rightToLeftAction;
                                    _handleSwipeAction(song, action, playlistService);
                                    return false; // Prevents the tile from disappearing
                                  },
                                  child: tileContent,
                                );
                              }

                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 300 + (index % 10 * 50)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) => Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  child: tileContent,
                                ),
                              );
                            },
                            childCount: sortedSongs.length,
                          ),
                        ),
                      ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 150)),
              ],
            ),
            
            // Selection Mode Overlay
            if (_isSelectionMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: theme.textColor,
                      onPressed: _clearSelection,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedSongIds.length} Selected',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.playlist_add, color: theme.accentColor),
                      onPressed: () {
                        // TODO: Implement add selected to playlist
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Adding ${_selectedSongIds.length} songs to playlist...'))
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
