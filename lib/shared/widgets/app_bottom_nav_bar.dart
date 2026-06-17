import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../features/shell/presentation/widgets/desktop_sidebar.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onCreateTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onCreateTap;

  static const int createNavIndex = 2;

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
                  if (i == createNavIndex)
                    Expanded(child: _CreateNavButton(onTap: onCreateTap))
                  else
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? item.selectedIcon : item.icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateNavButton extends StatelessWidget {
  const _CreateNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
