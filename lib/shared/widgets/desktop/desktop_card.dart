import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import 'desktop_chrome.dart';

class DesktopCard extends StatelessWidget {
  const DesktopCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.clipChild = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final bool clipChild;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusLg);

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (clipChild) {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    return Container(
      width: width,
      decoration: DesktopChrome.decoration(),
      child: content,
    );
  }
}
