import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_text_styles.dart';
import 'liquid_glass_surface.dart';
import 'liquid_tab_indicator.dart';
import 'shell_nav_items.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.items = const [],
    this.wrapPadding = true,
    this.onItemLongPress,
    this.onBarLongPress,
  });

  /// Selected slot in [items], or `-1` when no primary tab is active.
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<ShellNavItem> items;
  final bool wrapPadding;
  final ValueChanged<int>? onItemLongPress;
  final VoidCallback? onBarLongPress;

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    final showIndicator = selectedIndex >= 0 && selectedIndex < count;

    final bar = GestureDetector(
      onLongPress: onBarLongPress,
      behavior: HitTestBehavior.translucent,
      child: LiquidGlassSurface(
        style: LiquidGlassStyle.navigation,
        height: AppDimensions.bottomNavFloatingHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showIndicator)
              LiquidTabIndicator(
                selectedIndex: selectedIndex,
                itemCount: count,
              ),
            Row(
              children: [
                for (var i = 0; i < count; i++)
                  Expanded(
                    child: _NavSlot(
                      item: items[i],
                      selected: selectedIndex == i,
                      onTap: () => onItemSelected(i),
                      onLongPress: onItemLongPress == null
                          ? null
                          : () => onItemLongPress!(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!wrapPadding) return bar;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.floatingBarMarginHorizontal,
        0,
        AppDimensions.floatingBarMarginHorizontal,
        AppDimensions.floatingBarMarginBottom,
      ),
      child: SafeArea(
        top: false,
        child: bar,
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final ShellNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor =
        isDark ? AppColors.glassNavIconDark : AppColors.glassNavIconLight;
    final selectedColor = isDark
        ? AppColors.glassNavIconSelectedDark
        : AppColors.glassNavIconSelectedLight;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1.0 : 0.0),
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        builder: (context, t, _) {
          final color = Color.lerp(unselectedColor, selectedColor, t)!;

          return SizedBox(
            height: AppDimensions.bottomNavFloatingHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 22,
                  color: color,
                ),
                if (!item.hideLabel) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
