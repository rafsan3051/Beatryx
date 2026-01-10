import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/player_service.dart';
import '../services/music_scanner_service.dart';
import '../services/theme_service.dart';
import '../widgets/mini_player.dart';
import 'now_playing_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Song> _filteredSongs = [];
  bool _isSearching = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanMusic();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scanMusic() {
    final scannerService = Provider.of<MusicScannerService>(context, listen: false);
    scannerService.scanMusic().then((_) {
      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    if (!mounted) return;
    final scannerService = Provider.of<MusicScannerService>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = scannerService.songs;
      } else {
        _filteredSongs = scannerService.songs
            .where((song) =>
                song.title.toLowerCase().contains(query) ||
                song.artist.toLowerCase().contains(query) ||
                song.album.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _requestPermission() async {
    final scannerService = Provider.of<MusicScannerService>(context, listen: false);
    final hasPermission = await scannerService.requestPermission();
    if (hasPermission) {
      _scanMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayerService, MusicScannerService, ThemeService>(
      builder: (context, playerService, scannerService, themeService, _) {
        final isDark = themeService.isDarkMode;
        final backgroundColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
        
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: backgroundColor,
          drawer: _buildDrawer(context, isDark, themeService.accentColor),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              'Beatryx Music Player',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                    }
                  });
                },
              ),
              // More options button removed - not needed for now
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              if (_isSearching)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: backgroundColor,
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search songs, artists, albums...',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

              // Tab Navigation
              Container(
                color: backgroundColor,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: themeService.accentColor,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                  indicatorColor: themeService.accentColor,
                  tabs: const [
                    Tab(text: 'Home'),
                    Tab(text: 'Songs'),
                    Tab(text: 'Albums'),
                    Tab(text: 'Artists'),
                    Tab(text: 'Tags'),
                    Tab(text: 'Moods'),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHomeTab(context, playerService, scannerService, themeService, isDark),
                    _buildSongsTab(context, playerService, scannerService, isDark),
                    _buildAlbumsTab(context, scannerService, isDark),
                    _buildArtistsTab(context, scannerService, isDark),
                    _buildTagsTab(context, isDark),
                    _buildMoodsTab(context, isDark),
                  ],
                ),
              ),

              // Mini Player
              const MiniPlayer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark, Color accentColor) {
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    return Drawer(
      backgroundColor: bgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.music_note, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Beatryx',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'FREE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(icon: Icons.home, title: 'Home', isDark: isDark, onTap: () => Navigator.pop(context)),
          _DrawerItem(icon: Icons.timer, title: 'Timer', isDark: isDark, onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sleep Timer feature coming soon')),
            );
          }),
          _DrawerItem(icon: Icons.tag, title: 'Tags', isDark: isDark, onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tags feature coming soon')),
            );
          }),
          _DrawerItem(icon: Icons.mood, title: 'Moods', isDark: isDark, onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Moods feature coming soon')),
            );
          }),
          _DrawerItem(icon: Icons.queue_music, title: 'Queue', isDark: isDark, onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Queue management coming soon')),
            );
          }),
          const Divider(),
          _DrawerItem(icon: Icons.settings, title: 'Settings', isDark: isDark, onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          _DrawerItem(icon: Icons.privacy_tip, title: 'Privacy Policy', isDark: isDark, onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Privacy Policy'),
                content: const SingleChildScrollView(
                  child: Text(
                    'Beatryx is an offline music player. Your music files are stored locally on your device. '
                    'We do not collect, store, or transmit any personal data or music information to external servers. '
                    'All playback data remains on your device.'
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }),
          _DrawerItem(icon: Icons.help_outline, title: 'FAQ', isDark: isDark, onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Frequently Asked Questions'),
                content: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Q: Where does Beatryx find my music?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('A: Beatryx scans your device\'s music folders automatically.\n'),
                      Text('Q: Is Beatryx free?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('A: Yes, Beatryx is completely free and open-source.\n'),
                      Text('Q: Does it require internet?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('A: No, Beatryx works completely offline.\n'),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }),
          _DrawerItem(icon: Icons.email, title: 'Email Us', isDark: isDark, onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email feature coming soon')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, PlayerService playerService, MusicScannerService scannerService, ThemeService themeService, bool isDark) {
    if (!scannerService.hasPermission && !scannerService.isScanning) {
      return _buildPermissionScreen(context, isDark, themeService.accentColor);
    }
    
    if (scannerService.isScanning) {
      return _buildLoadingScreen(isDark);
    }

    if (scannerService.songs.isEmpty) {
      return _buildEmptyScreen(context, isDark, themeService.accentColor);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: scannerService.songCount.toString(),
                    label: 'SONGS',
                    color: themeService.accentColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: scannerService.albumCount.toString(),
                    label: 'ALBUMS',
                    color: themeService.accentColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: scannerService.artistCount.toString(),
                    label: 'ARTISTS',
                    color: themeService.accentColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Last Added Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last Added',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.arrow_forward, color: isDark ? Colors.white54 : Colors.black54),
            ],
          ),
          const SizedBox(height: 16),
          
          // Last Added Songs List
          ...scannerService.songs.take(5).map((song) {
            final isPlaying = playerService.currentSong?.id == song.id && playerService.isPlaying;
            return _SongListItem(
              song: song,
              isPlaying: isPlaying,
              isDark: isDark,
              accentColor: themeService.accentColor,
              onTap: () {
                playerService.playSong(song, playlist: scannerService.songs, index: scannerService.songs.indexOf(song));
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSongsTab(BuildContext context, PlayerService playerService, MusicScannerService scannerService, bool isDark) {
    if (scannerService.songs.isEmpty) {
      return _buildEmptyScreen(context, isDark, null);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSongs.isEmpty ? scannerService.songs.length : _filteredSongs.length,
      itemBuilder: (context, index) {
        final songs = _filteredSongs.isEmpty ? scannerService.songs : _filteredSongs;
        final song = songs[index];
        final isPlaying = playerService.currentSong?.id == song.id && playerService.isPlaying;
        return _SongListItem(
          song: song,
          isPlaying: isPlaying,
          isDark: isDark,
          accentColor: Theme.of(context).primaryColor,
          onTap: () {
            playerService.playSong(song, playlist: songs, index: index);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab(BuildContext context, MusicScannerService scannerService, bool isDark) {
    final albums = <String, List<Song>>{};
    for (var song in scannerService.songs) {
      albums.putIfAbsent(song.album, () => []).add(song);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums.keys.elementAt(index);
        final songs = albums[album]!;
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.album),
          ),
          title: Text(album, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
          subtitle: Text('${songs.length} songs', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38),
        );
      },
    );
  }

  Widget _buildArtistsTab(BuildContext context, MusicScannerService scannerService, bool isDark) {
    final artists = <String, List<Song>>{};
    for (var song in scannerService.songs) {
      artists.putIfAbsent(song.artist, () => []).add(song);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists.keys.elementAt(index);
        final songs = artists[artist]!;
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.person),
          ),
          title: Text(artist, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
          subtitle: Text('${songs.length} songs', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38),
        );
      },
    );
  }

  Widget _buildTagsTab(BuildContext context, bool isDark) {
    return Center(
      child: Text(
        'Tags feature coming soon',
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      ),
    );
  }

  Widget _buildMoodsTab(BuildContext context, bool isDark) {
    return Center(
      child: Text(
        'Moods feature coming soon',
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      ),
    );
  }

  Widget _buildPermissionScreen(BuildContext context, bool isDark, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 80, color: accentColor),
            const SizedBox(height: 24),
            Text(
              'Welcome to Beatryx',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Grant storage permission to scan and play your music files',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          const SizedBox(height: 24),
          Text(
            'Scanning your music...',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen(BuildContext context, bool isDark, Color? accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 80, color: isDark ? Colors.white38 : Colors.black38),
            const SizedBox(height: 24),
            Text(
              'No music found',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Make sure you have music files on your device',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _scanMusic,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor ?? Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SongListItem extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onTap;

  const _SongListItem({
    required this.song,
    required this.isPlaying,
    required this.isDark,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? accentColor : (isDark ? Colors.white : Colors.black87),
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      ),
      trailing: Text(
        song.duration,
        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      ),
      onTap: onTap,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      onTap: onTap,
    );
  }
}

