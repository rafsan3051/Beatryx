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
          return MaterialApp(
            title: 'Beatryx',
            theme: themeManager.toThemeData(),
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

  @override
  void initState() {
    super.initState();
    _initialization();
  }

  void _initialization() async {
    // We trigger the music provider loading but don't wait for it to finish
    // before showing the UI, to prevent the app from feeling stuck.
    Provider.of<MusicProvider>(context, listen: false);
    
    // Reduce wait time to 1 second for a faster feel
    await Future.delayed(const Duration(seconds: 1));
    
    // Remove splash screen
    FlutterNativeSplash.remove();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const ThemedHomeScreen(),
    const FavoritesScreen(),
    const PlaylistScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          
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
                        padding: EdgeInsets.only(bottom: 12),
                        child: MiniPlayer(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(0, Icons.home_rounded),
                            _buildNavItem(1, Icons.favorite_border_rounded),
                            _buildNavItem(2, Icons.playlist_play_rounded),
                            _buildNavItem(3, Icons.settings_rounded),
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

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 55,
        height: 55,
        decoration: isSelected ? BoxDecoration(
          color: const Color(0xFF2D2D2D).withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ) : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white24,
          size: 28,
        ),
      ),
    );
  }
}
