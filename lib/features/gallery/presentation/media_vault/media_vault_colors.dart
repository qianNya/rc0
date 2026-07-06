import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Light-tone media vault palette — maps to RC0 design tokens.
abstract final class MediaVaultColors {
  static const Color background = AppColors.pageBackground;
  static const Color surface = AppColors.surface;
  static const Color surfaceElevated = AppColors.surfaceSecondary;
  static const Color accent = AppColors.accent;
  static const Color accentGlow = AppColors.accentLight;
  static const Color highlightBlue = AppColors.catBlue;
  static const Color statusDanger = AppColors.error;
  static const Color statusSuccess = AppColors.badgeNew;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textTertiary = AppColors.textTertiary;
  static const Color border = AppColors.border;
  static const Color glassOverlay = AppColors.glassSurfaceLight;
  static const Color sidebarActive = AppColors.sidebarActive;
  static const Color starGold = Color(0xFFFFC857);
  static const Color shadowSoft = AppColors.shadowSoft;
}
