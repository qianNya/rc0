import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../domain/gear_device.dart';
import '../../domain/gear_shelf.dart';
import '../theme/gear_cabinet_colors.dart';
import 'gear_device_card.dart';

/// One horizontal shelf row inside an expanded cabinet.
class GearShelfRow extends StatelessWidget {
  const GearShelfRow({
    super.key,
    required this.shelf,
    required this.onDeviceTap,
    this.animate = true,
  });

  final GearShelf shelf;
  final ValueChanged<GearDevice> onDeviceTap;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shelf.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: GearCabinetColors.nameplateGoldDim,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = shelf.devices.length.clamp(1, 4);
              final gap = AppDimensions.spacingSm;
              final itemWidth =
                  (constraints.maxWidth - gap * (count - 1)) / count;
              return Row(
                children: [
                  for (var i = 0; i < shelf.devices.length; i++) ...[
                    if (i > 0) SizedBox(width: gap),
                    SizedBox(
                      width: itemWidth,
                      child: GearDeviceCard(
                        device: shelf.devices[i],
                        onTap: () => onDeviceTap(shelf.devices[i]),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );

    if (!animate) return content;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}
