import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _playlist = [];
  bool _autoplayNext = true;
  bool _showMiniPlayer = false; // Initially false, shown when song starts
  bool _isProcessing = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  
  SongModel? get currentSong {
    final index = _audioPlayer.currentIndex;
    if (index != null && index >= 0 && index < _playlist.length) {
      return _playlist[index];
    }
    return null;
  }

  bool get isPlaying => _audioPlayer.playing;
  bool get autoplayNext => _autoplayNext;
  bool get showMiniPlayer => _showMiniPlayer;
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _audioPlayer.currentIndex ?? -1;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playPlaylist(List<SongModel> songs, int initialIndex) async {
    if (_isProcessing) return;
    _isProcessing = true;
    
    try {
      _playlist = songs;
      
      final audioSources = songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album ?? "Unknown Album",
            title: song.title,
            artist: song.artist ?? "Unknown Artist",
            artUri: null,
          ),
        );
      }).toList();

      // ignore: deprecated_member_use
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      
      _audioPlayer.play();
      _showMiniPlayer = true; // Auto-show miniplayer when music starts
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading playlist: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> playNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    }
  }

  Future<void> playPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    }
  }

  void togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    notifyListeners();
  }

  void stop() {
    _audioPlayer.stop();
    _showMiniPlayer = false;
    notifyListeners();
  }

  void pause() {
    _audioPlayer.pause();
    notifyListeners();
  }

  // Shuffle & Repeat functionality
  bool get isShuffleMode => _audioPlayer.shuffleModeEnabled;
  LoopMode get repeatMode => _audioPlayer.loopMode;

  void toggleShuffle() {
    _audioPlayer.setShuffleModeEnabled(!isShuffleMode);
    notifyListeners();
  }

  void nextRepeatMode() {
    final modes = [LoopMode.off, LoopMode.all, LoopMode.one];
    final nextIndex = (modes.indexOf(repeatMode) + 1) % modes.length;
    _audioPlayer.setLoopMode(modes[nextIndex]);
    notifyListeners();
  }

  AudioPlayerService() {
    _audioPlayer.playerStateStream.listen((state) {
      notifyListeners();
    });

    _audioPlayer.currentIndexStream.listen((index) {
      notifyListeners();
    });

    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _autoplayNext = prefs.getBool('autoplayNext') ?? true;
    notifyListeners();
  }

  Future<void> setAutoplayNext(bool value) async {
    _autoplayNext = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoplayNext', value);
    notifyListeners();
  }

  void setShowMiniPlayer(bool value) {
    _showMiniPlayer = value;
    notifyListeners();
  }
}
