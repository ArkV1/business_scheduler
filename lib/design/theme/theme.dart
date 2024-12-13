import 'package:flutter/material.dart';
import 'package:mix/mix.dart' hide $token;

import '../tokens/tokens.dart';

class AppTheme {
  static final _baseTextStyles = {
    $token.textStyle.displayLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    $token.textStyle.displayMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    $token.textStyle.displaySmall: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    $token.textStyle.headlineLarge: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    $token.textStyle.headlineMedium: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    $token.textStyle.headlineSmall: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    $token.textStyle.titleLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    $token.textStyle.titleMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    $token.textStyle.titleSmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    $token.textStyle.bodyLarge: const TextStyle(
      fontSize: 16,
      height: 1.5,
    ),
    $token.textStyle.bodyMedium: const TextStyle(
      fontSize: 14,
      height: 1.5,
    ),
    $token.textStyle.bodySmall: const TextStyle(
      fontSize: 12,
      height: 1.5,
    ),
    $token.textStyle.labelLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    $token.textStyle.labelMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    $token.textStyle.labelSmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  };

  static final _baseSpacing = {
    $token.spacing.small: 8.0,
    $token.spacing.medium: 16.0,
    $token.spacing.large: 24.0,
  };

  static final _baseRadii = {
    $token.radius.small: const Radius.circular(4),
    $token.radius.medium: const Radius.circular(8),
    $token.radius.large: const Radius.circular(12),
  };

  // Light Theme Colors
  static final _lightColors = {
    $token.color.primary: const Color(0xFF2563EB),
    $token.color.onPrimary: Colors.white,
    $token.color.surface: Colors.white,
    $token.color.onSurface: const Color(0xFF1F2937),
    $token.color.background: const Color(0xFFF3F4F6),
    $token.color.card: Colors.white,
    $token.color.border: const Color(0xFFE5E7EB),
  };

  // Dark Theme Colors
  static final _darkColors = {
    $token.color.primary: const Color(0xFF3B82F6),
    $token.color.onPrimary: Colors.white,
    $token.color.surface: const Color(0xFF1F2937),
    $token.color.onSurface: Colors.white,
    $token.color.background: const Color(0xFF111827),
    $token.color.card: const Color(0xFF1F2937),
    $token.color.border: const Color(0xFF374151),
  };

  // Light Theme
  static final light = MixThemeData.withMaterial(
    colors: _lightColors,
    textStyles: _baseTextStyles,
    spaces: _baseSpacing,
    radii: _baseRadii,
  );

  // Dark Theme
  static final dark = MixThemeData.withMaterial(
    colors: _darkColors,
    textStyles: _baseTextStyles,
    spaces: _baseSpacing,
    radii: _baseRadii,
  );
}