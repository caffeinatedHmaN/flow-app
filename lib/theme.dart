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
      case 'deerflow':
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

class FlowTheme {
  static ThemeData deerflow() {
    FlowColors.applyTheme('deerflow');
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FlowColors.bg,
      colorScheme: ColorScheme.dark(
        primary: FlowColors.accent,
        surface: FlowColors.surface,
        onSurface: FlowColors.textPrimary,
      ),
    );
  }
}
