import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// App launcher / branding mark used in nav and create entry points.
class AppBrandIcon extends StatelessWidget {
  const AppBrandIcon({
    super.key,
    this.size = 28,
    this.selected = false,
    this.borderRadius = 10,
  });

  static const assetPath = 'assets/branding/app_logo.png';

  final double size;
  final bool selected;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final displaySize = selected ? size + 2 : size;
    final borderColor =
        selected ? AppColors.accent : Colors.transparent;
    final background = selected
        ? AppColors.accentLight
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: displaySize + 8,
      height: displaySize + 8,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: selected ? 1.5 : 0),
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Image.asset(
          assetPath,
          width: displaySize,
          height: displaySize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
