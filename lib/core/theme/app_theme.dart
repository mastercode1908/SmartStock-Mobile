import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Light Theme - preserve original design exactly
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFDAD6), // Keep pinkish but explicit
      onPrimaryContainer: const Color(0xFF410002),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE8EAED), // Neutral grey
      onSecondaryContainer: const Color(0xFF1A1C1E),
      tertiary: const Color(0xFF006A67),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFCCF2F0),
      onTertiaryContainer: const Color(0xFF00201F),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: Colors.white, // Pure white surface
      onSurface: const Color(0xFF1A1C1E),
      surfaceContainerHighest: const Color(0xFFE8EAED), // Neutral grey
      surfaceContainerHigh: const Color(0xFFEDEDED),   // Neutral light grey
      surfaceContainer: const Color(0xFFF3F3F3),        // Neutral
      surfaceContainerLow: const Color(0xFFF5F5F5),     // Near white - FIXES pink icon bg
      surfaceContainerLowest: Colors.white,
      onSurfaceVariant: const Color(0xFF546067),        // Original secondary text color
      outline: const Color(0xFFCFD8DC),
      outlineVariant: const Color(0xFFE0E0E0),
      scrim: Colors.black,
      inverseSurface: const Color(0xFF2F3133),
      onInverseSurface: const Color(0xFFF0F1F3),
      inversePrimary: const Color(0xFFFFB4AB),
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A1C1E),
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFEF5350),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF5C1010),
      onPrimaryContainer: const Color(0xFFFFDAD6),
      secondary: const Color(0xFF9CA3AF),
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF374151),
      onSecondaryContainer: const Color(0xFFE5E7EB),
      tertiary: const Color(0xFF4DB6AC),
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0xFF004D47),
      onTertiaryContainer: const Color(0xFFCCF2F0),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF3A3A3A),
      surfaceContainerHigh: const Color(0xFF333333),
      surfaceContainer: const Color(0xFF2A2A2A),
      surfaceContainerLow: const Color(0xFF262626),     // Dark icon backgrounds
      surfaceContainerLowest: const Color(0xFF121212),
      onSurfaceVariant: const Color(0xFF9CA3AF),
      outline: const Color(0xFF4A4A4A),
      outlineVariant: const Color(0xFF333333),
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE5E7EB),
      onInverseSurface: const Color(0xFF1A1C1E),
      inversePrimary: const Color(0xFFB02528),
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFFEF5350),
      unselectedItemColor: Color(0xFF9CA3AF),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF2C2C2C),
    ),
    dividerColor: const Color(0xFF333333),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Color(0xFF2A2A2A),
      filled: true,
    ),
  );
}
