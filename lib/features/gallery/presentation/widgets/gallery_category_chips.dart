import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';

class GalleryCategoryChips extends StatelessWidget {
  const GalleryCategoryChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final chipBackground = isDark
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          itemCount: labels.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: AppDimensions.spacingSm),
          itemBuilder: (context, index) {
            final selected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chipBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.accent : secondary,
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
