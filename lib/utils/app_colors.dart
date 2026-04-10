import 'package:flutter/material.dart';

/// App-wide color constants
/// Defines the color scheme for the Queueless Queue application
class AppColors {
  // Gradient colors
  static const Color gradientStart = Color(0xFF4F46E5); // Indigo
  static const Color gradientEnd = Color(0xFF3B82F6); // Blue
  
  // Primary colors
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF3B82F6);
  
  // Background colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Colors.white;
  
  // Accent colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x26000000);
  
  /// Creates a linear gradient from indigo to blue
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
