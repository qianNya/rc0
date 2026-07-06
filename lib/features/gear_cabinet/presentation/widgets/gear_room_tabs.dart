import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../domain/gear_room_type.dart';
import '../theme/gear_cabinet_colors.dart';

/// Horizontal room tabs with slide-fade selection.
class GearRoomTabs extends StatelessWidget {
  const GearRoomTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final GearRoomType selected;
  final ValueChanged<GearRoomType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
        ),
        itemCount: GearRoomType.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          final type = GearRoomType.values[index];
          final isSelected = type == selected;
          return _RoomTab(
            type: type,
            selected: isSelected,
            onTap: () => onChanged(type),
          );
        },
      ),
    );
  }
}

class _RoomTab extends StatelessWidget {
  const _RoomTab({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final GearRoomType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.floatingBarRadius),
          color: selected
              ? GearCabinetColors.accentGlow
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? GearCabinetColors.accent.withValues(alpha: 0.5)
                : GearCabinetColors.borderWood.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.fast,
              child: Icon(
                selected ? type.selectedIcon : type.icon,
                key: ValueKey(selected),
                size: 18,
                color: selected
                    ? GearCabinetColors.accent
                    : GearCabinetColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? GearCabinetColors.textPrimary
                    : GearCabinetColors.textSecondary,
              ),
              child: Text(type.label),
            ),
          ],
        ),
      ),
    );
  }
}
