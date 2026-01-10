class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> songIds;
  final PlaylistType type;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Playlist({
    required this.id,
    required this.name,
    this.description = '',
    required this.songIds,
    this.type = PlaylistType.custom,
    required this.createdAt,
    this.updatedAt,
  });

  int get songCount => songIds.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'songIds': songIds,
        'type': type.toString(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        songIds: List<String>.from(json['songIds']),
        type: PlaylistType.values.firstWhere(
          (e) => e.toString() == json['type'],
          orElse: () => PlaylistType.custom,
        ),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );
}

enum PlaylistType {
  custom,
  album,
  artist,
  mood,
  recentlyPlayed,
  mostPlayed,
  favorites,
}

