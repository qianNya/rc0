import 'package:flutter/material.dart';

/// Reserves space for the transparent status bar in edge-to-edge layouts.
class StatusBarSpacer extends StatelessWidget {
  const StatusBarSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.paddingOf(context).top);
  }
}

/// Reserves space for status bar + toolbar when [extendBodyBehindAppBar] is true.
class AppBarContentInset extends StatelessWidget {
  const AppBarContentInset({super.key, this.toolbarHeight});

  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final toolbar = toolbarHeight ?? kToolbarHeight;
    return SizedBox(height: top + toolbar);
  }
}
