import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../domain/gear_device.dart';
import '../../domain/gear_device_status.dart';
import '../theme/gear_cabinet_colors.dart';

/// Single device tile on a shelf.
class GearDeviceCard extends StatelessWidget {
  const GearDeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.compact = false,
  });

  final GearDevice device;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1,
        duration: AppMotion.fast,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: compact ? 0.85 : 0.9,
              child: Hero(
                tag: 'gear-device-${device.id}',
                child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLg),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GearCabinetColors.shelfInner,
                      Color(0xFF1C222C),
                    ],
                  ),
                  border: Border.all(
                    color: GearCabinetColors.borderWood.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GearCabinetColors.spotlight,
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        device.icon ?? Icons.devices_outlined,
                        size: compact ? 28 : 36,
                        color: GearCabinetColors.textPrimary
                            .withValues(alpha: 0.85),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _StatusDot(status: device.status),
                    ),
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(height: 6),
            Text(
              device.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: GearCabinetColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final GearDeviceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status.color,
        boxShadow: [
          BoxShadow(
            color: status.color.withValues(alpha: 0.6),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}
