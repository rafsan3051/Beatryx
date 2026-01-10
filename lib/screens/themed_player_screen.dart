import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioService = Provider.of<AudioPlayerService>(context, listen: false);
      final paletteService = Provider.of<PaletteService>(context, listen: false);
      
      if (audioService.currentSong?.id != widget.songs[widget.initialIndex].id) {
        audioService.playPlaylist(widget.songs, widget.initialIndex);
      }
      paletteService.updatePalette(widget.songs[widget.initialIndex].id);
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
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
    final currentSong = audioService.currentSong ?? widget.songs[widget.initialIndex];
    final isFavorite = playlistService.isFavorite(currentSong.id.toString());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glassmorphism Background with dynamic color tint
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              color: palette.dominantColor.withValues(alpha: 0.1),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.dominantColor.withValues(alpha: 0.2),
                      theme.backgroundColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! > 10) Navigator.pop(context); 
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  audioService.playPrevious();
                } else if (details.primaryVelocity! < 0) {
                  audioService.playNext();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Header
                    Row(
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
                    const SizedBox(height: 20),
                    // Artwork
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: palette.dominantColor.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: QueryArtworkWidget(
                            id: currentSong.id,
                            type: ArtworkType.AUDIO,
                            artworkWidth: MediaQuery.of(context).size.width * 0.85,
                            artworkHeight: MediaQuery.of(context).size.width * 0.85,
                            nullArtworkWidget: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.width * 0.85,
                              color: Colors.white10,
                              child: const Icon(Icons.music_note_rounded, size: 120, color: Colors.white12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Info
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentSong.title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(currentSong.artist ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white54)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? Colors.redAccent : Colors.white, size: 30),
                          onPressed: () => playlistService.toggleFavorite(currentSong.id.toString()),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Progress
                    StreamBuilder<Duration>(
                      stream: audioService.audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final total = audioService.audioPlayer.duration ?? Duration.zero;
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2, 
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                activeTrackColor: Colors.white,
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
                    // Controls
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80), // Increased to avoid queue overlap
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.shuffle_rounded, color: Colors.white30),
                          IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 44, color: Colors.white), onPressed: audioService.playPrevious),
                          GestureDetector(
                            onTap: audioService.togglePlayPause,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(audioService.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 44),
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.skip_next_rounded, size: 44, color: Colors.white), onPressed: audioService.playNext),
                          const Icon(Icons.repeat_rounded, color: Colors.white30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Slide Up Queue with integrated Glassmorphism
          DraggableScrollableSheet(
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.6,
            builder: (context, controller) => ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: ListView.builder(
                    controller: controller,
                    itemCount: widget.songs.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: QueryArtworkWidget(
                          id: widget.songs[i].id,
                          type: ArtworkType.AUDIO,
                          artworkWidth: 40,
                          artworkHeight: 40,
                          nullArtworkWidget: const Icon(Icons.music_note_rounded, color: Colors.white24),
                        ),
                      ),
                      title: Text(widget.songs[i].title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(widget.songs[i].artist ?? 'Unknown', style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1),
                      onTap: () {
                        audioService.playPlaylist(widget.songs, i);
                        palette.updatePalette(widget.songs[i].id);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
