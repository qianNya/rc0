import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Light Script Studio palette aligned with the app theme.
abstract final class ScriptStudioColors {
  static const Color background = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textTertiary = AppColors.textTertiary;
  static const Color accentGlow = AppColors.accent;
  static const Color glassFill = Color(0xD9FFFFFF);
  static const Color glassBorder = AppColors.border;
  static const Color glassHighlight = AppColors.glassHighlightLight;
  static const Color iconSurface = AppColors.accentLight;
  static const Color iconForeground = AppColors.accent;

  static const TextStyle title = TextStyle(
    color: textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle cardTitle = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle cardSubtitle = TextStyle(
    color: textSecondary,
    fontSize: 12,
    height: 1.35,
  );

  static const TextStyle sectionAction = TextStyle(
    color: AppColors.accent,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
