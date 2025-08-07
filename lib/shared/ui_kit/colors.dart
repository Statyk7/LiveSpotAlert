import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary colors (Complementary grays)
  static const Color secondary = Color(0xFF757575);
  static const Color secondaryDark = Color(0xFF424242);

  // Background colors
  static const Color background = Color(0xFFFAFAFA); // Very light gray for clean background
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light gray variant
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Pure white for elevated surfaces
  
  // Dark mode backgrounds (for future dark mode support)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text colors (Enhanced hierarchy)
  static const Color textPrimary = Color(0xFF212121);    // Dark gray for primary text
  static const Color textSecondary = Color(0xFF757575);  // Medium gray for secondary text
  static const Color textTertiary = Color(0xFF9E9E9E);   // Light gray for tertiary text
  static const Color textHint = Color(0xFFBDBDBD);       // Very light gray for hints

  // Border and divider colors
  static const Color border = Color(0xFFE0E0E0);         // Light border color
  static const Color borderFocus = Color(0xFF1976D2);    // Red border for focused elements
  static const Color divider = Color(0xFFEEEEEE);        // Very subtle dividers

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);          // Match primary for consistency
  static const Color info = Color(0xFF2196F3);

  // Geofencing specific
  static const Color geofenceActive = Color(0xFF4CAF50);
  static const Color geofenceInactive = Color(0xFF9E9E9E);
  static const Color locationPin = Color(0xFFE91E63);
}
