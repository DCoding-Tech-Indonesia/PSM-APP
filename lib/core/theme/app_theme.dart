import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorsLight.background,

    colorScheme: const ColorScheme.light(
      primary: AppColorsLight.primary,
      secondary: AppColorsLight.secondary,
      background: AppColorsLight.background,
      surface: AppColorsLight.surface,
      error: AppColorsLight.error,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColorsLight.textPrimary),
      displayMedium: TextStyle(color: AppColorsLight.textPrimary),
      displaySmall: TextStyle(color: AppColorsLight.textPrimary),
      headlineLarge: TextStyle(color: AppColorsLight.textPrimary),
      headlineMedium: TextStyle(color: AppColorsLight.textPrimary),
      headlineSmall: TextStyle(color: AppColorsLight.textPrimary),
      titleLarge: TextStyle(color: AppColorsLight.textPrimary),
      titleMedium: TextStyle(color: AppColorsLight.textPrimary),
      titleSmall: TextStyle(color: AppColorsLight.textPrimary),
      bodyLarge: TextStyle(color: AppColorsLight.textPrimary),
      bodyMedium: TextStyle(color: AppColorsLight.textSecondary),
      bodySmall: TextStyle(color: AppColorsLight.textSecondary),
      labelLarge: TextStyle(color: AppColorsLight.textPrimary),
      labelMedium: TextStyle(color: AppColorsLight.textPrimary),
      labelSmall: TextStyle(color: AppColorsLight.textSecondary),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsLight.secondary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColorsDark.primary,
      secondary: AppColorsDark.secondary,
      background: AppColorsDark.background,
      surface: AppColorsDark.surface,
      error: AppColorsDark.error,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColorsDark.textPrimary),
      displayMedium: TextStyle(color: AppColorsDark.textPrimary),
      displaySmall: TextStyle(color: AppColorsDark.textPrimary),
      headlineLarge: TextStyle(color: AppColorsDark.textPrimary),
      headlineMedium: TextStyle(color: AppColorsDark.textPrimary),
      headlineSmall: TextStyle(color: AppColorsDark.textPrimary),
      titleLarge: TextStyle(color: AppColorsDark.textPrimary),
      titleMedium: TextStyle(color: AppColorsDark.textPrimary),
      titleSmall: TextStyle(color: AppColorsDark.textPrimary),
      bodyLarge: TextStyle(color: AppColorsDark.textPrimary),
      bodyMedium: TextStyle(color: AppColorsDark.textSecondary),
      bodySmall: TextStyle(color: AppColorsDark.textSecondary),
      labelLarge: TextStyle(color: AppColorsDark.textPrimary),
      labelMedium: TextStyle(color: AppColorsDark.textPrimary),
      labelSmall: TextStyle(color: AppColorsDark.textSecondary),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsDark.secondary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}