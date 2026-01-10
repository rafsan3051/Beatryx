import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/music_provider.dart';
import '../services/theme_manager.dart';
import '../services/user_provider.dart';
import 'themed_player_screen.dart';
import 'all_songs_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ThemedHomeScreen extends StatelessWidget {
  const ThemedHomeScreen({super.key});

  void _showProfileMenu(BuildContext context, UserProvider userProvider, ThemeManager theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.person_outline_rounded, color: theme.textColor),
              title: Text('Set Profile Manually', style: TextStyle(color: theme.textColor)),
              onTap: () {
                Navigator.pop(context);
                _showManualProfileDialog(context, userProvider, theme);
              },
            ),
            ListTile(
              leading: Icon(Icons.login_rounded, color: theme.textColor),
              title: Text('Sign in with Google', style: TextStyle(color: theme.textColor)),
              onTap: () {
                Navigator.pop(context);
                userProvider.signInWithGoogle();
              },
            ),
            if (userProvider.isSignedIn)
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  userProvider.signOut();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showManualProfileDialog(BuildContext context, UserProvider userProvider, ThemeManager theme) {
    final nameController = TextEditingController(text: userProvider.displayName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surfaceColor,
        title: Text('Set Profile', style: TextStyle(color: theme.textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pick Avatar Image'),
              onTap: () async {
                await userProvider.pickLocalAvatar();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              style: TextStyle(color: theme.textColor),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: theme.subtitleColor),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.subtitleColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.setLocalProfile(nameController.text, userProvider.photoUrl);
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header with Interactive Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello, ${userProvider.displayName}!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: theme.textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showProfileMenu(context, userProvider, theme),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.surfaceColor,
                      backgroundImage: userProvider.photoUrl != null 
                          ? (userProvider.isSignedIn 
                              ? NetworkImage(userProvider.photoUrl!) 
                              : FileImage(File(userProvider.photoUrl!)) as ImageProvider)
                          : null,
                      child: userProvider.photoUrl == null 
                          ? Icon(Icons.person_rounded, color: theme.textColor.withValues(alpha: 0.7))
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: TextField(
                  style: TextStyle(color: theme.textColor),
                  decoration: InputDecoration(
                    hintText: 'Search for a song',
                    hintStyle: GoogleFonts.poppins(color: theme.subtitleColor, fontSize: 15),
                    suffixIcon: Icon(Icons.search_rounded, color: theme.subtitleColor, size: 24),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Categories',
                    style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w600, color: theme.textColor),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategory('All', true, theme, context),
                    _buildCategory('Relax', false, theme, context),
                    _buildCategory('Sad', false, theme, context),
                    _buildCategory('Party', false, theme, context),
                    _buildCategory('Rock', false, theme, context),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Popular Songs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular songs',
                    style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w600, color: theme.textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSongsScreen()));
                    },
                    child: Text('See All', style: TextStyle(color: theme.accentColor)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 280,
                child: musicProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: musicProvider.songs.length.clamp(0, 10),
                      itemBuilder: (context, index) {
                        return _buildPopularSongCard(context, musicProvider.songs[index], theme, musicProvider.songs, index);
                      },
                    ),
              ),
              const SizedBox(height: 32),
              // Recently Listened
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently listened',
                    style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w600, color: theme.textColor),
                  ),
                  Icon(Icons.chevron_right_rounded, color: theme.subtitleColor, size: 28),
                ],
              ),
              const SizedBox(height: 18),
              if (musicProvider.songs.isNotEmpty)
                _buildRecentLargeCard(context, musicProvider.songs[0], theme),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String label, bool isSelected, ThemeManager theme, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == 'All') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSongsScreen()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00C2A0) : theme.surfaceColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.black : theme.subtitleColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSongCard(BuildContext context, SongModel song, ThemeManager theme, List<SongModel> allSongs, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ThemedPlayerScreen(songs: allSongs, initialIndex: index)));
      },
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkWidth: 175,
                  artworkHeight: double.infinity,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Container(
                    color: Colors.white10,
                    child: Icon(Icons.music_note_rounded, size: 64, color: theme.subtitleColor),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: theme.textColor),
                  ),
                  Text(
                    song.artist ?? 'Unknown',
                    maxLines: 1,
                    style: GoogleFonts.poppins(color: theme.subtitleColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLargeCard(BuildContext context, SongModel song, ThemeManager theme) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/seed/music/600/400'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          const Center(
            child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
