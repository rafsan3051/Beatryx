import 'package:flutter/material.dart';
import 'player_ui_screen.dart';

class PastelCardScreen extends PlayerUIScreen {
  const PastelCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
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
          key: const ValueKey('pastel_body'),
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Color(0xFFFDF7F0),
                elevation: 0,
                floating: true,
                snap: true,
                title: Text(
                  'Pastel Vibes',
                  style: TextStyle(
                    color: Color(0xFF5D4E6D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
              ),

              // Horizontal section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Featured',
                          style: TextStyle(
                            color: Color(0xFF5D4E6D),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RepaintBoundary(
                        child: SizedBox(
                          height: 190,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: 10,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, i) =>
                                _PastelAlbumCard(index: i),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Card-based list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                sliver: SliverList.separated(
                  itemCount: 16,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => RepaintBoundary(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF0F5), Color(0xFFE8F4FD)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFB8E6F5).withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD8CC), Color(0xFFDEB6F5)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.queue_music_rounded,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Soft Morning',
                                    style: TextStyle(
                                        color: Color(0xFF5D4E6D),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('24 songs',
                                    style: TextStyle(
                                        color: Color(0xFF9A8AA5),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF9A8AA5), size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Spacer at bottom
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastelAlbumCard extends StatelessWidget {
  final int index;
  const _PastelAlbumCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFB8E6F5),
      const Color(0xFFD1C4E9),
      const Color(0xFFFFD8CC),
      const Color(0xFFDEB6F5),
    ];
    final a = colors[index % colors.length];
    final b = colors[(index + 1) % colors.length];

    return RepaintBoundary(
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [a, b]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: a.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.album_rounded, color: Colors.white, size: 56),
        ),
      ),
    );
  }
}
