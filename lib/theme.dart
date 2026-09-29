import 'package:flutter/material.dart';

class FlowColors {
  static Color bg = const Color(0xFF050505);
  static Color surface = const Color(0xFF0C0C0C);
  static Color card = const Color(0xFF0C0C0C);
  static Color border = const Color(0xFF161616);
  static Color textPrimary = const Color(0xFFE8E6E3);
  static Color textSecondary = const Color(0xFF888888);
  static Color textMuted = const Color(0xFF555555);
  static Color accent = const Color(0xFFFF4400);

  static void applyTheme(String name) {
    switch (name) {
      case 'paper':
        bg = const Color(0xFFF1EEE7);
        surface = const Color(0xFFFFFFFF);
        card = const Color(0xFFFFFFFF);
        border = const Color(0xFFDDD8CD);
        textPrimary = const Color(0xFF16161A);
        textSecondary = const Color(0xFF6F6E68);
        textMuted = const Color(0xFFA8A399);
        accent = const Color(0xFFE85D2C);
        break;
      case 'midnight':
        bg = const Color(0xFF070B14);
        surface = const Color(0xFF0F1520);
        card = const Color(0xFF0F1520);
        border = const Color(0xFF1E2A3E);
        textPrimary = const Color(0xFFE8EEF7);
        textSecondary = const Color(0xFF8896AA);
        textMuted = const Color(0xFF4A5568);
        accent = const Color(0xFF5B8DEF);
        break;
      default:
        bg = const Color(0xFF050505);
        surface = const Color(0xFF0C0C0C);
        card = const Color(0xFF0C0C0C);
        border = const Color(0xFF161616);
        textPrimary = const Color(0xFFE8E6E3);
        textSecondary = const Color(0xFF888888);
        textMuted = const Color(0xFF555555);
        accent = const Color(0xFFFF4400);
    }
  }
}

class FlowText {
  static const String mono = 'monospace';

  static TextStyle number({
    double size = 16,
    FontWeight weight = FontWeight.w800,
    Color? color,
    double spacing = -0.5,
  }) =>
      TextStyle(
        fontFamily: mono,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle label({
    double size = 10,
    Color? color,
    double spacing = 1.4,
  }) =>
      TextStyle(
        fontFamily: mono,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: spacing,
        color: color,
      );

  static TextStyle body({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: mono,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}
