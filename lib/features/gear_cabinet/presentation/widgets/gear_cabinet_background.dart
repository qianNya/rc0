import 'package:flutter/material.dart';

import '../theme/gear_cabinet_colors.dart';

/// Cinematic studio backdrop with soft spotlight vignette.
class GearCabinetBackground extends StatelessWidget {
  const GearCabinetBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 1.4,
          colors: [
            Color(0xFF141A24),
            GearCabinetColors.background,
            Color(0xFF06080C),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: MediaQuery.sizeOf(context).width * 0.2,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GearCabinetColors.accent.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
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
