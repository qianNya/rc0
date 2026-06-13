import 'package:flutter/material.dart';

import 'breakpoints.dart';

typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  bool isDesktop,
);

/// Renders [mobile] or [desktop] based on screen width.
/// Use one feature page that delegates layout — shared business logic stays unified.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= Breakpoints.expanded;
        return isDesktop ? desktop(context) : mobile(context);
      },
    );
  }
}

/// Constrains content width on large screens while keeping full-bleed shell.
class AdaptiveContent extends StatelessWidget {
  const AdaptiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
