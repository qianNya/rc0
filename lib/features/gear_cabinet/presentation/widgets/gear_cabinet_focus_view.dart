import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../domain/gear_cabinet.dart';
import '../../domain/gear_device.dart';
import '../theme/gear_cabinet_colors.dart';
import 'gear_shelf_row.dart';
import 'gear_wood_cabinet_frame.dart';

/// Expanded single-cabinet view with all shelves visible.
class GearCabinetFocusView extends StatelessWidget {
  const GearCabinetFocusView({
    super.key,
    required this.cabinet,
    required this.onDeviceTap,
    this.scale = 1.0,
    this.editMode = false,
    this.onDeviceReorder,
  });

  final GearCabinet cabinet;
  final ValueChanged<GearDevice> onDeviceTap;
  final double scale;
  final bool editMode;
  final void Function(String shelfId, int oldIndex, int newIndex)? onDeviceReorder;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale.clamp(0.85, 1.15),
      duration: AppMotion.normal,
      curve: AppMotion.smooth,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
        ),
        child: GearWoodCabinetFrame(
          cabinet: cabinet,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: GearCabinetColors.shelfInner,
              border: Border(
                top: BorderSide(
                  color: GearCabinetColors.borderWood.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: cabinet.shelves.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                color: GearCabinetColors.borderWood.withValues(alpha: 0.25),
              ),
              itemBuilder: (context, index) {
                return GearShelfRow(
                  shelf: cabinet.shelves[index],
                  onDeviceTap: onDeviceTap,
                  editMode: editMode,
                  onDeviceReorder: onDeviceReorder == null
                      ? null
                      : (oldIndex, newIndex) => onDeviceReorder!(
                            cabinet.shelves[index].id,
                            oldIndex,
                            newIndex,
                          ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
