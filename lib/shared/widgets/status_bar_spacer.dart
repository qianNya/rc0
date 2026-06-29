import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

/// Reserves space for the transparent status bar in edge-to-edge layouts.
class StatusBarSpacer extends StatelessWidget {
  const StatusBarSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).top);
  }
}

/// Height below the top edge for floating [Rc0AppBar] glass chrome.
double floatingAppBarContentInsetHeight(
  BuildContext context, {
  double? toolbarHeight,
}) {
  final top = MediaQuery.paddingOf(context).top;
  final toolbar = toolbarHeight ?? AppDimensions.bottomNavFloatingHeight;
  return top + toolbar;
}

/// Reserves space for status bar + toolbar when [extendBodyBehindAppBar] is true.
class AppBarContentInset extends StatelessWidget {
  const AppBarContentInset({super.key, this.toolbarHeight});

  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: floatingAppBarContentInsetHeight(
        context,
        toolbarHeight: toolbarHeight,
      ),
    );
  }
}
