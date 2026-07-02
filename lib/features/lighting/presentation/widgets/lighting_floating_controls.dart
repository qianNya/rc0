import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../domain/lighting_scheme.dart';
import '../lighting_editor_controller.dart';

/// Frosted vertical tool stack floating over the 3D viewport.
class LightingFloatingControls extends StatelessWidget {
  const LightingFloatingControls({
    super.key,
    required this.controller,
    required this.onEditLight,
    required this.onOpenLights,
    required this.onOpenSchemes,
  });

  final LightingEditorController controller;
  final VoidCallback onEditLight;
  final VoidCallback onOpenLights;
  final VoidCallback onOpenSchemes;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark
        ? AppColors.glassNavSurfaceDark
        : AppColors.glassNavSurfaceLight;
    final border = isDark
        ? AppColors.glassNavBorderDark
        : AppColors.glassNavBorderLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassNavBlurSigma,
          sigmaY: AppDimensions.glassNavBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacingSm,
              horizontal: 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToolIcon(
                  icon: controller.planView
                      ? Icons.view_in_ar_outlined
                      : Icons.map_outlined,
                  tooltip: controller.planView ? '3D 视角' : '平面图',
                  onTap: () =>
                      controller.setPlanView(!controller.planView),
                ),
                _ToolIcon(
                  icon: Icons.tune_rounded,
                  tooltip: '灯光参数',
                  onTap: onEditLight,
                ),
                _ToolIcon(
                  icon: Icons.lightbulb_outline_rounded,
                  tooltip: '灯光列表',
                  onTap: onOpenLights,
                ),
                _ToolIcon(
                  icon: Icons.auto_awesome_mosaic_outlined,
                  tooltip: '灯光方案',
                  onTap: onOpenSchemes,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isDark ? AppColors.glassNavIconDark : AppColors.glassNavIconLight;
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, color: color, size: 22),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Bottom glass bar — tap to open scheme picker.
class LightingSchemeBottomBar extends StatelessWidget {
  const LightingSchemeBottomBar({
    super.key,
    required this.scheme,
    required this.onTap,
  });

  final LightingScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark
        ? AppColors.glassNavSurfaceDark
        : AppColors.glassNavSurfaceLight;
    final border = isDark
        ? AppColors.glassNavBorderDark
        : AppColors.glassNavBorderLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDimensions.glassNavBlurSigma,
              sigmaY: AppDimensions.glassNavBlurSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: border, width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm + 2,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_incandescent_outlined,
                      size: 20,
                      color: isDark
                          ? AppColors.glassNavIconDark
                          : AppColors.glassNavIconLight,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            scheme.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            scheme.summaryLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: isDark
                          ? AppColors.glassNavIconDark
                          : AppColors.glassNavIconLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary action chip (save / apply) floating near bottom bar.
class LightingFloatingActionChip extends StatelessWidget {
  const LightingFloatingActionChip({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: label,
      filled: filled,
      onPressed: onPressed,
    );
  }
}
