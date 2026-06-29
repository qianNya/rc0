import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/data/app_catalog.dart';
import 'liquid_glass_surface.dart';

class FeedTabBar extends StatelessWidget {
  const FeedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.underlineStyle = false,
    this.embedded = false,
    this.margin,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool underlineStyle;

  /// When true, renders tabs without an outer [LiquidGlassSurface] wrapper.
  final bool embedded;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceSecondary = isDark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondary;
    final border = isDark
        ? Colors.transparent
        : theme.dividerColor;

    final tabList = _buildTabList(
      secondary: secondary,
      surfaceSecondary: surfaceSecondary,
      border: border,
    );

    final barHeight = underlineStyle
        ? AppDimensions.primaryButtonHeight
        : AppDimensions.feedTabBarHeight;

    if (embedded) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: SizedBox(height: barHeight, child: tabList),
      );
    }

    return LiquidGlassSurface(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppDimensions.floatingBarMarginHorizontal,
          ),
      height: barHeight,
      child: tabList,
    );
  }

  Widget _buildTabList({
    required Color secondary,
    required Color surfaceSecondary,
    required Color border,
  }) {
    return ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
        ),
        itemCount: tabs.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          if (underlineStyle) {
            return GestureDetector(
              onTap: () => onChanged(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.accent : secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2,
                    width: selected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            );
          }
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent
                    : surfaceSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? Border.all(color: AppColors.accent)
                    : Border.all(color: border),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : secondary,
                ),
              ),
            ),
          );
        },
      );
  }
}

/// Pinned [FeedTabBar] for [CustomScrollView] / [NestedScrollView] headers.
class PinnedFeedTabBarDelegate extends SliverPersistentHeaderDelegate {
  PinnedFeedTabBarDelegate({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    required this.backgroundColor,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color backgroundColor;

  @override
  double get minExtent => AppDimensions.primaryButtonHeight;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: FeedTabBar(
        tabs: tabs,
        selectedIndex: selectedIndex,
        onChanged: onChanged,
        underlineStyle: true,
        embedded: true,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant PinnedFeedTabBarDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.tabs != tabs ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Default feed tabs from catalog.
class DefaultFeedTabBar extends StatelessWidget {
  const DefaultFeedTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.underlineStyle = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool underlineStyle;

  @override
  Widget build(BuildContext context) {
    return FeedTabBar(
      tabs: AppCatalog.feedTabs,
      selectedIndex: selectedIndex,
      onChanged: onChanged,
      underlineStyle: underlineStyle,
    );
  }
}
