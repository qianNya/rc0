import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../domain/gear_cabinet.dart';
import '../theme/gear_cabinet_colors.dart';
import 'gear_wood_cabinet_frame.dart';

/// Collapsed cabinet thumbnails in overview zoom level.
class GearCabinetOverview extends StatelessWidget {
  const GearCabinetOverview({
    super.key,
    required this.cabinets,
    required this.onCabinetTap,
    this.onAddCabinet,
  });

  final List<GearCabinet> cabinets;
  final ValueChanged<GearCabinet> onCabinetTap;
  final VoidCallback? onAddCabinet;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
      ),
      children: [
        for (var i = 0; i < cabinets.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDimensions.spacingMd),
          _CabinetThumbnail(
            cabinet: cabinets[i],
            index: i,
            onTap: () => onCabinetTap(cabinets[i]),
          ),
        ],
        if (onAddCabinet != null) ...[
          const SizedBox(width: AppDimensions.spacingMd),
          _AddCabinetCard(onTap: onAddCabinet!),
        ],
      ],
    );
  }
}

class _CabinetThumbnail extends StatelessWidget {
  const _CabinetThumbnail({
    required this.cabinet,
    required this.index,
    required this.onTap,
  });

  final GearCabinet cabinet;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
      curve: AppMotion.standard,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.92 + value * 0.08,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 148,
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 0.72,
                child: GearWoodCabinetFrame(
                  cabinet: cabinet,
                  compact: true,
                  child: _MiniShelfPreview(cabinet: cabinet),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                cabinet.displayLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GearCabinetColors.textPrimary,
                ),
              ),
              Text(
                '${cabinet.deviceCount} 件',
                style: const TextStyle(
                  fontSize: 12,
                  color: GearCabinetColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniShelfPreview extends StatelessWidget {
  const _MiniShelfPreview({required this.cabinet});

  final GearCabinet cabinet;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: GearCabinetColors.shelfInner,
        border: Border.all(
          color: GearCabinetColors.borderWood.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            for (final shelf in cabinet.shelves.take(4)) ...[
              Expanded(
                child: Row(
                  children: [
                    for (final device in shelf.devices.take(3)) ...[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1F28),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              device.icon ?? Icons.devices_outlined,
                              size: 10,
                              color: GearCabinetColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddCabinetCard extends StatelessWidget {
  const _AddCabinetCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 148,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 0.72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: GearCabinetColors.borderWood.withValues(alpha: 0.5),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: CustomPaint(
                  painter: _DashedBorderPainter(),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 32,
                      color: GearCabinetColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(
              '添加柜子',
              style: TextStyle(
                fontSize: 14,
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

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GearCabinetColors.textTertiary.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dash = 6.0;
    const gap = 4.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(16),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
