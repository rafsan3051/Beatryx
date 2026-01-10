import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';
import '../services/palette_service.dart';
import '../services/theme_manager.dart';
import '../services/playlist_service.dart';

class ThemedPlayerScreen extends StatefulWidget {
  final List<SongModel> songs;
  final int initialIndex;

  const ThemedPlayerScreen({super.key, required this.songs, required this.initialIndex});

  @override
  State<ThemedPlayerScreen> createState() => _ThemedPlayerScreenState();
}

class _ThemedPlayerScreenState extends State<ThemedPlayerScreen> with SingleTickerProviderStateMixin {
  Timer? _sleepTimer;
  late PageController _artworkPageController;
  late AnimationController _playPauseController;

  @override
  void initState() {
    super.initState();
    _artworkPageController = PageController(initialPage: widget.initialIndex);
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final audioService = Provider.of<AudioPlayerService>(context, listen: false);
      final paletteService = Provider.of<PaletteService>(context, listen: false);
      
      if (audioService.currentSong?.id != widget.songs[widget.initialIndex].id) {
        audioService.playPlaylist(widget.songs, widget.initialIndex);
      }
      paletteService.updatePalette(widget.songs[widget.initialIndex].id);
      
      if (audioService.isPlaying) {
        _playPauseController.forward();
      }
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _artworkPageController.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  void _showCustomSleepTimer() {
    double sleepMinutes = 30;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text('Set Sleep Timer', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${sleepMinutes.toInt()} Minutes', style: const TextStyle(color: Color(0xFF00C2A0), fontSize: 24, fontWeight: FontWeight.bold)),
              Slider(
                value: sleepMinutes,
                min: 1,
                max: 120,
                activeColor: const Color(0xFF00C2A0),
                onChanged: (v) => setDialogState(() => sleepMinutes = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: () {
                _setSleepTimer(Duration(minutes: sleepMinutes.toInt()));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C2A0)),
              child: const Text('Set', style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  void _setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(duration, () {
      Provider.of<AudioPlayerService>(context, listen: false).stop();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Music will stop in ${duration.inMinutes} minutes')));
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context);
    final palette = Provider.of<PaletteService>(context);
    final theme = Provider.of<ThemeManager>(context);
    final playlistService = Provider.of<PlaylistService>(context);
    
    final currentPlaylist = audioService.playlist.isNotEmpty ? audioService.playlist : widget.songs;
    final currentSong = audioService.currentSong ?? (widget.songs.isNotEmpty ? widget.songs[widget.initialIndex] : null);
    
    if (currentSong == null) return const Scaffold(body: Center(child: Text('No song playing')));
    
    if (audioService.isPlaying) {
      _playPauseController.forward();
    } else {
      _playPauseController.reverse();
    }

    if (_artworkPageController.hasClients) {
      final int songIndexInPlaylist = currentPlaylist.indexWhere((s) => s.id == currentSong.id);
      if (songIndexInPlaylist != -1 && _artworkPageController.page?.round() != songIndexInPlaylist) {
        _artworkPageController.animateToPage(songIndexInPlaylist, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }

    final isFavorite = playlistService.isFavorite(currentSong.id.toString());

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Slide down to go back (to miniplayer)
          if (details.primaryDelta! > 10) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.dominantColor.withValues(alpha: 0.3),
                    theme.backgroundColor,
                  ],
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 38, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text('Music Player', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                        IconButton(icon: const Icon(Icons.timer_outlined, color: Colors.white), onPressed: _showCustomSleepTimer),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _artworkPageController,
                      itemCount: currentPlaylist.length,
                      onPageChanged: (index) {
                        audioService.playPlaylist(currentPlaylist, index);
                        palette.updatePalette(currentPlaylist[index].id);
                      },
                      itemBuilder: (context, index) {
                        final song = currentPlaylist[index];
                        return Center(
                          child: AnimatedScale(
                            scale: song.id == currentSong.id ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 400),
                            child: Hero(
                              tag: 'player_${song.id}',
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: palette.dominantColor.withValues(alpha: 0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: QueryArtworkWidget(
                                    id: song.id,
                                    type: ArtworkType.AUDIO,
                                    artworkWidth: double.infinity,
                                    artworkHeight: double.infinity,
                                    artworkFit: BoxFit.cover,
                                    nullArtworkWidget: Container(
                                      color: Colors.white10,
                                      child: const Icon(Icons.music_note_rounded, size: 100, color: Colors.white12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(currentSong.title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(currentSong.artist ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white54)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? Colors.redAccent : Colors.white, size: 28),
                                onPressed: () => playlistService.toggleFavorite(currentSong.id.toString()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          StreamBuilder<Duration>(
                            stream: audioService.audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final total = audioService.audioPlayer.duration ?? Duration.zero;
                              return Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3, 
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      activeTrackColor: const Color(0xFF00C2A0),
                                      inactiveTrackColor: Colors.white12,
                                      thumbColor: Colors.white,
                                    ),
                                    child: Slider(
                                      value: position.inMilliseconds.toDouble().clamp(0, total.inMilliseconds.toDouble() > 0 ? total.inMilliseconds.toDouble() : 1.0),
                                      max: total.inMilliseconds.toDouble() > 0 ? total.inMilliseconds.toDouble() : 1.0,
                                      onChanged: (v) => audioService.audioPlayer.seek(Duration(milliseconds: v.toInt())),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatDuration(position), style: const TextStyle(color: Colors.white30, fontSize: 11)),
                                        Text(_formatDuration(total), style: const TextStyle(color: Colors.white30, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildControlIcon(Icons.shuffle_rounded, audioService.isShuffleMode ? const Color(0xFF00C2A0) : Colors.white30, audioService.toggleShuffle),
                              _buildControlIcon(Icons.skip_previous_rounded, Colors.white, audioService.playPrevious, size: 40),
                              
                              GestureDetector(
                                onTap: audioService.togglePlayPause,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: AnimatedIcon(
                                    icon: AnimatedIcons.play_pause,
                                    progress: _playPauseController,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                ),
                              ),
                              
                              _buildControlIcon(Icons.skip_next_rounded, Colors.white, audioService.playNext, size: 40),
                              _buildControlIcon(
                                audioService.repeatMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                                audioService.repeatMode != LoopMode.off ? const Color(0xFF00C2A0) : Colors.white30,
                                audioService.nextRepeatMode
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.8,
              snap: true,
              snapSizes: const [0.1, 0.8],
              builder: (context, scrollController) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                          ),
                          Text('Up Next', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final song = currentPlaylist[i];
                            final isPlaying = song.id == currentSong.id;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: QueryArtworkWidget(
                                  id: song.id,
                                  type: ArtworkType.AUDIO,
                                  artworkWidth: 45,
                                  artworkHeight: 45,
                                  nullArtworkWidget: const Icon(Icons.music_note_rounded, color: Colors.white24),
                                ),
                              ),
                              title: Text(
                                song.title, 
                                style: TextStyle(
                                  color: isPlaying ? const Color(0xFF00C2A0) : Colors.white, 
                                  fontSize: 14, 
                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500
                                ), 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis
                              ),
                              subtitle: Text(
                                song.artist ?? 'Unknown', 
                                style: TextStyle(color: isPlaying ? const Color(0xFF00C2A0).withValues(alpha: 0.7) : Colors.white38, fontSize: 12), 
                                maxLines: 1
                              ),
                              onTap: () {
                                audioService.playPlaylist(currentPlaylist, i);
                                palette.updatePalette(song.id);
                              },
                            );
                          },
                          childCount: currentPlaylist.length,
                        ),
                      ),
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

  Widget _buildControlIcon(IconData icon, Color color, VoidCallback onTap, {double size = 24}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
