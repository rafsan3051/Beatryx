import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class UserInterfaceScreen extends StatelessWidget {
  const UserInterfaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Interface',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            margin: const EdgeInsets.only(left: 48, bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: themeService.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 40,
                  height: 2,
                  color: themeService.accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('User Interface Settings'),
      ),
    );
  }
}

