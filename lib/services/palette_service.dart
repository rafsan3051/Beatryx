import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:typed_data';

class PaletteService extends ChangeNotifier {
  Color _dominantColor = const Color(0xFF1E1E1E);
  Color get dominantColor => _dominantColor;

  final OnAudioQuery _audioQuery = OnAudioQuery();
  int? _currentSongId;

  Future<void> updatePalette(int songId) async {
    if (_currentSongId == songId) return;
    _currentSongId = songId;

    try {
      final Uint8List? artwork = await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 300,
      );

      if (artwork != null) {
        final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
          MemoryImage(artwork),
          maximumColorCount: 10,
        );
        
        final newColor = paletteGenerator.dominantColor?.color ?? const Color(0xFF1E1E1E);
        if (_dominantColor != newColor) {
          _dominantColor = newColor;
          notifyListeners();
        }
      } else {
        if (_dominantColor != const Color(0xFF1E1E1E)) {
          _dominantColor = const Color(0xFF1E1E1E);
          notifyListeners();
        }
      }
    } catch (e) {
      // Keep previous color on error to avoid flashing
      debugPrint('Palette generation error: $e');
    }
  }
}
