import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import 'app_brand_icon.dart';
import 'shell_nav_items.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? theme.scaffoldBackgroundColor
        : theme.colorScheme.surface;
    final topBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : theme.dividerColor;

    return Material(
      color: background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border(
            top: BorderSide(
              color: topBorderColor,
              width: isDark ? 0 : 1,
            ),
          ),
          boxShadow: isDark ? null : AppShadows.bottomNav,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppDimensions.bottomNavHeight,
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
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? AppColors.accent
        : theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Tooltip(
        message: item.label,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.useBrandLogo)
              AppBrandIcon(
                size: AppDimensions.bottomNavBrandIconSize,
                selected: selected,
              )
            else
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}
