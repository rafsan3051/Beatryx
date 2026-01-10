import 'song.dart';

class Album {
  final String name;
  final String artist;
  final List<Song> songs;
  final String? artworkPath;

  Album({
    required this.name,
    required this.artist,
    required this.songs,
    this.artworkPath,
  });

  int get songCount => songs.length;
  
  Duration get totalDuration {
    // This would need parsing duration strings - simplified for now
    return Duration(minutes: songs.length * 3); // Placeholder
  }
}

