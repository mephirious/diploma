import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand ───
  static const Color colorMain = Color(0xFF00BFA5);
  static const Color colorSecondary = Color(0xFF1B5E4B);
  static const Color colorAccent = Color(0xFF00E5CC);

  // ─── Functional ───
  static const Color colorError = Color(0xFFE53935);
  static const Color colorSuccess = Color(0xFF43A047);
  static const Color colorWarning = Color(0xFFFFA726);
  static const Color colorInfo = Color(0xFF29B6F6);

  // ─── Light Theme ───
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // ─── Dark Theme ───
  static const Color darkBackground = Color(0xFF0F1923);
  static const Color darkSurface = Color(0xFF1A2737);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ─── Sport category accents ───
  static const Color footballColor = Color(0xFF4CAF50);
  static const Color basketballColor = Color(0xFFFF9800);
  static const Color tennisColor = Color(0xFFFFC107);
  static const Color volleyballColor = Color(0xFF2196F3);
  static const Color swimmingColor = Color(0xFF00BCD4);
  static const Color gymColor = Color(0xFF9C27B0);

  // ─── Gradient ───
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D3B2E), Color(0xFF1B5E4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── AppBar gradient (light theme) – smooth teal, tight diapason ───
  // Goes from a slightly deeper teal to a lighter one; natural and premium.
  static const LinearGradient appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 148, 218, 204),
      Color.fromARGB(255, 28, 122, 100),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── AppBar gradient (dark theme) – same hue, just shifted darker ───
  static const LinearGradient appBarDarkGradient = LinearGradient(
    colors: [Color(0xFF0C5243), Color(0xFF157060)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
