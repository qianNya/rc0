import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/responsive/breakpoints.dart';

/// Provides bottom clearance for the mobile floating shell tab bar.
///
/// Injected by [AdaptiveShellPage] on mobile. Returns `0` on desktop and for
/// full-screen stack routes outside the shell.
class ShellInsets extends InheritedWidget {
  const ShellInsets({
    super.key,
    required this.bottomClearance,
    required super.child,
  });

  final double bottomClearance;

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ShellInsets>()
            ?.bottomClearance ??
        0;
  }

  /// Bottom padding for scrollable shell content (tab bar + home indicator).
  static double scrollBottom(BuildContext context, {double extra = 0}) {
    return of(context) + extra;
  }

  /// Computes clearance from design tokens + device safe area.
  static double mobileTabBarClearance(BuildContext context) {
    if (!Breakpoints.showsShellBottomBar(context)) return 0;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return safeBottom +
        AppDimensions.floatingBarMarginBottom +
        AppDimensions.bottomNavFloatingHeight +
        AppDimensions.spacingSm;
  }

  @override
  bool updateShouldNotify(ShellInsets oldWidget) {
    return bottomClearance != oldWidget.bottomClearance;
  }
}

/// Trailing spacer for shell tab scroll views / list children.
class ShellBottomSpacer extends StatelessWidget {
  const ShellBottomSpacer({super.key, this.extra = 0});

  final double extra;

  @override
  Widget build(BuildContext context) {
    final height = ShellInsets.scrollBottom(context, extra: extra);
    if (height <= 0) return const SizedBox.shrink();
    return SizedBox(height: height);
  }
}
