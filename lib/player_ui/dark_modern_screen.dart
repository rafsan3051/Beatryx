import 'package:flutter/material.dart';
import 'player_ui_screen.dart';

class DarkModernScreen extends PlayerUIScreen {
  const DarkModernScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0C),
        elevation: 0,
        title: const Text(
          'Dark Library',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: const ValueKey('dark_modern_body'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: RepaintBoundary(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF17181A),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xAA000000),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.album,
                        size: 110, color: Color(0xFF2E3033)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Night Runner',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Neon Drive',
                      style: TextStyle(color: Color(0xFF9AA0A6), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: RepaintBoundary(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: 12,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Color(0xFF25272A)),
                    itemBuilder: (context, i) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2023),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.music_note,
                            color: Color(0xFF3C4043)),
                      ),
                      title: Text('Track ${i + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      subtitle: const Text('Artist',
                          style: TextStyle(color: Color(0xFF9AA0A6))),
                      trailing:
                          const Icon(Icons.more_vert, color: Color(0xFF9AA0A6)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomControlsBar(),
    );
  }
}

class _BottomControlsBar extends StatelessWidget {
  const _BottomControlsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: const BoxDecoration(
        color: Color(0xFF121315),
        border: Border(top: BorderSide(color: Color(0xFF202225))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
            _PlayButton(),
            Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child:
          const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 40),
    );
  }
}
