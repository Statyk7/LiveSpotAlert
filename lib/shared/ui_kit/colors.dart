import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF00BFA5);

  // Background colors
  static const Color background = Color(0xFFF8F9FA); // Very light gray
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light gray variant
  static const Color surfaceDark = Color(0xFF121212);
  
  // Dark mode backgrounds (for future dark mode support)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark2 = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Geofencing specific
  static const Color geofenceActive = Color(0xFF4CAF50);
  static const Color geofenceInactive = Color(0xFF9E9E9E);
  static const Color locationPin = Color(0xFFE91E63);
}
