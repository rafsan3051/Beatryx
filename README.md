# Beatryx - Music Player App

A beautiful and feature-rich music player app built with Flutter, designed for Android 12+ devices.

**GitHub Repository**: [https://github.com/rafsan3051/Beatryx.git](https://github.com/rafsan3051/Beatryx.git)

## Features

- 🎵 **Play/Pause Controls** - Intuitive music playback controls
- ⏭️ **Next/Previous** - Navigate through your playlist easily
- 🔀 **Shuffle Mode** - Randomize your music experience
- 🔁 **Repeat Mode** - Loop your favorite songs
- 📊 **Progress Bar** - Seek through songs with a beautiful progress indicator
- 🔊 **Volume Control** - Adjust volume with a sleek slider
- 🎨 **Clean UI** - Modern, gradient-based design with smooth animations
- 🎧 **Now Playing Screen** - Full-screen player with rotating album art
- 🔍 **Search** - Quickly find songs, artists, or albums
- ❤️ **Favorites** - Mark your favorite songs
- 📱 **Local Music Scanning** - Automatically scans and plays music from your device
- 🔐 **Permission Handling** - Smart permission requests for Android 12+
- 📱 **Android 12+ Support** - Fully optimized for Android 12 and later versions

## Screenshots

### Home Screen

- View all your songs
- Quick stats (Songs, Favorites, Playing)
- Search functionality
- Mini player at the bottom

### Now Playing Screen

- Large rotating album art
- Full player controls
- Progress bar with time indicators
- Volume control
- Shuffle and repeat modes

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/rafsan3051/Beatryx.git
cd beatryx
```

1. Install dependencies:

```bash
flutter pub get
```

1. Run the app:

```bash
flutter run
```

## What's Included

This project includes:

- ✅ Complete music player UI with modern design
- ✅ Audio playback functionality with player controls
- ✅ Local music file scanning from device storage
- ✅ Song search and filtering
- ✅ Favorites management
- ✅ Volume and progress controls
- ✅ Android 12+ permission handling
- ✅ State management with Provider
- ✅ Smooth animations and transitions
- ✅ Responsive design for various screen sizes

## Next Steps

After cloning and setting up the project, you can:

1. **Run the app on your device**:

```bash
flutter run
```

1. **Customize the theme** - Edit `lib/theme/app_theme.dart` to change colors

1. **Build for release** (when ready):

```bash
flutter build apk --release
# or for App Bundle:
flutter build appbundle --release
```

1. **Implement future features** like:

   - Playlist management
   - Album/Artist views
   - Equalizer support
   - Background playback optimization
   - Lock screen controls

1. **Deploy to Google Play Store** - Follow Flutter's official deployment guide

## Clone & Setup Instructions

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/rafsan3051/Beatryx.git

# 2. Navigate to the project directory
cd beatryx

# 3. Get all dependencies
flutter pub get

# 4. Run on connected device/emulator
flutter run
```

### System Requirements

- **Flutter**: 3.0.0 or higher
- **Dart**: 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter extension
- **Android SDK**: API 21 and higher (targeting API 34)
- **Java Development Kit (JDK)**: 11 or higher

### Detailed Setup

1. **Install Flutter SDK** (if not already installed):

   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH

1. **Verify your environment**:

```bash
flutter doctor
```

1. **Clone and enter the project**:

```bash
git clone https://github.com/rafsan3051/Beatryx.git
cd beatryx
```

1. **Install dependencies**:

```bash
flutter pub get
```

1. **Run the application**:

   - On emulator: `flutter run`
   - On physical device: Connect device and run `flutter run`

### Building for Production

```bash
# Build APK for Android
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

The output files will be in:

- APK: `build/app/outputs/flutter-apk/`
- App Bundle: `build/app/outputs/bundle/`

## Project Structure

```text
lib/
├── models/
│   └── song.dart                    # Song model class
├── services/
│   ├── player_service.dart          # Audio player service
│   └── music_scanner_service.dart   # Local music scanning service
├── screens/
│   ├── home_screen.dart             # Main screen with song list
│   └── now_playing_screen.dart      # Full player screen
├── widgets/
│   ├── mini_player.dart             # Bottom mini player
│   ├── player_controls.dart         # Play/pause/next/prev controls
│   ├── progress_bar.dart            # Progress indicator
│   └── song_tile.dart               # Song list item widget
├── theme/
│   └── app_theme.dart               # App theme and colors
└── main.dart                        # App entry point
```

## Dependencies

- `just_audio` - Audio playback
- `audio_service` - Background audio support
- `provider` - State management
- `shared_preferences` - Local storage
- `google_fonts` - Beautiful typography
- `flutter_animate` - Smooth animations
- `on_audio_query` - Scan local music files from device storage
- `permission_handler` - Handle storage permissions for Android 12+
- `path_provider` - Access device file paths

## Android Support

This app is designed for **Android 12 (API 31) and later versions**.

### Permissions

The app requests the following permissions:

- **Android 12 and below**: `READ_EXTERNAL_STORAGE`
- **Android 13 and above**: `READ_MEDIA_AUDIO`

Permissions are requested automatically when you first launch the app. Grant permission when prompted to scan your device's music library.

### Minimum Requirements

- **Minimum SDK**: Android 5.0 (API 21)
- **Target SDK**: Android 14 (API 34)
- **Compile SDK**: Flutter default (34)

### Changing Theme Colors

Edit `lib/theme/app_theme.dart` to customize the app's color scheme.

## Features to Add

- Playlist management
- Album view
- Artist view
- Recently played
- Most played
- Equalizer
- Lyrics display
- Background playback
- Lock screen controls

## License

This project is open source and available for personal use.

## Contributing

Feel free to submit issues and enhancement requests!
