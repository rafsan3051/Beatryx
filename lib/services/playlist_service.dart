import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistService extends ChangeNotifier {
  static const String _playlistsKey = 'playlists';
  List<Playlist> _playlists = [];
  List<String> _favoriteSongIds = [];
  Map<String, int> _playCounts = {}; // songId -> play count
  Map<String, DateTime> _lastPlayed = {}; // songId -> last played time

  List<Playlist> get playlists => _playlists;
  List<String> get favoriteSongIds => _favoriteSongIds;

  PlaylistService() {
    _loadPlaylists();
    _loadFavorites();
    _loadPlayStats();
  }

  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getString(_playlistsKey);
    if (playlistsJson != null) {
      final List<dynamic> decoded = json.decode(playlistsJson);
      _playlists = decoded.map((json) => Playlist.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = json.encode(_playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_playlistsKey, playlistsJson);
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteSongIds = prefs.getStringList('favorite_songs') ?? [];
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_songs', _favoriteSongIds);
    notifyListeners();
  }

  Future<void> _loadPlayStats() async {
    final prefs = await SharedPreferences.getInstance();
    final playCountsJson = prefs.getString('play_counts');
    final lastPlayedJson = prefs.getString('last_played');
    
    if (playCountsJson != null) {
      _playCounts = Map<String, int>.from(json.decode(playCountsJson));
    }
    
    if (lastPlayedJson != null) {
      final decoded = json.decode(lastPlayedJson) as Map<String, dynamic>;
      _lastPlayed = decoded.map((key, value) => MapEntry(key, DateTime.parse(value)));
    }
  }

  Future<void> _savePlayStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('play_counts', json.encode(_playCounts));
    await prefs.setString('last_played', json.encode(
      _lastPlayed.map((key, value) => MapEntry(key, value.toIso8601String())),
    ));
  }

  Future<void> createPlaylist(String name, {String description = ''}) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      songIds: [],
      type: PlaylistType.custom,
      createdAt: DateTime.now(),
    );
    _playlists.add(playlist);
    await _savePlaylists();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _savePlaylists();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex == -1) return;
    
    final playlist = _playlists[playlistIndex];
    if (!playlist.songIds.contains(songId)) {
      final updatedSongIds = List<String>.from(playlist.songIds)..add(songId);
      final updatedPlaylist = Playlist(
        id: playlist.id,
        name: playlist.name,
        description: playlist.description,
        songIds: updatedSongIds,
        type: playlist.type,
        createdAt: playlist.createdAt,
        updatedAt: DateTime.now(),
      );
      _playlists[playlistIndex] = updatedPlaylist;
      await _savePlaylists();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex == -1) return;
    
    final playlist = _playlists[playlistIndex];
    final updatedSongIds = List<String>.from(playlist.songIds)..remove(songId);
    final updatedPlaylist = Playlist(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      songIds: updatedSongIds,
      type: playlist.type,
      createdAt: playlist.createdAt,
      updatedAt: DateTime.now(),
    );
    _playlists[playlistIndex] = updatedPlaylist;
    await _savePlaylists();
  }

  Future<void> toggleFavorite(String songId) async {
    if (_favoriteSongIds.contains(songId)) {
      _favoriteSongIds.remove(songId);
    } else {
      _favoriteSongIds.add(songId);
    }
    await _saveFavorites();
  }

  bool isFavorite(String songId) => _favoriteSongIds.contains(songId);

  Future<void> recordPlay(String songId) async {
    _playCounts[songId] = (_playCounts[songId] ?? 0) + 1;
    _lastPlayed[songId] = DateTime.now();
    await _savePlayStats();
  }

  List<Song> getRecentlyPlayed(List<Song> allSongs) {
    final sorted = _lastPlayed.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final songIds = sorted.map((e) => e.key).take(50).toList();
    return allSongs.where((s) => songIds.contains(s.id)).toList()
      ..sort((a, b) {
        final aIndex = songIds.indexOf(a.id);
        final bIndex = songIds.indexOf(b.id);
        return aIndex.compareTo(bIndex);
      });
  }

  List<Song> getMostPlayed(List<Song> allSongs) {
    final sorted = _playCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final songIds = sorted.map((e) => e.key).take(50).toList();
    return allSongs.where((s) => songIds.contains(s.id)).toList()
      ..sort((a, b) {
        final aCount = _playCounts[a.id] ?? 0;
        final bCount = _playCounts[b.id] ?? 0;
        return bCount.compareTo(aCount);
      });
  }

  List<Song> getFavoriteSongs(List<Song> allSongs) {
    return allSongs.where((s) => _favoriteSongIds.contains(s.id)).toList();
  }

  List<Song> getPlaylistSongs(String playlistId, List<Song> allSongs) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    return allSongs.where((s) => playlist.songIds.contains(s.id)).toList();
  }
}

