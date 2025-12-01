import 'package:flutter/material.dart';

/// Color palette for Daily Pace app
/// Based on Indigo-600 design system matching the web app
class AppColors {
  AppColors._();

  // Primary Colors - Indigo-600
  static const Color primary = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF4338CA); // Indigo-700

  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate-100

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successLight = Color(0xFF34D399); // Emerald-400
  static const Color danger = Color(0xFFF43F5E); // Rose-500
  static const Color dangerLight = Color(0xFFFB7185); // Rose-400
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Border Colors
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate-100

  // Disabled Colors
  static const Color disabled = Color(0xFFCBD5E1); // Slate-300
  static const Color disabledText = Color(0xFF94A3B8); // Slate-400

  // Overlay Colors
  static const Color overlay = Color(0x66000000); // Black with 40% opacity
  static const Color overlayLight = Color(0x33000000); // Black with 20% opacity

  // Create ColorScheme for Material 3
  static ColorScheme get lightColorScheme => ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: textOnPrimary,
        primaryContainer: primaryLight,
        onPrimaryContainer: textPrimary,
        secondary: Color(0xFF6B7280), // Gray-500
        onSecondary: textOnPrimary,
        secondaryContainer: Color(0xFFE5E7EB), // Gray-200
        onSecondaryContainer: textPrimary,
        tertiary: Color(0xFF8B5CF6), // Violet-500
        onTertiary: textOnPrimary,
        tertiaryContainer: Color(0xFFEDE9FE), // Violet-100
        onTertiaryContainer: textPrimary,
        error: danger,
        onError: textOnPrimary,
        errorContainer: dangerLight,
        onErrorContainer: textPrimary,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: textSecondary,
        outline: border,
        outlineVariant: borderLight,
        shadow: Color(0xFF000000),
        scrim: overlay,
        inverseSurface: textPrimary,
        onInverseSurface: textOnPrimary,
        inversePrimary: primaryLight,
      );

  // Dark color scheme (for future use)
  static ColorScheme get darkColorScheme => ColorScheme(
        brightness: Brightness.dark,
        primary: primaryLight,
        onPrimary: Color(0xFF1E1B4B), // Indigo-950
        primaryContainer: primaryDark,
        onPrimaryContainer: Color(0xFFE0E7FF), // Indigo-100
        secondary: Color(0xFF9CA3AF), // Gray-400
        onSecondary: Color(0xFF1F2937), // Gray-800
        secondaryContainer: Color(0xFF374151), // Gray-700
        onSecondaryContainer: Color(0xFFF3F4F6), // Gray-100
        tertiary: Color(0xFFA78BFA), // Violet-400
        onTertiary: Color(0xFF4C1D95), // Violet-900
        tertiaryContainer: Color(0xFF6D28D9), // Violet-700
        onTertiaryContainer: Color(0xFFF5F3FF), // Violet-50
        error: dangerLight,
        onError: Color(0xFF881337), // Rose-900
        errorContainer: danger,
        onErrorContainer: Color(0xFFFFF1F2), // Rose-50
        surface: Color(0xFF0F172A), // Slate-900
        onSurface: Color(0xFFF8FAFC), // Slate-50
        surfaceContainerHighest: Color(0xFF1E293B), // Slate-800
        onSurfaceVariant: Color(0xFFCBD5E1), // Slate-300
        outline: Color(0xFF475569), // Slate-600
        outlineVariant: Color(0xFF334155), // Slate-700
        shadow: Color(0xFF000000),
        scrim: overlay,
        inverseSurface: Color(0xFFF8FAFC), // Slate-50
        onInverseSurface: Color(0xFF0F172A), // Slate-900
        inversePrimary: primary,
      );
}
