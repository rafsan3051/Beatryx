import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song.dart';

enum RepeatMode {
  none,
  one,
  all,
}

class PlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;
  List<String> _favorites = [];
  List<Song> _recentlyPlayed = [];

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isPlaying => _audioPlayer.playing;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  List<String> get favorites => _favorites;
  List<Song> get recentlyPlayed => _recentlyPlayed;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  PlayerService() {
    _init();
    _audioPlayer.playerStateStream.listen((state) {
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> _init() async {
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');
      if (favoritesJson != null) {
        _favorites = List<String>.from(jsonDecode(favoritesJson));
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('favorites', jsonEncode(_favorites));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    if (playlist != null && index != null) {
      _playlist = playlist;
      _currentIndex = index;
    } else {
      _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _playlist = [song];
        _currentIndex = 0;
      }
    }

    try {
      if (song.filePath != null && song.filePath!.isNotEmpty) {
        await _audioPlayer.setFilePath(song.filePath!);
      } else if (song.url != null && song.url!.isNotEmpty) {
        await _audioPlayer.setUrl(song.url!);
      } else {
        throw Exception('No valid audio source found');
      }
      await _audioPlayer.play();
      _addToRecentlyPlayed(song);
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing song: $e');
      rethrow;
    }
  }

  void _addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 20);
    }
  }

  void setPlaylist(List<Song> songs, {bool shuffle = false}) {
    _playlist = List.from(songs);
    if (shuffle && _playlist.isNotEmpty) {
      _playlist.shuffle();
    }
    _currentIndex = 0;
    if (_playlist.isNotEmpty) {
      playSong(_playlist[0]);
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    if (_repeatMode == RepeatMode.one) {
      await _audioPlayer.seek(Duration.zero);
      await play();
      return;
    }

    if (_isShuffle) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }

    await playSong(_playlist[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }

    if (_isShuffle) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    }

    await playSong(_playlist[_currentIndex]);
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  bool isFavorite(String songId) {
    return _favorites.contains(songId);
  }

  Future<void> toggleFavorite(String songId) async {
    if (_favorites.contains(songId)) {
      _favorites.remove(songId);
    } else {
      _favorites.add(songId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
