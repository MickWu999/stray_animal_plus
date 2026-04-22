import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFFFDF6EE);
  static const Color surface = Colors.white;
  static const Color surfaceSoft = Color(0xFFF7F0E7);
  static const Color primaryButton = Color(0xFF9D6B47);
  static const Color border = Color(0xFFE7DDD1);
  static const Color male = Color(0xFF3572D4);
  static const Color female = Color(0xFFD25A72);
  static const Color text = Color(0xFF3E2A1E);
  static const Color subText = Color(0xFF6A5A4A);
  static const Color success = Color(0xFF5A8A38);

  static ThemeData get themeData => ThemeData(
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryButton,
      surface: background,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: text,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: text,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: text,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: text, height: 1.45),
      bodyMedium: TextStyle(fontSize: 15, color: subText, height: 1.4),
    ),
  );
}
