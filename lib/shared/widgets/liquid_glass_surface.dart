import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';

enum LiquidGlassStyle {
  standard,
  navigation,
}

class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.style = LiquidGlassStyle.standard,
    this.borderRadius,
    this.padding,
    this.margin,
    this.height,
    this.width,
  });

  final Widget child;
  final LiquidGlassStyle style;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ??
        BorderRadius.circular(AppDimensions.floatingBarRadius);
    final isNav = style == LiquidGlassStyle.navigation;

    final surfaceColor = isNav
        ? (isDark ? AppColors.glassNavSurfaceDark : AppColors.glassNavSurfaceLight)
        : (isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight);
    final borderColor = isNav
        ? (isDark ? AppColors.glassNavBorderDark : AppColors.glassNavBorderLight)
        : (isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight);
    final blurSigma =
        isNav ? AppDimensions.glassNavBlurSigma : AppDimensions.glassBlurSigma;
    final shadows = isNav ? AppShadows.floatingBarNav : AppShadows.floatingBar;
    final highlight = isNav
        ? (isDark
            ? AppColors.glassNavHighlightDark
            : AppColors.glassNavHighlightLight)
        : null;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: radius,
              border: Border.all(
                color: borderColor,
                width: isNav ? 0.5 : 1,
              ),
              boxShadow: shadows,
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                if (highlight != null)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            highlight,
                            highlight.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.55],
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: height,
                  width: width,
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
