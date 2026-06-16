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
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          if (underlineStyle) {
            return GestureDetector(
              onTap: () => onChanged(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2,
                    width: 24,
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
                color: selected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
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
