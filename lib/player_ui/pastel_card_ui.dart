import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_ui.dart';
import '../services/audio_service.dart';
import '../services/music_provider.dart';

class PastelCardUI implements PlayerUI {
  @override
  Widget buildHome(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8B4A4), Color(0xFFD4A574)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              height: 420,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Rayhan',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Music',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  Consumer2<AudioPlayerService, MusicProvider>(
                    builder: (context, audioService, musicProvider, _) {
                      return GestureDetector(
                        onTap: musicProvider.songs.isNotEmpty
                            ? () {
                                audioService.playPlaylist(
                                  musicProvider.songs,
                                  0,
                                );
                              }
                            : null,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5A3C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white, size: 34),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Most popular',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'All',
                      style: TextStyle(
                        color: Color(0xFFE8B4A4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<MusicProvider>(
                builder: (context, musicProvider, _) {
                  if (!musicProvider.permissionGranted) {
                    return _buildPermissionPrompt(context, musicProvider);
                  }
                  if (musicProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (musicProvider.songs.isEmpty) {
                    return _buildEmptyState(context, musicProvider);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: musicProvider.songs.length,
                    itemBuilder: (context, index) {
                      final song = musicProvider.songs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF3D3D3D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(song.duration ?? 0),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF999999),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.favorite_border,
                                color: Color(0xFFE8B4A4), size: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer2<AudioPlayerService, MusicProvider>(
        builder: (context, audioService, musicProvider, _) {
          final song = audioService.currentSong ??
              (musicProvider.songs.isNotEmpty
                  ? musicProvider.songs.first
                  : null);

          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song?.title ?? 'No song playing',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        song?.artist ??
                            'Grant storage permission to load music',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: song != null
                      ? () {
                          if (audioService.isPlaying) {
                            audioService.togglePlayPause();
                          } else {
                            audioService.playPlaylist(
                              musicProvider.songs.isNotEmpty
                                  ? musicProvider.songs
                                  : audioService.playlist,
                              audioService.currentIndex >= 0
                                  ? audioService.currentIndex
                                  : 0,
                            );
                          }
                        }
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8B4A4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildNowPlaying(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.expand_more, size: 32),
                    onPressed: () {},
                  ),
                  const Text(
                    'DAMN. COLLECTORS EDITION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: const Center(
                    child:
                        Icon(Icons.album, size: 120, color: Color(0xFF3D3D3D)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HUMBLE.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rayhan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFE8B4A4), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite,
                        color: Color(0xFFE8B4A4), size: 24),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.4,
                      backgroundColor: const Color(0xFFE0E0E0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFE8B4A4)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.shuffle, color: Color(0xFF999999)),
                        iconSize: 24,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_previous,
                            color: Color(0xFF3D3D3D)),
                        iconSize: 36,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8B4A4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pause,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_next,
                            color: Color(0xFF3D3D3D)),
                        iconSize: 36,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon:
                            const Icon(Icons.repeat, color: Color(0xFF999999)),
                        iconSize: 24,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.airplay, color: Color(0xFF999999)),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        icon: const Icon(Icons.queue_music,
                            color: Color(0xFF999999)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildMiniPlayer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 44,
              height: 44,
              color: Colors.grey[300],
              child: const Icon(Icons.music_note, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HUMBLE.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Kendrick Lamar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE8B4A4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pause, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPrompt(BuildContext context, MusicProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 56, color: Color(0xFF999999)),
          const SizedBox(height: 12),
          const Text(
            'Storage permission required',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Allow access to show your music library',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8B4A4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Grant permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MusicProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, size: 56, color: Color(0xFF999999)),
          const SizedBox(height: 12),
          const Text(
            'No music found',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to rescan your storage',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: provider.fetchSongs,
            icon: const Icon(Icons.refresh),
            label: const Text('Rescan music'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int millis) {
    final totalSeconds = millis ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
