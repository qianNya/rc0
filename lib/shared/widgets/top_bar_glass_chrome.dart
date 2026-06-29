import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import 'liquid_glass_surface.dart';

/// Shared floating glass chrome for top navigation bars.
class TopBarGlassChrome extends StatelessWidget {
  const TopBarGlassChrome({
    super.key,
    required this.child,
    this.breath = 0,
  });

  final Widget child;
  final double breath;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.topNavFloatingRadius);

    return LiquidGlassSurface(
      style: LiquidGlassStyle.navigation,
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                color: Colors.white.withValues(alpha: 0.04 + breath * 0.02),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16 + breath * 0.06),
                  width: 0.8,
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
