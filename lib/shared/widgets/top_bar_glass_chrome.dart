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
    final radius = BorderRadius.circular(AppDimensions.tabFloatingRadius);
    final highlight = 0.12 + breath * 0.04;
    final tail = 0.02 + breath * 0.02;

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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: highlight),
                    Colors.white.withValues(alpha: tail),
                  ],
                  stops: const [0, 0.75],
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
