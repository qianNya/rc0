import 'package:flutter/material.dart';

import 'feed_grid_layout.dart';

/// Layout breakpoints aligned with Material adaptive guidelines.
abstract final class Breakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1024;
  static const double large = 1280;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) =>
      widthOf(context) < compact;

  static bool isMobile(BuildContext context) =>
      widthOf(context) < expanded;

  static bool isDesktop(BuildContext context) =>
      widthOf(context) >= expanded;

  /// Tablet / wide layout: permanent sidebar instead of bottom tab bar.
  static bool useSidebarShell(BuildContext context) =>
      widthOf(context) >= medium;

  /// Floating bottom tab bar (phones and narrow tablet windows).
  static bool showsShellBottomBar(BuildContext context) =>
      !useSidebarShell(context);

  /// Wide enough to center-constrain the floating bottom bar.
  static bool useConstrainedBottomBar(BuildContext context) =>
      widthOf(context) >= compact;

  static int gridColumns(BuildContext context, {int mobile = 2, int desktop = 3}) =>
      FeedGridLayout.columnsFor(context);
}
