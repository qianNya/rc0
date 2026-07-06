import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../domain/gear_zoom_level.dart';
import '../theme/gear_cabinet_colors.dart';

/// Floating zoom control — toggles overview ↔ focus.
class GearCabinetZoomFab extends StatelessWidget {
  const GearCabinetZoomFab({
    super.key,
    required this.zoomLevel,
    required this.onToggle,
  });

  final GearZoomLevel zoomLevel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isFocus = zoomLevel == GearZoomLevel.focus;
    return GestureDetector(
      onTap: onToggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.glassNavBlurSigma,
            sigmaY: AppDimensions.glassNavBlurSigma,
          ),
          child: AnimatedContainer(
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GearCabinetColors.accent.withValues(alpha: 0.85),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: GearCabinetColors.accent.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              child: Icon(
                isFocus ? Icons.grid_view_rounded : Icons.zoom_out_map_rounded,
                key: ValueKey(isFocus),
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
