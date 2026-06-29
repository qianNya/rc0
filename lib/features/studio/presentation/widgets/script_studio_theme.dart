import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Immersive Script Studio page palette (dark nebula + liquid glass).
abstract final class ScriptStudioColors {
  static const Color background = Color(0xFF07050F);
  static const Color nebulaDeep = Color(0xFF120A28);
  static const Color nebulaPurple = Color(0xFF3D1F6E);
  static const Color nebulaBlue = Color(0xFF1A3568);
  static const Color nebulaMagenta = Color(0xFF5C2D8A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textTertiary = Color(0x80FFFFFF);
  static const Color accentGlow = Color(0xFFA855F7);
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x40FFFFFF);

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
