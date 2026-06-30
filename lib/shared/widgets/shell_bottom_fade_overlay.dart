import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/responsive/breakpoints.dart';

/// Frosted fade from the shell tab bar midline down to the screen bottom.
///
/// Sits above scrollable shell content (see [AdaptiveShellPage]) and does not
/// intercept pointer events.
class ShellBottomFadeOverlay extends StatelessWidget {
  const ShellBottomFadeOverlay({super.key});

  /// Height from just below the tab bar center to the physical screen bottom.
  static double heightOf(BuildContext context) {
    if (!Breakpoints.showsShellBottomBar(context)) return 0;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return safeBottom +
        AppDimensions.floatingBarMarginBottom +
        AppDimensions.bottomNavFloatingHeight * 0.35;
  }

  @override
  Widget build(BuildContext context) {
    final height = heightOf(context);
    if (height <= 0) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(
        child: ClipRect(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.55, 1],
                colors: [
                  Color(0x00000000),
                  Color(0x99000000),
                  Color(0xFF000000),
                ],
              ).createShader(bounds);
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.glassNavBlurSigma,
                sigmaY: AppDimensions.glassNavBlurSigma,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
