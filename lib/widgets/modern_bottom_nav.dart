import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: Icons.music_note_rounded,
                label: 'Songs',
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.album_rounded,
                label: 'Albums',
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Icons.playlist_play_rounded,
                label: 'Playlists',
                index: 3,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                label: 'Settings',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
              size: 24,
            ).animate(target: isSelected ? 1 : 0).scale(
                  duration: 300.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 200.ms).slideX(
                    begin: -0.2,
                    end: 0,
                    duration: 300.ms,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
