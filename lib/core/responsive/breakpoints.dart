import 'package:flutter/material.dart';

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

  static int gridColumns(BuildContext context, {int mobile = 2, int desktop = 3}) =>
      isDesktop(context) ? desktop : mobile;
}
