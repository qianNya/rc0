import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../liquid_glass_surface.dart';

/// A frosted liquid-glass card surface with an optional tap target.
///
/// Built on [LiquidGlassSurface] so blur, border, shadow and highlight stay
/// consistent across the app. Prefer this over hand-rolled
/// `Container + BoxDecoration + BackdropFilter` cards.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppDimensions.spacingMd),
    this.margin,
    this.borderRadius,
    this.selected = false,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool selected;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusLg);

    Widget content = child;
    if (onTap != null || onLongPress != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return LiquidGlassSurface(
      borderRadius: radius,
      margin: margin,
      width: width,
      height: height,
      child: Stack(
        children: [
          if (selected)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
              ),
            ),
          Padding(padding: padding, child: content),
        ],
      ),
    );
  }
}
