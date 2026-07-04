import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
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
    this.bareTrack = false,
    this.margin,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool underlineStyle;

  /// When true, renders tabs without an outer [LiquidGlassSurface] wrapper.
  final bool embedded;

  /// When true with [embedded], omits the glass track behind tab chips.
  final bool bareTrack;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final selectedTextColor =
        isDark ? AppColors.glassNavIconSelectedDark : AppColors.accent;
    final unselectedFill = isDark
        ? AppColors.glassNavSurfaceDark.withValues(alpha: 0.45)
        : AppColors.glassNavSurfaceLight.withValues(alpha: 0.45);
    final selectedFill = isDark
        ? AppColors.glassNavIndicatorDark.withValues(alpha: 0.9)
        : AppColors.glassNavIndicatorLight.withValues(alpha: 0.95);
    final chipBorder = isDark
        ? AppColors.glassNavBorderDark
        : AppColors.glassNavBorderLight;

    final tabList = _buildTabList(
      textColor: textColor,
      selectedTextColor: selectedTextColor,
      unselectedFill: unselectedFill,
      selectedFill: selectedFill,
      border: chipBorder,
    );

    final barHeight = underlineStyle
        ? AppDimensions.tabFloatingHeight
        : AppDimensions.feedTabBarHeight;

    if (embedded) {
      final trackChild = bareTrack ? tabList : _buildGlassTrack(tabList);
      return SizedBox(
        height: barHeight,
        child: Padding(
          padding: margin ?? EdgeInsets.zero,
          child: trackChild,
        ),
      );
    }

    return LiquidGlassSurface(
      style: LiquidGlassStyle.navigation,
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppDimensions.floatingBarMarginHorizontal,
          ),
      borderRadius: BorderRadius.circular(AppDimensions.tabFloatingRadius),
      height: barHeight,
      child: _buildGlassTrack(tabList),
    );
  }

  Widget _buildGlassTrack(Widget child) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.tabFloatingRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.02),
                ],
                stops: const [0, 0.75],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildTabList({
    required Color textColor,
    required Color selectedTextColor,
    required Color unselectedFill,
    required Color selectedFill,
    required Color border,
  }) {
    final listPadding = bareTrack && embedded
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          );
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      padding: listPadding,
      itemCount: tabs.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final selected = selectedIndex == index;
        return _LiquidTabChip(
          label: tabs[index],
          selected: selected,
          underlineStyle: underlineStyle,
          textColor: textColor,
          selectedTextColor: selectedTextColor,
          unselectedFill: unselectedFill,
          selectedFill: selectedFill,
          border: border,
          onTap: () => onChanged(index),
        );
      },
    );
  }
}

class _LiquidTabChip extends StatelessWidget {
  const _LiquidTabChip({
    required this.label,
    required this.selected,
    required this.underlineStyle,
    required this.textColor,
    required this.selectedTextColor,
    required this.unselectedFill,
    required this.selectedFill,
    required this.border,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool underlineStyle;
  final Color textColor;
  final Color selectedTextColor;
  final Color unselectedFill;
  final Color selectedFill;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.tabFloatingRadius);
    final glow = selected
        ? [
            ...AppShadows.floatingBarNav,
            BoxShadow(
              color: selectedTextColor.withValues(alpha: 0.22),
              blurRadius: 18,
              spreadRadius: -6,
              offset: const Offset(0, 3),
            ),
          ]
        : AppShadows.floatingBarNav;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: AppMotion.normal,
      curve: AppMotion.liquidTab,
      builder: (context, t, _) {
        final refractionHighlight = Color.lerp(
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.22),
          t,
        )!;
        final edgeAlpha = Color.lerp(
          border.withValues(alpha: 0.65),
          selectedTextColor.withValues(alpha: 0.5),
          t,
        )!;
        final sheenAlignment = Alignment.lerp(
          const Alignment(-0.9, -0.55),
          const Alignment(0.9, -0.15),
          t,
        )!;

        return AnimatedScale(
          duration: AppMotion.fast,
          curve: AppMotion.liquidTab,
          scale: selected ? 1.0 : 0.975,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.standard,
                padding: EdgeInsets.symmetric(
                  horizontal: underlineStyle
                      ? AppDimensions.spacingLg
                      : AppDimensions.spacingMd,
                  vertical: underlineStyle
                      ? AppDimensions.spacingSm + 2
                      : AppDimensions.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: Color.lerp(unselectedFill, selectedFill, t),
                  borderRadius: radius,
                  border: Border.all(color: edgeAlpha, width: selected ? 1.1 : 0.8),
                  boxShadow: glow,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            gradient: RadialGradient(
                              center: sheenAlignment,
                              radius: 1.0,
                              colors: [
                                refractionHighlight,
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [0, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 1,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                selectedTextColor.withValues(alpha: 0.12 * t),
                              ],
                            ),
                          ),
                          child: const SizedBox(height: 6),
                        ),
                      ),
                    ),
                    AnimatedDefaultTextStyle(
                      duration: AppMotion.fast,
                      curve: AppMotion.standard,
                      style: AppTextStyles.label.copyWith(
                        fontSize: underlineStyle ? 14 : 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: Color.lerp(textColor, selectedTextColor, t),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
  double get minExtent => AppDimensions.tabFloatingHeight;

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
