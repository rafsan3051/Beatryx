import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_service.dart';

class AudioVisualizer extends StatefulWidget {
  final int barCount;
  final Color color;
  final double barWidth;
  final double barSpacing;

  const AudioVisualizer({
    super.key,
    this.barCount = 30, // Reduced for better performance
    this.color = Colors.white,
    this.barWidth = 4.0,
    this.barSpacing = 2.0,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Slower animation for better performance
    );
    
    // Initialize bar heights
    final random = math.Random();
    for (int i = 0; i < widget.barCount; i++) {
      _barHeights.add(random.nextDouble() * 0.3 + 0.1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, playerService, _) {
        final isPlaying = playerService.isPlaying;
        
        // Control animation based on playing state
        if (isPlaying && !_controller.isAnimating) {
          _controller.repeat();
        } else if (!isPlaying && _controller.isAnimating) {
          _controller.stop();
        }
        
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Update bar heights based on animation and playing state
            if (isPlaying && _controller.isAnimating) {
              for (int i = 0; i < _barHeights.length; i++) {
                // Create wave-like pattern - optimized calculation
                final phase = (i / _barHeights.length) * 2 * math.pi;
                final time = _controller.value * 2 * math.pi;
                final baseHeight = (math.sin(phase + time) + 1) / 2;
                _barHeights[i] = (baseHeight * 0.8 + 0.2).clamp(0.1, 1.0);
              }
            } else if (!isPlaying) {
              // Gradually decrease heights when not playing
              for (int i = 0; i < _barHeights.length; i++) {
                _barHeights[i] = (_barHeights[i] * 0.95).clamp(0.05, 1.0);
              }
            }

            return RepaintBoundary(
              child: CustomPaint(
                painter: _VisualizerPainter(
                  barHeights: List.from(_barHeights),
                  color: widget.color,
                  barWidth: widget.barWidth,
                  barSpacing: widget.barSpacing,
                ),
                child: Container(),
              ),
            );
          },
        );
      },
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;
  final double barWidth;
  final double barSpacing;

  _VisualizerPainter({
    required this.barHeights,
    required this.color,
    required this.barWidth,
    required this.barSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final totalBarWidth = barWidth + barSpacing;
    final startX = (size.width - (barHeights.length * totalBarWidth - barSpacing)) / 2;

    for (int i = 0; i < barHeights.length; i++) {
      final x = startX + i * totalBarWidth;
      final height = barHeights[i] * size.height * 0.8;
      final y = (size.height - height) / 2;

      // Simplified rendering for better performance
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_VisualizerPainter oldDelegate) {
    return oldDelegate.barHeights != barHeights;
  }
}

