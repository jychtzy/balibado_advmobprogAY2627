import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  // Added getters for ThemeData referenced in main.dart
  ThemeData get lightTheme => ThemeData.light();
  ThemeData get darkTheme => ThemeData.dark();

  // Enhancement 3: Method called by the switch on SettingsScreen
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}