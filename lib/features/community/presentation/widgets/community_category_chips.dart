import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';

class CommunityCategoryChips extends StatelessWidget {
  const CommunityCategoryChips({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = AppCatalog.communityCategoryChips;
    final secondary = theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceSecondary = theme.brightness == Brightness.dark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondary;

    return Material(
      color: theme.scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chips[index],
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
