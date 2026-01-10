import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_ui.dart';
import '../services/audio_service.dart';
import '../services/music_provider.dart';

class DarkModernUI implements PlayerUI {
  @override
  Widget buildHome(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A148C), Color(0xFF121212), Color(0xFF121212)],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, Rayhan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border,
                              color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildCategoryChip('All', true),
                    _buildCategoryChip('New Release', false),
                    _buildCategoryChip('Trending', false),
                    _buildCategoryChip('Top', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Curated & trending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discover weekly',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The original slow instrumental beats playlist.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Consumer2<AudioPlayerService, MusicProvider>(
                                builder:
                                    (context, audioService, musicProvider, _) {
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
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.play_arrow,
                                          color: Color(0xFF9C27B0)),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.favorite_border,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              const Icon(Icons.more_horiz,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.white24,
                        child: const Icon(Icons.album,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top daily playlists',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildSongsList(context)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(Icons.home_filled, 'Home', true),
                _buildBottomNavItem(
                    Icons.favorite_border_rounded, 'Liked', false),
                _buildBottomNavItem(Icons.play_circle_outline, 'Play', false),
                _buildBottomNavItem(Icons.library_music, 'Library', false),
                _buildBottomNavItem(
                    Icons.person_outline_rounded, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFCDDC39) : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : const Color(0xFF999999),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool active) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFCDDC39).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFFCDDC39) : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFCDDC39) : Colors.white54,
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(BuildContext context) {
    return Consumer<MusicProvider>(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.white12,
                      child:
                          const Icon(Icons.music_note, color: Colors.white38),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<AudioPlayerService>(
                    builder: (context, audioService, _) {
                      return IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        onPressed: () {
                          audioService.playPlaylist(
                            musicProvider.songs,
                            index,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionPrompt(BuildContext context, MusicProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 56, color: Colors.white54),
          const SizedBox(height: 12),
          const Text('Storage permission required',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Allow access to load your music library',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCDDC39),
              foregroundColor: Colors.black,
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
          const Icon(Icons.music_off, size: 56, color: Colors.white54),
          const SizedBox(height: 12),
          const Text('No music found',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap to rescan your storage',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: provider.fetchSongs,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Rescan music',
                style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildNowPlaying(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFD4A574).withValues(alpha: 0.3),
              const Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.expand_more,
                          color: Colors.white, size: 32),
                      onPressed: () {},
                    ),
                    const Text(
                      'Now Playing',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 280,
                    height: 280,
                    color: Colors.white12,
                    child: const Icon(Icons.album,
                        size: 120, color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'Starlit Reverie',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Beautiful, Limardre',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Text(
                      'Whispers in the midnight breeze, Carrying dreams across the seas.',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: const Color(0xFFCDDC39),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: const Color(0xFFCDDC39),
                      ),
                      child: Slider(value: 0.3, onChanged: (v) {}),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0:38',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                          Text('-2:15',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.shuffle, color: Colors.white60),
                          iconSize: 24,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white),
                          iconSize: 36,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCDDC39),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pause,
                              color: Colors.black, size: 32),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon:
                              const Icon(Icons.skip_next, color: Colors.white),
                          iconSize: 36,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.playlist_play,
                              color: Colors.white60),
                          iconSize: 28,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
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
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note,
                color: Color(0xFF3A3A3A), size: 28),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track Title',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Artist Name',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
