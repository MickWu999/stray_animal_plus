import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFFFDF6EE);
  static const Color primaryButton = Color(0xFF9D6B47);
  static const Color text = Color(0xFF3E2A1E);
  static const Color subText = Color(0xFF6A5A4A);

  static ThemeData get themeData => ThemeData(
        scaffoldBackgroundColor: background,
        useMaterial3: true,
      );
}
