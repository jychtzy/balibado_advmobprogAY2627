// Enhancement 3: Add settings page to move the dark/light mode switch.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SwitchListTile(
              // Enhancement 3: Dark/Light Mode Switch moved here
              title: CustomText(
                text: 'Dark Mode',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              subtitle: CustomText(
                text: 'Toggle application theme mode',
                fontSize: 12.sp,
              ),
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              value: themeProvider.isDark,
              onChanged: (bool value) {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}