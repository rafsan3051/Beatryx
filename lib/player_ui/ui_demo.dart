import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_ui_factory.dart';
import 'ui_switcher_widget.dart';
import '../services/music_provider.dart';

class UIDemo extends StatefulWidget {
  const UIDemo({super.key});

  @override
  State<UIDemo> createState() => _UIDemoState();
}

class _UIDemoState extends State<UIDemo> {
  final _manager = PlayerUIManager();
  int _selectedUIIndex = 0;

  final List<PlayerUIType> _uiTypes = [
    PlayerUIType.darkModern,
    PlayerUIType.glass,
    PlayerUIType.pastel,
    PlayerUIType.modernDark,
  ];

  final List<String> _uiNames = [
    'Dark Modern',
    'Glass',
    'Pastel',
    'Modern Dark',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize music scanning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.fetchSongs();
    });
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _manager,
      builder: (context, _) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: UISwitcherWidget(
              currentUIType: _manager.currentUIType,
              builder: (ui) => ui.buildHome(context),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            elevation: 4,
            backgroundColor: Colors.purple.shade700,
            tooltip: 'Switch UI',
            child: const Icon(Icons.palette, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select UI Theme',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        _uiNames.length,
                        (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedUIIndex = index;
                            });
                            _manager.switchUI(_uiTypes[index]);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: _selectedUIIndex == index
                                  ? Colors.purple.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedUIIndex == index
                                    ? Colors.purple
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  const [
                                    Icons.dark_mode,
                                    Icons.blur_on,
                                    Icons.palette,
                                    Icons.music_note,
                                  ][index],
                                  color: _selectedUIIndex == index
                                      ? Colors.purple
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _uiNames[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedUIIndex == index
                                        ? Colors.purple
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}
