import 'package:flutter/material.dart';

// =====================================================================
// Single source of truth for brand colors + ThemeData.
// Previously cart_screen.dart, product_screen.dart, product_details.dart
// and home_screen.dart each redefined the same _kPrimary/_kAccent/etc.
// locally — fine until someone updates one and forgets the other three.
// Screens should now import this file and use AppColors.* / Theme.of(context)
// instead of declaring their own color constants.
// =====================================================================

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF313376); // brand indigo
  static const Color accent = Color(0xFFF5A623); // CTA amber
  static const Color accentDark = Color(0xFFC97F00);
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF1F9254);
  static const Color backgroundLight = Color(0xFFF6F6FA);
  static const Color backgroundDark = Color(0xFF16161D);
  static const Color surfaceDark = Color(0xFF201F2B);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(secondary: AppColors.accent, error: AppColors.danger);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE7E7EE),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(secondary: AppColors.accent, error: AppColors.danger);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}