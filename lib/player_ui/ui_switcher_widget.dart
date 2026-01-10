import 'package:flutter/material.dart';
import 'player_ui.dart';
import 'player_ui_factory.dart';

class UISwitcherWidget extends StatefulWidget {
  final PlayerUIType currentUIType;
  final Widget Function(PlayerUI) builder;

  const UISwitcherWidget({
    super.key,
    required this.currentUIType,
    required this.builder,
  });

  @override
  State<UISwitcherWidget> createState() => _UISwitcherWidgetState();
}

class _UISwitcherWidgetState extends State<UISwitcherWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<PlayerUIType>(widget.currentUIType),
        child: widget.builder(PlayerUIFactory.get(widget.currentUIType)),
      ),
    );
  }
}

class PlayerUIManager extends ChangeNotifier {
  PlayerUIType _currentUIType = PlayerUIType.darkModern;

  PlayerUIType get currentUIType => _currentUIType;

  void switchUI(PlayerUIType newType) {
    if (_currentUIType != newType) {
      _currentUIType = newType;
      notifyListeners();
    }
  }

  PlayerUI get currentUI => PlayerUIFactory.get(_currentUIType);
}
