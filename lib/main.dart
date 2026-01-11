import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/themed_home_screen.dart';
import 'screens/aura_home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/animated_splash_screen.dart';
import 'services/audio_service.dart';
import 'services/music_provider.dart';
import 'services/theme_manager.dart';
import 'services/ui_manager.dart';
import 'services/user_provider.dart';
import 'services/palette_service.dart';
import 'services/playlist_service.dart';
import 'widgets/mini_player.dart';
import 'screens/themed_player_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => UIManager()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PaletteService()),
        ChangeNotifierProvider(create: (_) => PlaylistService()),
      ],
      child: Consumer2<ThemeManager, UIManager>(
        builder: (context, themeManager, uiManager, _) {
          final isAura = uiManager.currentUI.isAura;
          final baseTheme = themeManager.toThemeData();
          
          return MaterialApp(
            title: 'Beatryx',
            theme: baseTheme.copyWith(
              scaffoldBackgroundColor: isAura ? Colors.white : themeManager.backgroundColor,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _showAnimatedSplash = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _removeNativeSplash();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _removeNativeSplash() async {
    Provider.of<MusicProvider>(context, listen: false);
    FlutterNativeSplash.remove();
  }

  void _onSplashFinished() {
    setState(() {
      _showAnimatedSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showAnimatedSplash) {
      return AnimatedSplashScreen(onInitializationComplete: _onSplashFinished);
    }

    final theme = Provider.of<ThemeManager>(context);
    final uiManager = Provider.of<UIManager>(context);
    final isAura = uiManager.currentUI.isAura;
    
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background
          if (isAura) ...[
            Container(color: Colors.white), // Changed to solid white for all tabs
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFC0CB).withValues(alpha: 0.2), // Lighter pink
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE6E6FA).withValues(alpha: 0.3), // Lighter lavender
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ] else
            Consumer<PaletteService>(
              builder: (context, palette, _) => AnimatedContainer(
                duration: const Duration(seconds: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      palette.dominantColor.withValues(alpha: 0.15),
                      theme.backgroundColor,
                      palette.dominantColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              isAura ? const AuraHomeScreen() : const ThemedHomeScreen(),
              const FavoritesScreen(),
              const PlaylistScreen(),
              const SettingsScreen(),
            ],
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<AudioPlayerService>(
                  builder: (context, audio, _) {
                    if (audio.currentSong != null) {
                      if (isAura) {
                        // Show seek bar above bottom bar instead of mini player for Aura
                        return StreamBuilder<Duration>(
                          stream: audio.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final total = audio.audioPlayer.duration ?? Duration.zero;
                            double progress = 0.0;
                            if (total.inMilliseconds > 0) {
                              progress = position.inMilliseconds / total.inMilliseconds;
                            }
                            return Container(
                              margin: const EdgeInsets.fromLTRB(40, 0, 40, 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  backgroundColor: Colors.black12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD81B60)),
                                  minHeight: 3,
                                ),
                              ),
                            );
                          },
                        );
                      } else if (audio.showMiniPlayer) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: MiniPlayer(),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Bottom Navigation
                _buildBottomNav(isAura, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isAura, ThemeManager theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isAura ? 0.05 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isAura ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_filled),
              _buildNavItem(1, Icons.favorite_rounded),
              _buildAuraCenterButton(isAura),
              _buildNavItem(2, Icons.playlist_play_rounded),
              _buildNavItem(3, Icons.settings_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuraCenterButton(bool isAura) {
    if (!isAura) return const SizedBox.shrink();
    return Consumer<AudioPlayerService>(
      builder: (context, audio, _) {
        final song = audio.currentSong;
        return GestureDetector(
          onTap: () {
            if (song != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThemedPlayerScreen(
                    songs: audio.playlist,
                    initialIndex: audio.currentIndex,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD81B60).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: song != null
                  ? QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkFit: BoxFit.cover,
                      nullArtworkWidget: Container(
                        color: const Color(0xFFD81B60),
                        child: const Icon(Icons.music_note, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFD81B60),
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    final theme = Provider.of<ThemeManager>(context);
    final uiManager = Provider.of<UIManager>(context);
    final isAura = uiManager.currentUI.isAura;
    
    return IconButton(
      onPressed: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      },
      icon: Icon(
        icon,
        color: isSelected 
            ? (isAura ? const Color(0xFFD81B60) : theme.accentColor) 
            : (isAura ? Colors.black26 : theme.textColor.withValues(alpha: 0.4)),
        size: 26,
      ),
    );
  }
}
