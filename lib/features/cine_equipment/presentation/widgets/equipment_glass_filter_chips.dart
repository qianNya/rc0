import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';

/// Horizontal glass filter chips for equipment category / brand rows.
class EquipmentGlassFilterChips extends StatelessWidget {
  const EquipmentGlassFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.padding,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        padding: padding ?? EdgeInsets.zero,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return _GlassFilterChip(
            label: labels[index],
            selected: selected,
            unselectedColor: unselectedColor,
            onTap: () => onChanged(index),
          );
        },
      ),
    );
  }
}

class _GlassFilterChip extends StatelessWidget {
  const _GlassFilterChip({
    required this.label,
    required this.selected,
    required this.unselectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.smooth,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : null,
          borderRadius: radius,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: selected
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            : LiquidGlassSurface(
                borderRadius: radius,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: unselectedColor,
                  ),
                ),
              ),
      ),
    );
  }
}
