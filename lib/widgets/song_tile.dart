import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            color: isPlaying ? const Color(0xFF06FFA5) : Colors.white,
            fontSize: 16,
            fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white.withValues(alpha: 0.6),
                size: 22,
              ),
              onPressed: onFavoriteTap,
            ),
            const SizedBox(width: 8),
            Text(
              song.duration,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

