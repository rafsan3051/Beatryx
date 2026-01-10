import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_service.dart';

class PlayerControls extends StatelessWidget {
  final bool showShuffleRepeat;

  const PlayerControls({
    super.key,
    this.showShuffleRepeat = true,
  });

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context);

    return Column(
      children: [
        if (showShuffleRepeat) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => playerService.toggleShuffle(),
                icon: Icon(
                  Icons.shuffle,
                  color: playerService.isShuffle
                      ? const Color(0xFF06FFA5)
                      : Colors.white.withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 40),
              IconButton(
                onPressed: () => playerService.toggleRepeat(),
                icon: Icon(
                  Icons.repeat,
                  color: playerService.repeatMode != RepeatMode.none
                      ? const Color(0xFF06FFA5)
                      : Colors.white.withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => playerService.playPrevious(),
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => playerService.playPause(),
                  borderRadius: BorderRadius.circular(35),
                  child: Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    child: Icon(
                      playerService.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => playerService.playNext(),
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

