import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final settingsBox = await Hive.openBox('settings');
    _isDarkMode = settingsBox.get('darkMode', defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('darkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'YekanBakh',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      useMaterial3: true,
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'YekanBakh',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blue.shade300,
        unselectedItemColor: Colors.grey.shade600,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      cardColor: const Color(0xFF1E1E1E),
      useMaterial3: true,
    );
  }
}
