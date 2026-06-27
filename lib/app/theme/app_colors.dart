import 'package:flutter/material.dart';

/// Design tokens — purple accent, light neutrals.
abstract final class AppColors {
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF5F5F5);
  static const Color accent = Color(0xFF6B4FE0);
  static const Color accentLight = Color(0xFFEEF0FF);
  static const Color accentDark = Color(0xFF5A3FD4);
  static const Color placeholder = Color(0xFFE8E8E8);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textTertiary = Color(0xFFB0B0B0);
  static const Color border = Color(0xFFEBEBEB);
  static const Color sidebarActive = Color(0xFFEEF0FF);
  static const Color error = Color(0xFFDC2626);
  static const Color badgeHot = Color(0xFFFF8C42);
  static const Color badgeNew = Color(0xFF34C759);
  static const Color badgeTemplate = Color(0xFF4A90D9);
  static const Color scrim = Color(0x8C000000);
  static const Color profileGradientStart = Color(0xFF3B9EFF);
  static const Color profileGradientEnd = Color(0xFF7B4FFF);

  // Dark theme tokens
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceSecondaryDark = Color(0xFF2A2A2A);

  // Character library cinematic surfaces (dark-first)
  static const Color characterBackgroundDark = Color(0xFF0F1115);
  static const Color characterCardDark = Color(0xFF171A21);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF757575);
  static const Color borderDark = Color(0xFF333333);
  static const Color placeholderDark = Color(0xFF2E2E2E);
  static const Color sidebarActiveDark = Color(0xFF2D2640);
  static const Color accentLightDark = Color(0xFF3D2F6B);

  // Liquid glass surfaces
  static const Color glassSurfaceLight = Color(0xB8FFFFFF);
  static const Color glassSurfaceDark = Color(0x661E1E1E);
  static const Color glassBorderLight = Color(0x40FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  /// Bottom navigation — more transparent, Apple-like liquid glass.
  static const Color glassNavSurfaceLight = Color(0x47F2F2F7);
  static const Color glassNavSurfaceDark = Color(0x382C2C2E);
  static const Color glassNavBorderLight = Color(0x66FFFFFF);
  static const Color glassNavBorderDark = Color(0x24FFFFFF);
  static const Color glassNavHighlightLight = Color(0x1FFFFFFF);
  static const Color glassNavHighlightDark = Color(0x14FFFFFF);
}
