import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';

class CharacterCategoryChips extends StatelessWidget {
  const CharacterCategoryChips({
    super.key,
    required this.chips,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> chips;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const double chipBarHeight = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceSecondary = theme.brightness == Brightness.dark
        ? AppColors.characterCardDark
        : AppColors.surfaceSecondary;

    return SizedBox(
      height: chipBarHeight,
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
    );
  }
}
