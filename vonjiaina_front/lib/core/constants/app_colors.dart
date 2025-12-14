import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales (dominantes)
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color primaryLight = Color(0xFF1B9AAA);
  
  // Couleur milieu (gradient)
  static const Color accentTeal = Color(0xFF2ACCCF);
  
  // Couleurs décoration
  static const Color decorLight = Color(0xFF4DE5DD);
  static const Color decorVeryLight = Color(0xFF5FF5E8);
  
  // Fond général
  static const Color background = Color(0xFFF5F7FA);
  
  // Couleurs fonctionnelles
  static const Color success = Color(0xFF1B9AAA);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  
  // Textes
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Gradient principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryLight, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient pour boutons
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryLight, accentTeal],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Gradient décoratif
  static const LinearGradient decorGradient = LinearGradient(
    colors: [decorLight, decorVeryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}