class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String? imageUrl;
  final String? filePath;
  final String? url;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.imageUrl,
    this.filePath,
    this.url,
  });


  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'duration': duration,
        'imageUrl': imageUrl,
        'filePath': filePath,
        'url': url,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        duration: json['duration'],
        imageUrl: json['imageUrl'],
        filePath: json['filePath'],
        url: json['url'],
      );
}

