import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App-wide text styles and theme configurations
class AppStyles {
  // Heading styles
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
  
  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
  
  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
  
  // Body text styles
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );
  
  // Button text style
  static TextStyle get buttonText => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      );
  
  // Light text styles (for dark backgrounds)
  static TextStyle get headingLight => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      );
  
  static TextStyle get subtitleLight => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textLight.withOpacity(0.9),
      );
  
  // Border radius constants
  static const double radiusSmall = 16.0;
  static const double radiusMedium = 24.0;
  static const double radiusLarge = 32.0;
  static const double radiusXLarge = 40.0;
  
  // Spacing constants
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;
  
  // Premium multi-layer shadows for depth
  static BoxShadow get cardShadow => BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 20,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      );
  
  static List<BoxShadow> get cardShadowHover => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 30,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 40,
          offset: const Offset(0, 16),
          spreadRadius: -8,
        ),
      ];
  
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: AppColors.shadow.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];
  
  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.primary.withOpacity(0.15),
          blurRadius: 40,
          offset: const Offset(0, 16),
          spreadRadius: -8,
        ),
      ];
  
  // Additional premium shadows
  static List<BoxShadow> get headerShadow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.2),
          blurRadius: 32,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: AppColors.primary.withOpacity(0.1),
          blurRadius: 48,
          offset: const Offset(0, 20),
          spreadRadius: -8,
        ),
      ];
  
  static List<BoxShadow> get iconShadow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];
}
