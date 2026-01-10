import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MusicProvider extends ChangeNotifier with WidgetsBindingObserver {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _permissionGranted = false;
  bool _permissionDenied = false;

  List<SongModel> get songs => _songs;
  bool get isLoading => _isLoading;
  bool get permissionGranted => _permissionGranted;
  bool get permissionDenied => _permissionDenied;

  static const List<String> _excludedPaths = [
    '/ringtones/', '/notifications/', '/alarms/', 
    'ringtone', 'notification', 'alarm'
  ];

  MusicProvider() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    await requestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionGranted) {
      fetchSongs();
    }
  }

  Future<void> requestPermission() async {
    _isLoading = true;
    _permissionDenied = false;
    notifyListeners();

    try {
      bool hasPermission = false;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        
        if (androidInfo.version.sdkInt >= 33) {
          final status = await Permission.audio.request();
          hasPermission = status.isGranted;
        } else {
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
        }
      } else {
        hasPermission = true;
      }

      _permissionGranted = hasPermission;
      _permissionDenied = !hasPermission;

      if (hasPermission) {
        await fetchSongs();
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      _permissionGranted = false;
      _permissionDenied = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSongs() async {
    if (!_permissionGranted) return;

    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Offload filtering to a background thread if there are many songs
      if (songs.length > 500) {
        _songs = await compute(_filterSongs, songs);
      } else {
        _songs = _filterSongs(songs);
      }
    } catch (e) {
      debugPrint('Error fetching songs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static List<SongModel> _filterSongs(List<SongModel> songs) {
    return songs.where((song) {
      final path = song.data.toLowerCase();
      for (final excluded in _excludedPaths) {
        if (path.contains(excluded)) return false;
      }
      return (song.duration ?? 0) >= 30000;
    }).toList();
  }
}
