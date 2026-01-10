import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const AnimatedSplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Allow the animations to play for 3.5 seconds before moving to home
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        widget.onInitializationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // 1. White Logo Icon - Perfectly Centered with High Quality
          Center(
            child: Image.asset(
              'assets/images/app_logo_white.png',
              width: 140,
              height: 140,
              filterQuality: FilterQuality.high,
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                  curve: Curves.elasticOut,
                )
                .fade(duration: 800.ms)
                .shimmer(delay: 1500.ms, duration: 1200.ms, color: Colors.white24),
          ),
          
          // 2. Text Image ("Beatryx") - Positioned at the Bottom with High Quality
          Positioned(
            bottom: 100, // Slightly higher for better visibility
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/app_name.png',
                width: 220, // Slightly larger for better clarity
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 1000.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }
}
