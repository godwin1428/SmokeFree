import 'package:flutter/material.dart';

class AppColors {
  // Primary Therapeutic Palette
  static const Color primaryTeal = Color(0xFF0F4C5C);
  static const Color primaryLightTeal = Color(0xFF16697A);
  static const Color primaryDeepTeal = Color(0xFF082D37);

  // Vitality & Recovery Accents
  static const Color mintFresh = Color(0xFF2EC4B6);
  static const Color mintLight = Color(0xFFE8FBF8);
  static const Color skyBlue = Color(0xFF48CAE4);
  static const Color softBlue = Color(0xFF82A8D2); // Legacy brand reference

  // Warm Accents & Gamification
  static const Color amberGold = Color(0xFFFFA62B);
  static const Color amberLight = Color(0xFFFFF6E9);
  static const Color coralRed = Color(0xFFE76F51);
  static const Color successGreen = Color(0xFF2A9D8F);

  // Light Theme Surfaces
  static const Color lightBg = Color(0xFFF7FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);

  // Dark Theme Surfaces
  static const Color darkBg = Color(0xFF0B132B);
  static const Color darkSurface = Color(0xFF1C2541);
  static const Color darkCardBorder = Color(0xFF3A506B);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textDarkMuted = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F4C5C), Color(0xFF16697A), Color(0xFF2EC4B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF16697A), Color(0xFF0F4C5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintCardGradient = LinearGradient(
    colors: [Color(0xFF2EC4B6), Color(0xFF48CAE4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFA62B), Color(0xFFFF8E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFE76F51), Color(0xFFF4A261)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
