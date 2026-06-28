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

  /// Bottom navigation — frosted glass; opaque enough for icon legibility.
  static const Color glassNavSurfaceLight = Color(0x72F2F2F7);
  static const Color glassNavSurfaceDark = Color(0x5A2C2C2E);
  static const Color glassNavBorderLight = Color(0x66FFFFFF);
  static const Color glassNavBorderDark = Color(0x30FFFFFF);
  static const Color glassNavHighlightLight = Color(0x1AFFFFFF);
  static const Color glassNavHighlightDark = Color(0x12FFFFFF);

  /// Bottom navigation icon colors (higher contrast than body text tokens).
  static const Color glassNavIconLight = Color(0xFF3A3A3A);
  static const Color glassNavIconSelectedLight = Color(0xFF5A3FD4);
  static const Color glassNavIconDark = Color(0xFFD0D0D0);
  static const Color glassNavIconSelectedDark = Color(0xFF9B8AF5);

  /// Water-drop selection pill inside bottom navigation.
  static const Color glassNavIndicatorLight = Color(0xE6FFFFFF);
  static const Color glassNavIndicatorDark = Color(0x884A4A4C);
  static const Color glassNavIndicatorBorderLight = Color(0x99FFFFFF);
  static const Color glassNavIndicatorBorderDark = Color(0x40FFFFFF);
  static const Color glassNavIndicatorSheenLight = Color(0x66FFFFFF);
  static const Color glassNavIndicatorSheenDark = Color(0x24FFFFFF);

  /// Glass highlight used by [GlassCard]/[GlassButton] top sheen.
  static const Color glassHighlightLight = Color(0x26FFFFFF);
  static const Color glassHighlightDark = Color(0x0FFFFFFF);

  // Elevation shadow tokens (replace inline Color(0x..) in AppShadows).
  static const Color shadowSoft = Color(0x0F000000);
  static const Color shadowFaint = Color(0x0A000000);
  static const Color shadowAmbient = Color(0x14000000);
  static const Color shadowStrong = Color(0x1A000000);
  static const Color shadowDrag = Color(0x22000000);
  static const Color shadowNavCast = Color(0x0A000000);
  static const Color shadowNavFaint = Color(0x06000000);
  static const Color scrimStrong = Color(0xCC000000);

  // Profile semantic accents (was hardcoded in profile pages).
  static const Color profileIcon = Color(0xFF7C4DFF);
  static const Color profileIconBg = Color(0xFFEDE7F6);
  static const Color membershipGradientStart = Color(0xFFFFF3E0);
  static const Color membershipGradientEnd = Color(0xFFFFE0B2);
  static const Color membershipIcon = Color(0xFFFF9800);

  // Category icon palette (foreground + tint) for menu / list entries.
  static const Color catPurple = Color(0xFF7C4DFF);
  static const Color catPurpleBg = Color(0xFFEDE7F6);
  static const Color catPink = Color(0xFFE91E63);
  static const Color catPinkBg = Color(0xFFFCE4EC);
  static const Color catBlue = Color(0xFF2196F3);
  static const Color catBlueBg = Color(0xFFE3F2FD);
  static const Color catGreen = Color(0xFF4CAF50);
  static const Color catGreenBg = Color(0xFFE8F5E9);
  static const Color catViolet = Color(0xFF9C27B0);
  static const Color catVioletBg = Color(0xFFF3E5F5);
  static const Color catOrange = Color(0xFFFF9800);
  static const Color catOrangeBg = Color(0xFFFFF3E0);

  // Explore placeholder cover gradient (was hardcoded in carousel).
  static const Color explorePlaceholderStart = Color(0xFF3B4A6B);
  static const Color explorePlaceholderEnd = Color(0xFF1A1F2E);

  // macOS desktop window controls (was hardcoded in desktop_title_bar).
  static const Color macWindowClose = Color(0xFFFF5F57);
  static const Color macWindowMinimize = Color(0xFFFEBC2E);
  static const Color macWindowZoom = Color(0xFF28C840);

  // Generic preset cover gradient fallbacks.
  static const Color presetCoverStart = Color(0xFF6B4FE0);
  static const Color presetCoverEnd = Color(0xFF3B2E80);
}
