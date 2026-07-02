import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/content_card_shared.dart';
import 'breakpoints.dart';

/// Responsive feed grid: phone 3 cols, tablet 4 cols, wider screens grow elastically.
abstract final class FeedGridLayout {
  static const double maxContentWidth = 1280;
  static const double horizontalPadding = 16;
  static const double spacing = 12;
  static const double minTileWidth = 104;

  /// Width used for column math after applying [maxContentWidth].
  static double layoutWidth(double width) =>
      math.min(width, maxContentWidth);

  /// Usable track width inside horizontal padding.
  static double contentWidthFor(double width) {
    final capped = layoutWidth(width);
    return math.max(0, capped - horizontalPadding * 2);
  }

  static int columnsForWidth(double width) {
    if (width < Breakpoints.compact) return 3;
    if (width < Breakpoints.medium) return 4;

    final usable = contentWidthFor(width);
    final cols =
        ((usable + spacing) / (minTileWidth + spacing)).floor();
    return cols.clamp(4, 8);
  }

  static int columnsFor(BuildContext context) =>
      columnsForWidth(MediaQuery.sizeOf(context).width);

  static EdgeInsets padding({double top = 8, double bottom = 0}) =>
      EdgeInsets.fromLTRB(horizontalPadding, top, horizontalPadding, bottom);

  static SliverGridDelegate sliverDelegate(
    double width, {
    double? childAspectRatio,
    double? gridSpacing,
  }) {
    final columns = columnsForWidth(width);
    final gap = gridSpacing ?? spacing;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: gap,
      crossAxisSpacing: gap,
      childAspectRatio:
          childAspectRatio ?? feedGridChildAspectRatio(columns),
    );
  }

  static SliverGridDelegateWithFixedCrossAxisCount boxDelegate(
    double width, {
    double? childAspectRatio,
    double? gridSpacing,
  }) {
    final columns = columnsForWidth(width);
    final gap = gridSpacing ?? spacing;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: gap,
      crossAxisSpacing: gap,
      childAspectRatio:
          childAspectRatio ?? feedGridChildAspectRatio(columns),
    );
  }
}

/// Centers feed content and caps width on large screens.
class FeedGridScope extends StatelessWidget {
  const FeedGridScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: FeedGridLayout.maxContentWidth),
        child: child,
      ),
    );
  }
}
