import 'package:flutter/material.dart';
import 'dart:ui';
import 'player_ui_screen.dart';

class GlassmorphismScreen extends PlayerUIScreen {
  const GlassmorphismScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: const ValueKey('glass_body'),
          child: Stack(
            children: [
              // Soft gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE3F2FD),
                      Color(0xFFF8EAF6),
                      Color(0xFFFFF8E1)
                    ],
                  ),
                ),
              ),
              // Global blur veil
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.white.withValues(alpha: 0.05)),
              ),

              // Centered circular album art
              Align(
                alignment: Alignment.center,
                child: RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(160),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                spreadRadius: 4),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.album_rounded,
                              color: Color(0xFF1A1A1A), size: 96),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating controls (no BottomNavigationBar)
              Positioned(
                left: 24,
                right: 24,
                bottom: 36,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              spreadRadius: 2),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.shuffle_rounded,
                              color: Color(0xFF3D3D3D), size: 24),
                          Icon(Icons.skip_previous_rounded,
                              color: Color(0xFF1A1A1A), size: 36),
                          _GlassPlayButton(),
                          Icon(Icons.skip_next_rounded,
                              color: Color(0xFF1A1A1A), size: 36),
                          Icon(Icons.repeat_rounded,
                              color: Color(0xFF3D3D3D), size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Header labels floating
              Positioned(
                top: 54,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _frostedIcon(Icons.expand_more),
                    _frostedIcon(Icons.favorite_border),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _frostedIcon(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFF1A1A1A), size: 24),
        ),
      ),
    );
  }
}

class _GlassPlayButton extends StatelessWidget {
  const _GlassPlayButton();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.7), width: 2),
          ),
          child: const Icon(Icons.play_arrow_rounded,
              color: Color(0xFF1A1A1A), size: 40),
        ),
      ),
    );
  }
}
