import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/data/app_catalog.dart';

class FeedTabBar extends StatelessWidget {
  const FeedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.underlineStyle = false,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool underlineStyle;

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

    return Material(
      color: theme.scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        height: AppDimensions.shellBarHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.hardEdge,
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
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
                  children: [
                    Text(
                      tabs[index],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : surfaceSecondary,
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
        ),
      ),
    );
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
