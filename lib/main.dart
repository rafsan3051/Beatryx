import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/themed_home_screen.dart';
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
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
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
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          final baseTheme = themeManager.toThemeData();
          return MaterialApp(
            title: 'Beatryx',
            theme: baseTheme.copyWith(
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
    // Initial call to load music provider
    Provider.of<MusicProvider>(context, listen: false);
    
    // Brief delay to ensure app is ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Remove the static Native Splash to show the Animated Flutter Splash
    FlutterNativeSplash.remove();
  }

  void _onSplashFinished() {
    setState(() {
      _showAnimatedSplash = false;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const ThemedHomeScreen(),
    const FavoritesScreen(),
    const PlaylistScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_showAnimatedSplash) {
      return AnimatedSplashScreen(onInitializationComplete: _onSplashFinished);
    }

    final theme = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Dynamic background tint for the whole app
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

          // Sliding Tab View
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _widgetOptions,
          ),
          
          // Glassmorphism Bottom Navigation and MiniPlayer
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
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: MiniPlayer(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Glassmorphism Bottom Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(0, Icons.home_rounded, 'Home'),
                            _buildNavItem(1, Icons.favorite_rounded, 'Favorites'),
                            _buildNavItem(2, Icons.playlist_play_rounded, 'Playlists'),
                            _buildNavItem(3, Icons.settings_rounded, 'Settings'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Provider.of<ThemeManager>(context);
    
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? theme.accentColor.withValues(alpha: 0.15) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? theme.accentColor : theme.textColor.withValues(alpha: 0.4),
              size: 26,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.0,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: theme.accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
