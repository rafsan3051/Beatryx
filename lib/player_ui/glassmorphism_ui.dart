import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'player_ui.dart';
import '../services/audio_service.dart';
import '../services/music_provider.dart';

class GlassmorphismUI implements PlayerUI {
  @override
  Widget buildHome(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF9C27B0),
                  Color(0xFF7B1FA2),
                  Color(0xFF512DA8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top rounded corners decoration
                Container(
                  height: 30,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [
                        Color(0xFF9C27B0),
                        Color(0xFF7B1FA2),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Rayhan !',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Good Afternoon',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.3),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rayhan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Music Lover',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Consumer2<AudioPlayerService, MusicProvider>(
                                    builder: (context, audioService,
                                        musicProvider, _) {
                                      return GestureDetector(
                                        onTap: musicProvider.songs.isNotEmpty
                                            ? () {
                                                audioService.playPlaylist(
                                                  musicProvider.songs,
                                                  0,
                                                );
                                              }
                                            : null,
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Play Now',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.play_circle_filled,
                                                color: Colors.white, size: 20),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Made For You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildGlassCard('Liked\nSongs', Icons.favorite),
                      _buildGlassCard('Top\nHits', Icons.trending_up),
                      _buildGlassCard('Daily\nMix', Icons.playlist_play),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Recently Played',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildArtistCircle('Joly Hunter'),
                      _buildArtistCircle('Joly Jam'),
                      _buildArtistCircle('Squid Jelly'),
                      _buildArtistCircle('Joly Lodger'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildSongsList(context)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(Icons.home, true),
                  _buildNavIcon(Icons.favorite_border, false),
                  _buildNavIcon(Icons.play_circle_filled, false),
                  _buildNavIcon(Icons.library_music, false),
                  _buildNavIcon(Icons.person_outline, false),
                ],
              ),
            ),
          ),
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
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.music_note,
                              color: Colors.white, size: 24),
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
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer<AudioPlayerService>(
                          builder: (context, audioService, _) {
                            return IconButton(
                              icon: const Icon(Icons.play_circle_filled,
                                  color: Colors.white, size: 32),
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
                  ),
                ),
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
          const Icon(Icons.folder_open, size: 56, color: Colors.white70),
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
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7B1FA2),
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
          const Icon(Icons.music_off, size: 56, color: Colors.white70),
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

  Widget _buildGlassCard(String title, IconData icon) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtistCircle(String name) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool selected) {
    return Icon(
      icon,
      color: selected ? Colors.white : Colors.white70,
      size: 28,
    );
  }

  @override
  Widget buildNowPlaying(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child:
                            Icon(Icons.album, size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        'Purple Dreams',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rayhan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
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
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(value: 0.5, onChanged: (v) {}),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('04:20',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text('08:46',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.white),
                            iconSize: 36,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 24),
                          ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(Icons.pause,
                                    color: Colors.white, size: 36),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white),
                            iconSize: 36,
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
        ],
      ),
    );
  }

  @override
  Widget buildMiniPlayer(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.album, color: Colors.white, size: 28),
                  ),
                ),
              ),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Now Playing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rayhan',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
