import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../domain/media_vault_types.dart';
import 'media_vault_colors.dart';

class MediaVaultCategoryTabs extends StatelessWidget {
  const MediaVaultCategoryTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MediaVaultCategory selected;
  final ValueChanged<MediaVaultCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
        ),
        itemCount: MediaVaultCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = MediaVaultCategory.values[index];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isSelected
                    ? MediaVaultColors.accentGlow
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? MediaVaultColors.accent.withValues(alpha: 0.5)
                      : MediaVaultColors.border,
                ),
              ),
              child: Text(
                cat.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? MediaVaultColors.textPrimary
                      : MediaVaultColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
