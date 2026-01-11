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
import '../services/ui_manager.dart';

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
  final DraggableScrollableController _sheetController = DraggableScrollableController();

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

  void _showOptionsDialog() {
    final audioService = Provider.of<AudioPlayerService>(context, listen: false);
    final isAura = Provider.of<UIManager>(context, listen: false).currentUI.isAura;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isAura ? Colors.white : const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Consumer<AudioPlayerService>(
        builder: (context, audio, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isAura ? Colors.black12 : Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.timer_outlined, color: isAura ? Colors.black87 : Colors.white),
              title: Text('Sleep Timer', style: TextStyle(color: isAura ? Colors.black87 : Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showCustomSleepTimer();
              },
            ),
            ListTile(
              leading: Icon(
                audio.repeatMode == LoopMode.off ? Icons.repeat_rounded : (audio.repeatMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_on_rounded),
                color: audio.repeatMode != LoopMode.off ? (isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0)) : (isAura ? Colors.black87 : Colors.white),
              ),
              title: Text('Repeat Mode', style: TextStyle(color: isAura ? Colors.black87 : Colors.white)),
              trailing: Text(
                audio.repeatMode == LoopMode.off ? 'Off' : (audio.repeatMode == LoopMode.one ? 'One' : 'All'),
                style: TextStyle(color: isAura ? Colors.black45 : Colors.white54),
              ),
              onTap: audio.nextRepeatMode,
            ),
            ListTile(
              leading: Icon(
                Icons.shuffle_rounded,
                color: audio.isShuffleMode ? (isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0)) : (isAura ? Colors.black87 : Colors.white),
              ),
              title: Text('Shuffle', style: TextStyle(color: isAura ? Colors.black87 : Colors.white)),
              trailing: Switch(
                value: audio.isShuffleMode,
                activeThumbColor: isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0),
                onChanged: (_) => audio.toggleShuffle(),
              ),
              onTap: audio.toggleShuffle,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showCustomSleepTimer() {
    double sleepMinutes = 30;
    final isAura = Provider.of<UIManager>(context, listen: false).currentUI.isAura;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isAura ? Colors.white : const Color(0xFF1E1E1E).withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text('Set Sleep Timer', style: GoogleFonts.poppins(color: isAura ? Colors.black87 : Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${sleepMinutes.toInt()} Minutes', style: TextStyle(color: isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0), fontSize: 24, fontWeight: FontWeight.bold)),
              Slider(
                value: sleepMinutes,
                min: 1,
                max: 120,
                activeColor: isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0),
                onChanged: (v) => setDialogState(() => sleepMinutes = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: isAura ? Colors.black45 : Colors.white70))),
            ElevatedButton(
              onPressed: () {
                _setSleepTimer(Duration(minutes: sleepMinutes.toInt()));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0)),
              child: const Text('Set', style: TextStyle(color: Colors.white)),
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
    final uiManager = Provider.of<UIManager>(context);
    final isAura = uiManager.currentUI.isAura;
    
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

    return Scaffold(
      backgroundColor: isAura ? Colors.white : theme.backgroundColor,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            audioService.setShowMiniPlayer(true);
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            // Background Elements
            if (isAura) ...[
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFC0CB).withOpacity(0.3)),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE6E6FA).withOpacity(0.4)),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),
            ] else
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [palette.dominantColor.withOpacity(0.3), theme.backgroundColor],
                  ),
                ),
              ),
            
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            isAura ? Icons.keyboard_arrow_down_rounded : Icons.arrow_back_ios_new_rounded, 
                            size: 30, 
                            color: isAura ? Colors.black87 : Colors.white
                          ),
                          onPressed: () {
                            audioService.setShowMiniPlayer(true);
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          isAura ? 'Playing Now' : 'Music Player', 
                          style: GoogleFonts.poppins(
                            fontSize: 18, 
                            fontWeight: FontWeight.w600, 
                            color: isAura ? Colors.black87 : Colors.white
                          ),
                        ),
                        IconButton(
                          icon: Icon(isAura ? Icons.grid_view_rounded : Icons.timer_outlined, color: isAura ? Colors.black87 : Colors.white), 
                          onPressed: _showOptionsDialog,
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Circular Artwork
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.9,
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
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.75,
                                    height: MediaQuery.of(context).size.width * 0.75,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isAura ? Colors.black.withOpacity(0.08) : palette.dominantColor.withOpacity(0.2),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        )
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Container(
                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                      clipBehavior: Clip.antiAlias,
                                      child: QueryArtworkWidget(
                                        id: song.id,
                                        type: ArtworkType.AUDIO,
                                        artworkWidth: double.infinity,
                                        artworkHeight: double.infinity,
                                        artworkFit: BoxFit.cover,
                                        nullArtworkWidget: Container(
                                          color: const Color(0xFFF5F5F5),
                                          child: Icon(Icons.music_note_rounded, size: 80, color: Colors.black12),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
  
                          const SizedBox(height: 30),
                          // Song Info
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              children: [
                                Text(
                                  currentSong.title, 
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold, 
                                    color: isAura ? Colors.black87 : Colors.white
                                  ), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentSong.artist ?? 'Unknown', 
                                  style: GoogleFonts.poppins(
                                    fontSize: 16, 
                                    color: isAura ? Colors.black45 : Colors.white54
                                  )
                                ),
                              ],
                            ),
                          ),
  
                          const SizedBox(height: 25),
                          
                          // Controls & Seek bar section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              children: [
                                // Seek Bar
                                StreamBuilder<Duration>(
                                  stream: audioService.audioPlayer.positionStream,
                                  builder: (context, snapshot) {
                                    final position = snapshot.data ?? Duration.zero;
                                    final total = audioService.audioPlayer.duration ?? Duration.zero;
                                    return Column(
                                      children: [
                                        SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackHeight: 4, 
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                            activeTrackColor: isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0),
                                            inactiveTrackColor: isAura ? Colors.black.withOpacity(0.05) : Colors.white12,
                                            thumbColor: isAura ? const Color(0xFFD81B60) : Colors.white,
                                            overlayColor: (isAura ? const Color(0xFFD81B60) : const Color(0xFF00C2A0)).withOpacity(0.2),
                                          ),
                                          child: Slider(
                                            value: position.inMilliseconds.toDouble().clamp(0, total.inMilliseconds.toDouble() > 0 ? total.inMilliseconds.toDouble() : 1.0),
                                            max: total.inMilliseconds.toDouble() > 0 ? total.inMilliseconds.toDouble() : 1.0,
                                            onChanged: (v) => audioService.audioPlayer.seek(Duration(milliseconds: v.toInt())),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_formatDuration(position), style: TextStyle(color: isAura ? Colors.black26 : Colors.white30, fontSize: 12, fontWeight: FontWeight.w500)),
                                              Text(_formatDuration(total), style: TextStyle(color: isAura ? Colors.black26 : Colors.white30, fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                ),
                                const SizedBox(height: 25),
                                // Controls
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.skip_previous_rounded, color: isAura ? const Color(0xFFD81B60) : Colors.white, size: 40),
                                      onPressed: audioService.playPrevious,
                                    ),
                                    
                                    GestureDetector(
                                      onTap: audioService.togglePlayPause,
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          gradient: isAura ? const LinearGradient(
                                            colors: [Color(0xFF6C63FF), Color(0xFFD81B60)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ) : null,
                                          color: isAura ? null : Colors.white, 
                                          shape: BoxShape.circle,
                                          boxShadow: isAura ? [
                                            BoxShadow(color: const Color(0xFFD81B60).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                                          ] : null,
                                        ),
                                        child: AnimatedIcon(
                                          icon: AnimatedIcons.play_pause,
                                          progress: _playPauseController,
                                          color: isAura ? Colors.white : Colors.black,
                                          size: 45,
                                        ),
                                      ),
                                    ),
                                    
                                    IconButton(
                                      icon: Icon(Icons.skip_next_rounded, color: isAura ? const Color(0xFFD81B60) : Colors.white, size: 40),
                                      onPressed: audioService.playNext,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                if (isAura)
                                  GestureDetector(
                                    onVerticalDragUpdate: (details) {
                                      if (details.primaryDelta! < -5) {
                                        _sheetController.animateTo(0.8, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                      }
                                    },
                                    onTap: () => _sheetController.animateTo(0.8, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.black26),
                                        Text('Next', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
  
            // Draggable Playqueue
            if (isAura)
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.0,
                minChildSize: 0.0,
                maxChildSize: 0.85,
                snap: true,
                builder: (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Up Next', 
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: currentPlaylist.length,
                          itemBuilder: (context, i) {
                            final song = currentPlaylist[i];
                            final isPlaying = song.id == currentSong.id;
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: QueryArtworkWidget(
                                  id: song.id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Container(
                                    width: 45,
                                    height: 45,
                                    color: Colors.black.withOpacity(0.05),
                                    child: const Icon(Icons.music_note, color: Colors.black12),
                                  ),
                                ),
                              ),
                              title: Text(
                                song.title, 
                                style: TextStyle(
                                  color: isPlaying ? const Color(0xFFD81B60) : Colors.black87, 
                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(song.artist ?? 'Unknown', style: const TextStyle(color: Colors.black45, fontSize: 12)),
                              onTap: () {
                                audioService.playPlaylist(currentPlaylist, i);
                                palette.updatePalette(song.id);
                              },
                            );
                          },
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
