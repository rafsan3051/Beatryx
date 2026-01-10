import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

class MusicScannerService extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<Song> _songs = [];
  bool _isScanning = false;
  bool _hasPermission = false;

  List<Song> get songs => _songs;
  bool get isScanning => _isScanning;
  bool get hasPermission => _hasPermission;
  
  // Stats getters
  int get songCount => _songs.length;
  int get albumCount {
    final albums = _songs.map((s) => s.album).toSet();
    return albums.length;
  }
  int get artistCount {
    final artists = _songs.map((s) => s.artist).toSet();
    return artists.length;
  }
  
  // Get albums list
  List<Map<String, dynamic>> get albums {
    final albumMap = <String, Map<String, dynamic>>{};
    for (var song in _songs) {
      if (!albumMap.containsKey(song.album)) {
        albumMap[song.album] = {
          'name': song.album,
          'artist': song.artist,
          'songCount': 1,
        };
      } else {
        albumMap[song.album]!['songCount'] = 
            (albumMap[song.album]!['songCount'] as int) + 1;
      }
    }
    return albumMap.values.toList();
  }

  Future<bool> requestPermission() async {
    // Check Android version
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use READ_MEDIA_AUDIO
      final permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        final result = await _audioQuery.permissionsRequest();
        if (result) {
          _hasPermission = true;
          notifyListeners();
          return true;
        }
      } else {
        _hasPermission = true;
        notifyListeners();
        return true;
      }
    } else {
      // For iOS
      final status = await Permission.storage.request();
      _hasPermission = status.isGranted;
      notifyListeners();
      return status.isGranted;
    }
    
    _hasPermission = false;
    notifyListeners();
    return false;
  }

  Future<void> scanMusic() async {
    if (_isScanning) return;

    _isScanning = true;
    notifyListeners();

    try {
      // Request permission first
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      // Query all songs
      final songsList = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filter only audio files
      _songs = songsList
          .where((audioModel) => audioModel.isMusic == true)
          .map((audioModel) {
        return Song(
          id: audioModel.id.toString(),
          title: audioModel.title.isNotEmpty ? audioModel.title : 'Unknown Title',
          artist: audioModel.artist?.isNotEmpty == true 
              ? audioModel.artist! 
              : 'Unknown Artist',
          album: audioModel.album?.isNotEmpty == true 
              ? audioModel.album! 
              : 'Unknown Album',
          duration: _formatDuration(audioModel.duration ?? 0),
          filePath: audioModel.data,
        );
      }).toList();

      _isScanning = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error scanning music: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours;
    if (hours > 0) {
      return '${twoDigits(hours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<Uint8List?> getAlbumArt(int songId) async {
    try {
      return await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 500,
      );
    } catch (e) {
      debugPrint('Error getting album art: $e');
      return null;
    }
  }
}

