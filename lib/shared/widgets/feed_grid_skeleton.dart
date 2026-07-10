import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_motion.dart';
import '../../core/responsive/feed_grid_layout.dart';

/// Pulsing gradient placeholder grid shown while the first feed page loads.
///
/// Mirrors [FeedGridLayout] so the skeleton frame matches the final grid —
/// per UX guidelines list loading uses gradient placeholders, not a spinner.
class FeedGridSkeleton extends StatefulWidget {
  const FeedGridSkeleton({
    super.key,
    this.tileCount = 9,
    this.sliver = false,
  });

  final int tileCount;

  /// When true, builds sliver grid for use inside a [CustomScrollView].
  final bool sliver;

  @override
  State<FeedGridSkeleton> createState() => _FeedGridSkeletonState();
}

class _FeedGridSkeletonState extends State<FeedGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow * 3,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTile(Color start, Color end) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.smooth),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [start, end],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final start = AppColors.explorePlaceholderStart
        .withValues(alpha: isDark ? 0.55 : 0.12);
    final end = AppColors.explorePlaceholderEnd
        .withValues(alpha: isDark ? 0.55 : 0.06);

    if (widget.sliver) {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          final gridWidth = FeedGridLayout.layoutWidth(
            constraints.crossAxisExtent,
          );
          return SliverGrid(
            gridDelegate: FeedGridLayout.sliverDelegate(gridWidth),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTile(start, end),
              childCount: widget.tileCount,
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: FeedGridLayout.padding(),
          gridDelegate: FeedGridLayout.boxDelegate(constraints.maxWidth),
          itemCount: widget.tileCount,
          itemBuilder: (context, index) => _buildTile(start, end),
        );
      },
    );
  }
}
