import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ThemeModel manages the application's theme (App State).
// It notifies the app whenever the theme changes.
class ThemeModel with ChangeNotifier {
  // Stores whether Dark Mode is enabled.
  bool _isDark = false;

  // Tracks if the theme has been changed.
  bool _themeChanged = false;

  // Returns the current theme mode.
  bool get isDark => _isDark;

  // Returns true if the theme has changed.
  bool get themeChanged => _themeChanged;

  // Switches between Light Mode and Dark Mode.
  void toggleTheme() {
    _isDark = !_isDark;
    _themeChanged = true;
    notifyListeners();
  }

  // Resets the themeChanged flag after it has been used.
  void resetThemeChanged() {
    _themeChanged = false;
  }
}

// Settings screen where the user can change app settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),

      // Displays the available settings.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Listens for changes in ThemeModel.
          Consumer<ThemeModel>(
            builder: (context, themeModel, child) {
              return SwitchListTile(
                // Switch title.
                title: const Text('Dark Mode'),

                // Short description of the switch.
                subtitle: const Text(
                  'Toggle between Light and Dark theme',
                ),

                // Current value of the switch.
                value: themeModel.isDark,

                // Changes the app theme when the switch is pressed.
                onChanged: (_) {
                  themeModel.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}