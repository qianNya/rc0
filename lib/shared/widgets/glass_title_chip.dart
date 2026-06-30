import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// Title wrapping mode for top bar glass chips.
enum GlassTitleMode {
  /// Wrap only simple text titles (`Text` / `RichText`).
  auto,

  /// Always wrap title with [GlassTitleChip].
  force,

  /// Never wrap title with [GlassTitleChip].
  off,
}

/// Frosted glass title chip used by top bars.
class GlassTitleChip extends StatelessWidget {
  const GlassTitleChip({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingMd,
      vertical: AppDimensions.spacingSm,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  static bool _isSimpleTitle(Widget title) =>
      title is Text || title is RichText;

  static Widget? maybeWrap(
    Widget? title, {
    GlassTitleMode mode = GlassTitleMode.auto,
  }) {
    if (title == null) return null;
    if (title is GlassTitleChip) return title;
    return switch (mode) {
      GlassTitleMode.off => title,
      GlassTitleMode.force => GlassTitleChip(child: title),
      GlassTitleMode.auto =>
        _isSimpleTitle(title) ? GlassTitleChip(child: title) : title,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(999);
    final fill = isDark
        ? AppColors.glassSurfaceDark.withValues(alpha: 0.56)
        : AppColors.glassSurfaceLight.withValues(alpha: 0.86);
    final border = isDark
        ? AppColors.glassBorderDark.withValues(alpha: 0.9)
        : AppColors.glassBorderLight.withValues(alpha: 0.95);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassNavBlurSigma,
          sigmaY: AppDimensions.glassNavBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: border, width: 0.8),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
