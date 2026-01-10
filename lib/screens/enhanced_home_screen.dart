import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/player_service.dart';
import '../services/music_scanner_service.dart';
import '../widgets/modern_bottom_nav.dart';
import '../widgets/glassmorphic_card.dart';
import 'enhanced_now_playing_screen.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MusicScannerService>(context, listen: false).scanMusic();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _buildBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniPlayer(),
          ModernBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildSongsTab();
      case 2:
        return _buildAlbumsTab();
      case 3:
        return _buildPlaylistsTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(),
              _buildQuickActions(),
              _buildRecentlyPlayed(),
              _buildFavorites(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Beatryx',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Your Offline Music Player',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<MusicScannerService>(
      builder: (context, scanner, child) {
        final playerService = Provider.of<PlayerService>(context);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.music_note_rounded,
                  title: 'Songs',
                  value: scanner.songs.length.toString(),
                  gradient: [
                    Colors.blue,
                    Colors.purple,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.album_rounded,
                  title: 'Albums',
                  value: scanner.albums.length.toString(),
                  gradient: [
                    Colors.pink,
                    Colors.orange,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite_rounded,
                  title: 'Favorites',
                  value: playerService.favorites.length.toString(),
                  gradient: [
                    Colors.red,
                    Colors.pink,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.shuffle_rounded,
                  label: 'Shuffle All',
                  onTap: () {
                    final scanner = Provider.of<MusicScannerService>(
                      context,
                      listen: false,
                    );
                    final player = Provider.of<PlayerService>(
                      context,
                      listen: false,
                    );
                    if (scanner.songs.isNotEmpty) {
                      player.setPlaylist(scanner.songs, shuffle: true);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Rescan',
                  onTap: () {
                    Provider.of<MusicScannerService>(context, listen: false)
                        .scanMusic();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2);
  }

  Widget _buildRecentlyPlayed() {
    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        if (playerService.recentlyPlayed.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recently Played',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: playerService.recentlyPlayed.length,
                  itemBuilder: (context, index) {
                    final song = playerService.recentlyPlayed[index];
                    return _buildSongCard(song, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavorites() {
    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        final scanner = Provider.of<MusicScannerService>(context);
        final favoriteSongs = scanner.songs
            .where((song) => playerService.favorites.contains(song.id))
            .toList();

        if (favoriteSongs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your Favorites',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favoriteSongs.length,
                  itemBuilder: (context, index) {
                    final song = favoriteSongs[index];
                    return _buildSongCard(song, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongCard(dynamic song, int index) {
    return GestureDetector(
      onTap: () {
        final player = Provider.of<PlayerService>(context, listen: false);
        player.playSong(song);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnhancedNowPlayingScreen(),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: song.imageUrl != null && song.imageUrl!.isNotEmpty
                      ? Image.network(
                          song.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note_rounded,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        )
                      : const Icon(
                          Icons.music_note_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                song.artist,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2),
    );
  }

  Widget _buildSongsTab() {
    return Consumer<MusicScannerService>(
      builder: (context, scanner, child) {
        if (scanner.isScanning) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Scanning for music...'),
              ],
            ),
          );
        }

        if (scanner.songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_off_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No music found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add music to your device to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('All Songs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () {
                    // Show search
                  },
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = scanner.songs[index];
                  return _buildSongListTile(song);
                },
                childCount: scanner.songs.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSongListTile(dynamic song) {
    final playerService = Provider.of<PlayerService>(context);
    final isPlaying = playerService.currentSong?.id == song.id;

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: song.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.music_note_rounded,
                        color: Colors.white);
                  },
                ),
              )
            : const Icon(Icons.music_note_rounded, color: Colors.white),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isPlaying ? FontWeight.bold : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying)
            Icon(
              Icons.equalizer_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              // Show options
            },
          ),
        ],
      ),
      onTap: () {
        playerService.playSong(song);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnhancedNowPlayingScreen(),
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    return const Center(child: Text('Albums - Coming Soon'));
  }

  Widget _buildPlaylistsTab() {
    return const Center(child: Text('Playlists - Coming Soon'));
  }

  Widget _buildSettingsTab() {
    return const Center(child: Text('Settings - Coming Soon'));
  }

  Widget _buildMiniPlayer() {
    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        if (playerService.currentSong == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EnhancedNowPlayingScreen(),
              ),
            );
          },
          child: Container(
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerService.currentSong!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        playerService.currentSong!.artist,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    playerService.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: playerService.playPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                  onPressed: playerService.playNext,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 1, end: 0);
      },
    );
  }
}
