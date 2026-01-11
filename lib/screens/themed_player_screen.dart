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
import '../services/ui_manager.dart';

class ThemedPlayerScreen extends StatefulWidget {
  final List<SongModel> songs;
  final int initialIndex;

  const ThemedPlayerScreen(
      {super.key, required this.songs, required this.initialIndex});

  @override
  State<ThemedPlayerScreen> createState() => _ThemedPlayerScreenState();
}

class _ThemedPlayerScreenState extends State<ThemedPlayerScreen>
    with SingleTickerProviderStateMixin {
  Timer? _sleepTimer;
  late PageController _artworkPageController;
  late AnimationController _playPauseController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

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
      final audioService =
          Provider.of<AudioPlayerService>(context, listen: false);
      final paletteService =
          Provider.of<PaletteService>(context, listen: false);

      if (audioService.currentSong?.id !=
          widget.songs[widget.initialIndex].id) {
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
    final theme = Provider.of<ThemeManager>(context, listen: false);
    final uiManager = Provider.of<UIManager>(context, listen: false);
    final isAura = uiManager.currentUI.isAura;
    final isDark = theme.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF1E1E1E)
          : (isAura ? Colors.white : theme.backgroundColor),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Consumer<AudioPlayerService>(
        builder: (context, audio, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.black12,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.timer_outlined,
                  color: isDark ? Colors.white70 : Colors.black87),
              title: Text('Sleep Timer',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                _showCustomSleepTimer();
              },
            ),
            ListTile(
              leading: Icon(
                audio.repeatMode == LoopMode.off
                    ? Icons.repeat_rounded
                    : (audio.repeatMode == LoopMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_on_rounded),
                color: audio.repeatMode != LoopMode.off
                    ? theme.accentColor
                    : (isDark ? Colors.white38 : Colors.black26),
              ),
              title: Text('Repeat Mode',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87)),
              trailing: Text(
                audio.repeatMode == LoopMode.off
                    ? 'Off'
                    : (audio.repeatMode == LoopMode.one ? 'One' : 'All'),
                style:
                    TextStyle(color: isDark ? Colors.white38 : Colors.black45),
              ),
              onTap: audio.nextRepeatMode,
            ),
            ListTile(
              leading: Icon(
                Icons.shuffle_rounded,
                color: audio.isShuffleMode
                    ? theme.accentColor
                    : (isDark ? Colors.white38 : Colors.black26),
              ),
              title: Text('Shuffle',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87)),
              trailing: Switch(
                value: audio.isShuffleMode,
                activeThumbImage: null,
                thumbColor: WidgetStateProperty.all(theme.accentColor),
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
    final theme = Provider.of<ThemeManager>(context, listen: false);
    final isDark = theme.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text('Set Sleep Timer',
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black87, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${sleepMinutes.toInt()} Minutes',
                  style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Slider(
                value: sleepMinutes,
                min: 1,
                max: 120,
                activeColor: theme.accentColor,
                onChanged: (v) => setDialogState(() => sleepMinutes = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black45))),
            ElevatedButton(
              onPressed: () {
                _setSleepTimer(Duration(minutes: sleepMinutes.toInt()));
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
              child: Text('Set',
                  style:
                      TextStyle(color: isDark ? Colors.black : Colors.white)),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Music will stop in ${duration.inMinutes} minutes')));
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context);
    final palette = Provider.of<PaletteService>(context);
    final theme = Provider.of<ThemeManager>(context);
    final uiManager = Provider.of<UIManager>(context);
    final isAura = uiManager.currentUI.isAura;
    final isDark = theme.isDarkMode;

    final currentPlaylist =
        audioService.playlist.isNotEmpty ? audioService.playlist : widget.songs;
    final currentSong = audioService.currentSong ??
        (widget.songs.isNotEmpty ? widget.songs[widget.initialIndex] : null);

    if (currentSong == null) {
      return const Scaffold(body: Center(child: Text('No song playing')));
    }

    if (audioService.isPlaying) {
      _playPauseController.forward();
    } else {
      _playPauseController.reverse();
    }

    if (_artworkPageController.hasClients) {
      final int songIndexInPlaylist =
          currentPlaylist.indexWhere((s) => s.id == currentSong.id);
      if (songIndexInPlaylist != -1 &&
          _artworkPageController.page?.round() != songIndexInPlaylist) {
        _artworkPageController.animateToPage(songIndexInPlaylist,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! > 10) {
                // Drag down to dismiss
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
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? theme.accentColor.withValues(alpha: 0.08)
                              : const Color(0xFFFFC0CB).withValues(alpha: 0.3)),
                    ),
                  ),
                  Positioned(
                    bottom: -150,
                    left: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? theme.accentColor.withValues(alpha: 0.05)
                              : const Color(0xFFE6E6FA).withValues(alpha: 0.4)),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ] else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          palette.dominantColor.withValues(alpha: 0.3),
                          theme.backgroundColor
                        ],
                      ),
                    ),
                  ),

                // Main Player UI
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Header Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 30),
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87),
                                ),
                                IconButton(
                                  icon: Icon(
                                      isAura
                                          ? Icons.grid_view_rounded
                                          : Icons.timer_outlined,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                  onPressed: isAura
                                      ? _showOptionsDialog
                                      : _showCustomSleepTimer,
                                ),
                              ],
                            ),
                          ),

                          // Artwork Section
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: PageView.builder(
                                controller: _artworkPageController,
                                itemCount: currentPlaylist.length,
                                onPageChanged: (index) {
                                  audioService.playPlaylist(
                                      currentPlaylist, index);
                                  palette.updatePalette(
                                      currentPlaylist[index].id);
                                },
                                itemBuilder: (context, index) {
                                  final song = currentPlaylist[index];
                                  return Center(
                                    child: Container(
                                      width: constraints.maxWidth * 0.72,
                                      height: constraints.maxWidth * 0.72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.05)
                                            : Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black45
                                                : Colors.black.withValues(
                                                    alpha: 0.08),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          )
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: ClipOval(
                                        child: QueryArtworkWidget(
                                          id: song.id,
                                          type: ArtworkType.AUDIO,
                                          artworkWidth: double.infinity,
                                          artworkHeight: double.infinity,
                                          artworkFit: BoxFit.cover,
                                          nullArtworkWidget: Container(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.02)
                                                : const Color(0xFFF5F5F5),
                                            child: Icon(Icons.music_note_rounded,
                                                size: 80,
                                                color: isDark
                                                    ? Colors.white10
                                                    : Colors.black12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Song Info Section
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(currentSong.title,
                                          style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(currentSong.artist ?? 'Unknown',
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.black45)),
                                    ],
                                  ),
                                ),
                                if (!isAura)
                                  Consumer<PlaylistService>(
                                    builder: (context, playlist, _) =>
                                        IconButton(
                                      icon: Icon(
                                        playlist.isFavorite(
                                                currentSong.id.toString())
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: playlist.isFavorite(
                                                currentSong.id.toString())
                                            ? Colors.redAccent
                                            : (isDark
                                                ? Colors.white38
                                                : Colors.black26),
                                        size: 28,
                                      ),
                                      onPressed: () => playlist.toggleFavorite(
                                          currentSong.id.toString()),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Progress & Controls Section
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              children: [
                                StreamBuilder<Duration>(
                                    stream:
                                        audioService.audioPlayer.positionStream,
                                    builder: (context, snapshot) {
                                      final position =
                                          snapshot.data ?? Duration.zero;
                                      final total =
                                          audioService.audioPlayer.duration ??
                                              Duration.zero;
                                      return Column(
                                        children: [
                                          SliderTheme(
                                            data:
                                                SliderTheme.of(context).copyWith(
                                              trackHeight: 4,
                                              thumbShape:
                                                  const RoundSliderThumbShape(
                                                      enabledThumbRadius: 6),
                                              activeTrackColor:
                                                  theme.accentColor,
                                              inactiveTrackColor: isDark
                                                  ? Colors.white10
                                                  : Colors.black.withValues(
                                                      alpha: 0.05),
                                              thumbColor: theme.accentColor,
                                              overlayColor: theme.accentColor
                                                  .withValues(alpha: 0.2),
                                            ),
                                            child: Slider(
                                              value: position.inMilliseconds
                                                  .toDouble()
                                                  .clamp(
                                                      0,
                                                      total.inMilliseconds
                                                                  .toDouble() >
                                                              0
                                                          ? total.inMilliseconds
                                                              .toDouble()
                                                          : 1.0),
                                              max: total.inMilliseconds
                                                          .toDouble() >
                                                      0
                                                  ? total.inMilliseconds
                                                      .toDouble()
                                                  : 1.0,
                                              onChanged: (v) => audioService
                                                  .audioPlayer
                                                  .seek(Duration(
                                                      milliseconds: v.toInt())),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(_formatDuration(position),
                                                    style: TextStyle(
                                                        color: isDark
                                                            ? Colors.white24
                                                            : Colors.black26,
                                                        fontSize: 11)),
                                                Text(_formatDuration(total),
                                                    style: TextStyle(
                                                        color: isDark
                                                            ? Colors.white24
                                                            : Colors.black26,
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                const SizedBox(height: 15),
                                if (!isAura)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                              audioService.isShuffleMode
                                                  ? Icons.shuffle_on_rounded
                                                  : Icons.shuffle_rounded,
                                              color: audioService.isShuffleMode
                                                  ? theme.accentColor
                                                  : (isDark
                                                      ? Colors.white38
                                                      : Colors.black26)),
                                          onPressed: audioService.toggleShuffle,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.skip_previous_rounded,
                                              color: theme.accentColor,
                                              size: 35),
                                          onPressed: audioService.playPrevious,
                                        ),
                                        GestureDetector(
                                          onTap: audioService.togglePlayPause,
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                color: theme.accentColor,
                                                shape: BoxShape.circle),
                                            child: Icon(
                                                audioService.isPlaying
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: isDark
                                                    ? Colors.black
                                                    : Colors.white,
                                                size: 40),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.skip_next_rounded,
                                              color: theme.accentColor,
                                              size: 35),
                                          onPressed: audioService.playNext,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            audioService.repeatMode ==
                                                    LoopMode.off
                                                ? Icons.repeat_rounded
                                                : (audioService.repeatMode ==
                                                        LoopMode.one
                                                    ? Icons.repeat_one_rounded
                                                    : Icons.repeat_on_rounded),
                                            color: audioService.repeatMode !=
                                                    LoopMode.off
                                                ? theme.accentColor
                                                : (isDark
                                                    ? Colors.white38
                                                    : Colors.black26),
                                          ),
                                          onPressed: audioService.nextRepeatMode,
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.skip_previous_rounded,
                                            color: theme.accentColor, size: 40),
                                        onPressed: audioService.playPrevious,
                                      ),
                                      GestureDetector(
                                        onTap: audioService.togglePlayPause,
                                        child: Container(
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF6C63FF),
                                                theme.accentColor
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: theme.accentColor
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8))
                                            ],
                                          ),
                                          child: AnimatedIcon(
                                            icon: AnimatedIcons.play_pause,
                                            progress: _playPauseController,
                                            color: Colors.white,
                                            size: 45,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.skip_next_rounded,
                                            color: theme.accentColor, size: 40),
                                        onPressed: audioService.playNext,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // Drag Handle Section Spacer
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),

                // Draggable Playqueue (Integrated interaction)
                DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: 0.08, // Small visible handle area
                  minChildSize: 0.08,
                  maxChildSize: 0.8,
                  snap: true,
                  builder: (context, scrollController) {
                    return ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(35)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? const Color(0xFF0F1219)
                                    : Colors.white)
                                .withValues(alpha: isDark ? 0.95 : 0.8),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(35)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isDark ? 0.4 : 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5)
                            ],
                          ),
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white12
                                                : Colors.black12,
                                            borderRadius:
                                                BorderRadius.circular(2))),
                                    const SizedBox(height: 12),
                                    Text(isAura ? 'Next' : 'Up Next',
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87)),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                              SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 20),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) {
                                      final song = currentPlaylist[i];
                                      final isPlaying =
                                          song.id == currentSong.id;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isPlaying
                                              ? theme.accentColor.withValues(
                                                  alpha: isDark ? 0.1 : 0.05)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 4),
                                          leading: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: QueryArtworkWidget(
                                                  id: song.id,
                                                  type: ArtworkType.AUDIO,
                                                  nullArtworkWidget: Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: isDark
                                                        ? Colors.white
                                                            .withValues(
                                                                alpha: 0.05)
                                                        : Colors.black
                                                            .withValues(
                                                                alpha: 0.05),
                                                    child: Icon(
                                                        Icons.music_note,
                                                        color: isDark
                                                            ? Colors.white12
                                                            : Colors.black12),
                                                  ),
                                                ),
                                              ),
                                              if (isPlaying)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Icon(
                                                        Icons.bar_chart_rounded,
                                                        color:
                                                            theme.accentColor,
                                                        size: 24),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          title: Text(song.title,
                                              style: TextStyle(
                                                  color: isPlaying
                                                      ? theme.accentColor
                                                      : (isDark
                                                          ? Colors.white
                                                          : Colors.black87),
                                                  fontWeight: isPlaying
                                                      ? FontWeight.bold
                                                      : FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          subtitle: Text(
                                              song.artist ?? 'Unknown',
                                              style: TextStyle(
                                                  color: isPlaying
                                                      ? theme.accentColor
                                                          .withValues(
                                                              alpha: 0.7)
                                                      : (isDark
                                                          ? Colors.white38
                                                          : Colors.black45),
                                                  fontSize: 12)),
                                          onTap: () {
                                            audioService.playPlaylist(
                                                currentPlaylist, i);
                                            palette.updatePalette(song.id);
                                          },
                                        ),
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
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
