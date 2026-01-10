import 'song.dart';

class Artist {
  final String name;
  final List<Song> songs;
  final List<String> albums;

  Artist({
    required this.name,
    required this.songs,
    required this.albums,
  });

  int get songCount => songs.length;
  int get albumCount => albums.length;
}

