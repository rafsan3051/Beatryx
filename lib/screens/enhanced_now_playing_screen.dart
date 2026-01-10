import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/player_service.dart';
import '../widgets/animated_album_art.dart';
import '../widgets/glassmorphic_card.dart';

class EnhancedNowPlayingScreen extends StatefulWidget {
  const EnhancedNowPlayingScreen({super.key});

  @override
  State<EnhancedNowPlayingScreen> createState() =>
      _EnhancedNowPlayingScreenState();
}

class _EnhancedNowPlayingScreenState extends State<EnhancedNowPlayingScreen>
    with TickerProviderStateMixin {
  bool _showLyrics = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        final currentSong = playerService.currentSong;

        if (currentSong == null) {
          return const Scaffold(
            body: Center(
              child: Text('No song playing'),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => _showOptionsSheet(context, currentSong),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showLyrics
                          ? _buildLyricsView(context)
                          : _buildAlbumArtView(context, currentSong),
                    ),
                  ),
                  _buildSongInfo(context, currentSong),
                  _buildProgressBar(context, playerService),
                  _buildControls(context, playerService),
                  const SizedBox(height: 8),
                  _buildBottomActions(context, playerService),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArtView(BuildContext context, dynamic currentSong) {
    final playerService = Provider.of<PlayerService>(context, listen: false);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'album_art_${currentSong.id}',
            child: AnimatedAlbumArt(
              imageUrl: currentSong.imageUrl,
              size: MediaQuery.of(context).size.width * 0.75,
              isPlaying: playerService.isPlaying,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildLyricsView(BuildContext context) {
    return GlassmorphicCard(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lyrics_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Lyrics not available',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Enable lyrics in settings to view synced lyrics',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, dynamic currentSong) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            currentSong.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            currentSong.artist,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          if (currentSong.album.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              currentSong.album,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, PlayerService playerService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          StreamBuilder<Duration>(
            stream: playerService.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = playerService.duration ?? Duration.zero;

              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: position.inMilliseconds.toDouble(),
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    playerService.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<Duration>(
                  stream: playerService.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Text(
                      _formatDuration(position),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                Text(
                  _formatDuration(playerService.duration ?? Duration.zero),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, PlayerService playerService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            context,
            icon: playerService.isShuffle
                ? Icons.shuffle_on_rounded
                : Icons.shuffle_rounded,
            onPressed: playerService.toggleShuffle,
            isActive: playerService.isShuffle,
          ),
          _buildControlButton(
            context,
            icon: Icons.skip_previous_rounded,
            size: 48,
            onPressed: playerService.playPrevious,
          ),
          _buildPlayPauseButton(context, playerService),
          _buildControlButton(
            context,
            icon: Icons.skip_next_rounded,
            size: 48,
            onPressed: playerService.playNext,
          ),
          _buildControlButton(
            context,
            icon: playerService.repeatMode == RepeatMode.none
                ? Icons.repeat_rounded
                : playerService.repeatMode == RepeatMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_on_rounded,
            onPressed: playerService.toggleRepeat,
            isActive: playerService.repeatMode != RepeatMode.none,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(
      BuildContext context, PlayerService playerService) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          playerService.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          size: 40,
        ),
        color: Colors.white,
        onPressed: playerService.playPause,
      ),
    ).animate(target: playerService.isPlaying ? 1 : 0).scale(
          duration: 200.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
        );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    double size = 32,
    bool isActive = false,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: size,
      color: isActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).textTheme.bodyMedium?.color,
      onPressed: onPressed,
    );
  }

  Widget _buildBottomActions(BuildContext context, PlayerService playerService) {
    final currentSong = playerService.currentSong;
    final isFavorite = playerService.isFavorite(currentSong!.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () => playerService.toggleFavorite(currentSong.id),
          ),
          IconButton(
            icon: Icon(
              _showLyrics ? Icons.album_rounded : Icons.lyrics_outlined,
            ),
            onPressed: () {
              setState(() {
                _showLyrics = !_showLyrics;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            onPressed: () => _showAddToPlaylistSheet(context, currentSong),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareSong(currentSong),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, dynamic song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Song Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showSongDetails(context, song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Sleep Timer'),
                onTap: () {
                  Navigator.pop(context);
                  _showSleepTimer(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.equalizer_rounded),
                title: const Text('Equalizer'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to equalizer screen
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, dynamic song) {
    // Implementation for add to playlist
  }

  void _shareSong(dynamic song) {
    // Implementation for sharing song
  }

  void _showSongDetails(BuildContext context, dynamic song) {
    // Implementation for song details
  }

  void _showSleepTimer(BuildContext context) {
    // Implementation for sleep timer
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
