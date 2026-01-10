import 'player_ui.dart';
import 'dark_modern_ui.dart';
import 'glassmorphism_ui.dart';
import 'pastel_card_ui.dart';
import 'modern_dark_ui.dart';

enum PlayerUIType {
  darkModern,
  glass,
  pastel,
  modernDark,
}

class PlayerUIFactory {
  static PlayerUI get(PlayerUIType type) {
    switch (type) {
      case PlayerUIType.darkModern:
        return DarkModernUI();
      case PlayerUIType.glass:
        return GlassmorphismUI();
      case PlayerUIType.pastel:
        return PastelCardUI();
      case PlayerUIType.modernDark:
        return ModernDarkUI();
    }
  }
}
