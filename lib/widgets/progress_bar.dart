import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/player_service.dart';

class ProgressBar extends StatefulWidget {
  final bool showTimeLabels;

  const ProgressBar({
    super.key,
    this.showTimeLabels = true,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  bool _isDragging = false;
  Duration _draggedPosition = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isDragging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<PlayerService>(context);
    final position = _isDragging ? _draggedPosition : playerService.position;
    final duration = playerService.duration ?? Duration.zero;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: const Color(0xFF06FFA5),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: const Color(0xFF06FFA5),
            overlayColor: const Color(0xFF06FFA5).withValues(alpha: 0.2),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                _isDragging = true;
                _draggedPosition = Duration(
                  milliseconds: (value * duration.inMilliseconds).round(),
                );
              });
            },
            onChangeEnd: (value) {
              final newPosition = Duration(
                milliseconds: (value * duration.inMilliseconds).round(),
              );
              playerService.seek(newPosition);
              setState(() {
                _isDragging = false;
              });
            },
          ),
        ),
        if (widget.showTimeLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

