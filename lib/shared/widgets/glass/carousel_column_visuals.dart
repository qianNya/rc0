import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../features/cine_equipment/domain/equipment_category.dart';
import 'equipment_simulation_art.dart';

/// Visual column types for [GlassFourColumnCarouselPicker].
enum CarouselColumnKind {
  cameraBody,
  lens,
  focalLength,
  aperture,
  shootDevice,
  aspectRatio,
  lighting,
}

/// Builds the center visual for each carousel item (light glass palette).
class CarouselColumnVisuals {
  const CarouselColumnVisuals._();

  static Widget build({
    required CarouselColumnKind kind,
    required String value,
    required bool selected,
    EquipmentCategory? bodyCategory,
  }) {
    final opacity = selected ? 1.0 : 0.38;
    final scale = selected ? 1.0 : 0.84;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 180),
      child: Opacity(
        opacity: opacity,
        child: _VisualCell(
          child: switch (kind) {
            CarouselColumnKind.cameraBody => _cameraBodyVisual(
                bodyCategory: bodyCategory,
                deviceName: value,
              ),
            CarouselColumnKind.lens => _lensVisual(),
            CarouselColumnKind.focalLength =>
              _textVisual(value, large: true, selected: selected),
            CarouselColumnKind.aperture =>
              _textVisual(value, large: true, selected: selected),
            CarouselColumnKind.shootDevice => _shootDeviceVisual(
                value,
                bodyCategory: bodyCategory,
              ),
            CarouselColumnKind.aspectRatio =>
              _textVisual(value, selected: selected),
            CarouselColumnKind.lighting =>
              _textVisual(value, selected: selected),
          },
        ),
      ),
    );
  }

  static Widget _cameraBodyVisual({
    EquipmentCategory? bodyCategory,
    String? deviceName,
  }) {
    final badge = bodyCategory == EquipmentCategory.cinema ? 'FILM' : null;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        EquipmentSimulationArt.cameraBody(
          category: bodyCategory,
          deviceName: deviceName,
        ),
        if (badge != null)
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 8,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget _lensVisual() {
    return EquipmentSimulationArt.lens();
  }

  static Widget _shootDeviceVisual(
    String device, {
    EquipmentCategory? bodyCategory,
  }) {
    return EquipmentSimulationArt.cameraBody(
      category: bodyCategory,
      deviceName: device,
      compact: true,
    );
  }

  static Widget _textVisual(
    String value, {
    bool large = false,
    required bool selected,
  }) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: AppTextStyles.title.copyWith(
        fontSize: large ? 22 : 16,
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.accent : AppColors.textPrimary,
        height: 1.1,
      ),
    );
  }
}

class _VisualCell extends StatelessWidget {
  const _VisualCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Center(child: child),
    );
  }
}
