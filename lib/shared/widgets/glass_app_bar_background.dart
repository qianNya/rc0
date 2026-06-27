import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// Full-width frosted glass backdrop for [AppBar.flexibleSpace].
class GlassAppBarBackground extends StatelessWidget {
  const GlassAppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight;
    final borderColor =
        isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassBlurSigma,
          sigmaY: AppDimensions.glassBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
