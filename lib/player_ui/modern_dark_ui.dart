import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_ui.dart';
import '../services/audio_service.dart';
import '../services/music_provider.dart';

class ModernDarkUI implements PlayerUI {
  @override
  Widget buildHome(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
              Color(0xFF0F0F0F),
            ],
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, Rayhan 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search_outlined,
                              color: Colors.white70),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white70),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildPill('All', true),
                    _buildPill('Trending', false),
                    _buildPill('Chill', false),
                    _buildPill('Workout', false),
                    _buildPill('Focus', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recently Listened',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
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
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavIcon(Icons.home_filled, true),
                _buildBottomNavIcon(Icons.favorite_border_rounded, false),
                _buildBottomNavIcon(Icons.search_rounded, false),
                _buildBottomNavIcon(Icons.library_music_rounded, false),
                _buildBottomNavIcon(Icons.person_outline_rounded, false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF00BCD4) : const Color(0xFF2A2A2A),
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

  Widget _buildBottomNavIcon(IconData icon, bool selected) {
    return Icon(
      icon,
      color: selected ? const Color(0xFF00BCD4) : const Color(0xFF555555),
      size: 26,
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
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00BCD4).withValues(alpha: 0.8),
                          const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.music_note,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<AudioPlayerService>(
                    builder: (context, audioService, _) {
                      return IconButton(
                        icon: const Icon(Icons.play_circle_fill,
                            color: Color(0xFF00BCD4), size: 32),
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
          const Icon(Icons.folder_open, size: 56, color: Color(0xFF777777)),
          const SizedBox(height: 12),
          const Text('Storage permission required',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Allow access to load your music library',
              style: TextStyle(color: Color(0xFF777777)),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
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
          const Icon(Icons.music_off, size: 56, color: Color(0xFF777777)),
          const SizedBox(height: 12),
          const Text('No music found',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap to rescan your storage',
              style: TextStyle(color: Color(0xFF777777))),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: provider.fetchSongs,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Rescan music',
                style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF777777)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildNowPlaying(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00BCD4).withValues(alpha: 0.15),
              const Color(0xFF0F0F0F),
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
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 32),
                      onPressed: () {},
                    ),
                    const Text(
                      'Now Playing',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 300,
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.album, size: 120, color: Colors.white24),
                ),
              ),
              const SizedBox(height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'Summer Vibes Mix',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rayhan',
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
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: const Color(0xFF00BCD4),
                        inactiveTrackColor: const Color(0xFF333333),
                        thumbColor: const Color(0xFF00BCD4),
                      ),
                      child: Slider(value: 0.45, onChanged: (v) {}),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('2:15',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                          Text('-2:30',
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
                          icon: const Icon(Icons.shuffle_rounded,
                              color: Colors.white60),
                          iconSize: 24,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded,
                              color: Colors.white),
                          iconSize: 40,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF00BCD4), Color(0xFFFF6B6B)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pause_rounded,
                              color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded,
                              color: Colors.white),
                          iconSize: 40,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.repeat_rounded,
                              color: Colors.white60),
                          iconSize: 24,
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
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFFFF6B6B)],
              ),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 28),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summer Vibes Mix',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Rayhan',
                  style: TextStyle(color: Color(0xFF777777), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow,
                color: Color(0xFF00BCD4), size: 32),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white60, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
