import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import 'liquid_glass_surface.dart';

/// Shared floating glass chrome for all bottom bars.
class BottomBarGlassChrome extends StatelessWidget {
  const BottomBarGlassChrome({
    super.key,
    required this.child,
    this.height = AppDimensions.bottomNavFloatingHeight,
    this.width,
    this.breath = 0,
  });

  final Widget child;
  final double height;
  final double? width;
  final double breath;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.bottomNavFloatingRadius);

    return LiquidGlassSurface(
      style: LiquidGlassStyle.navigation,
      height: height,
      width: width,
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                color: Colors.white.withValues(alpha: 0.02),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1 + breath * 0.04),
                  width: 0.7,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
