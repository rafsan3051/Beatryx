import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> _playlist = [];
  int _currentIndex = -1;
  bool _autoplayNext = true;
  bool _showMiniPlayer = true;

  AudioPlayer get audioPlayer => _audioPlayer;
  SongModel? get currentSong =>
      _currentIndex == -1 ? null : _playlist[_currentIndex];
  bool get isPlaying => _audioPlayer.playing;
  bool get autoplayNext => _autoplayNext;
  bool get showMiniPlayer => _showMiniPlayer;
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playPlaylist(List<SongModel> songs, int initialIndex) {
    _playlist = songs;
    _currentIndex = initialIndex;
    _playCurrent();
    notifyListeners();
  }

  void _playCurrent() {
    if (currentSong != null) {
      _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(currentSong!.uri!),
          tag: MediaItem(
            id: currentSong!.id.toString(),
            album: currentSong!.album ?? "Unknown Album",
            title: currentSong!.title,
            artist: currentSong!.artist ?? "Unknown Artist",
            artUri: null, // You could add artwork URI here for notifications
          ),
        ),
      );
      _audioPlayer.play();
    }
  }

  void playNext() {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _playCurrent();
      notifyListeners();
    }
  }

  void playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _playCurrent();
      notifyListeners();
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
    notifyListeners();
  }

  AudioPlayerService() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && _autoplayNext) {
        playNext();
      }
      notifyListeners();
    });

    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _autoplayNext = prefs.getBool('autoplayNext') ?? true;
    _showMiniPlayer = prefs.getBool('showMiniPlayer') ?? true;
    notifyListeners();
  }

  Future<void> setAutoplayNext(bool value) async {
    _autoplayNext = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoplayNext', value);
    notifyListeners();
  }

  Future<void> setShowMiniPlayer(bool value) async {
    _showMiniPlayer = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showMiniPlayer', value);
    notifyListeners();
  }
}
