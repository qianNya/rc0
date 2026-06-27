import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import 'app_brand_icon.dart';
import 'liquid_glass_surface.dart';
import 'shell_nav_items.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.wrapPadding = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool wrapPadding;

  @override
  Widget build(BuildContext context) {
    final bar = SafeArea(
      top: false,
      child: LiquidGlassSurface(
        style: LiquidGlassStyle.navigation,
        height: AppDimensions.bottomNavFloatingHeight,
        child: Row(
          children: [
            for (var i = 0; i < mobileNavItems.length; i++)
              Expanded(
                child: _NavItem(
                  item: mobileNavItems[i],
                  selected: selectedIndex == i,
                  onTap: () => onItemSelected(i),
                ),
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
      child: bar,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ShellNavItem item;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unselectedColor =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.floatingBarRadius),
      child: Tooltip(
        message: item.label,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1.0 : 0.0),
          duration: _duration,
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            final color = Color.lerp(unselectedColor, AppColors.accent, t)!;
            final scale = 1 + 0.12 * Curves.easeOutBack.transform(t);

            return SizedBox(
              height: AppDimensions.bottomNavFloatingHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: item.useBrandLogo
                        ? AppBrandIcon(
                            size: AppDimensions.bottomNavBrandIconSize,
                            selected: selected,
                          )
                        : AnimatedSwitcher(
                            duration: _duration,
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              selected ? item.selectedIcon : item.icon,
                              key: ValueKey<bool>(selected),
                              size: 22,
                              color: color,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
