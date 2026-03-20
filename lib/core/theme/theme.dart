/*
* File: theme.dart
* Description: Defines the visual themes for the MindCare app, including light and dark modes.
* Responsibilities:
* - set theme ของแอป
*
* Authors:
* - Nanticha Muangpun 650510623
* Course: Mobile App Development
*/


import 'package:flutter/material.dart';

/// Defines the application's visual themes for both light
/// and dark modes.
///
/// This class provides centralized theme configurations
/// used throughout the app to ensure consistent styling,
/// colors, and Material Design behavior.
///
/// Responsibilities:
/// - Provide a light theme configuration
/// - Provide a dark theme configuration
/// - Apply Material 3 design system
/// - Generate color schemes from a seed color
///
/// Notes:
/// - Themes are static and intended for global use
/// - Uses teal as the primary seed color
/// - Can be supplied to MaterialApp's theme properties
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {

  /// Light theme configuration for the application.
  ///
  /// Uses Material 3 with a light brightness setting
  /// and a color scheme generated from a teal seed color.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    ),
  );

  /// Dark theme configuration for the application.
  ///
  /// Uses Material 3 with a dark brightness setting
  /// and a color scheme generated from a teal seed color.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    ),
  );
}