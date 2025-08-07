import 'package:flutter/material.dart';

/// Centralized spacing constants for consistent layout throughout the app
class AppSpacing {
  // Base spacing scale (reduced for tighter layout)
  static const double micro = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 20.0;
  static const double xxlarge = 24.0;

  // Semantic EdgeInsets for common use cases
  
  // Screen-level spacing
  static const EdgeInsets screenPadding = EdgeInsets.all(medium);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: medium);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: medium);
  
  // Card spacing
  static const EdgeInsets cardPadding = EdgeInsets.all(medium);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(small);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(large);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: medium, vertical: small);
  static const EdgeInsets cardMarginSmall = EdgeInsets.symmetric(horizontal: small, vertical: micro);
  
  // Button spacing
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: large, vertical: medium);
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(horizontal: medium, vertical: small);
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(horizontal: xlarge, vertical: large);
  
  // Input field spacing
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: medium, vertical: medium);
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(horizontal: medium, vertical: medium);
  
  // List and tile spacing
  static const EdgeInsets listPadding = EdgeInsets.all(medium);
  static const EdgeInsets tilePadding = EdgeInsets.symmetric(horizontal: large, vertical: small);
  
  // Section spacing (vertical gaps between major sections)
  static const double sectionSpacing = large;
  static const double sectionSpacingSmall = medium;
  static const double sectionSpacingLarge = xlarge;
  
  // Common SizedBox widgets for convenience
  static const SizedBox verticalSpaceSmall = SizedBox(height: small);
  static const SizedBox verticalSpaceMedium = SizedBox(height: medium);
  static const SizedBox verticalSpaceLarge = SizedBox(height: large);
  static const SizedBox verticalSpaceSection = SizedBox(height: sectionSpacing);
  
  static const SizedBox horizontalSpaceSmall = SizedBox(width: small);
  static const SizedBox horizontalSpaceMedium = SizedBox(width: medium);
  static const SizedBox horizontalSpaceLarge = SizedBox(width: large);
  
  // Border radius (while we're standardizing spacing)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // Elevation values
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
}