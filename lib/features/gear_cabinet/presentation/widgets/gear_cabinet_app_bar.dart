import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/system_ui_style.dart';
import '../theme/gear_cabinet_colors.dart';

/// Floating glass top bar for the gear cabinet page.
class GearCabinetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GearCabinetAppBar({
    super.key,
    this.onSearch,
    this.onFilter,
    this.onAdd,
    this.showBack = false,
    this.onBack,
  });

  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onAdd;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.darkStyle,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.floatingBarMarginHorizontal,
            AppDimensions.topNavFloatingMarginTop,
            AppDimensions.floatingBarMarginHorizontal,
            AppDimensions.topNavFloatingMarginBottom,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.topNavFloatingRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.glassNavBlurSigma,
                sigmaY: AppDimensions.glassNavBlurSigma,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.topNavFloatingRadius),
                  color: GearCabinetColors.glassOverlay,
                  border: Border.all(
                    color: GearCabinetColors.borderWood.withValues(alpha: 0.35),
                  ),
                ),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      if (showBack)
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: GearCabinetColors.textPrimary,
                          ),
                          onPressed: onBack,
                          tooltip: '返回',
                        )
                      else
                        const SizedBox(width: AppDimensions.spacingMd),
                      const Text(
                        '设备库',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: GearCabinetColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      _IconBtn(
                        icon: Icons.search_rounded,
                        onPressed: onSearch,
                        tooltip: '搜索',
                      ),
                      _IconBtn(
                        icon: Icons.tune_rounded,
                        onPressed: onFilter,
                        tooltip: '筛选',
                      ),
                      _IconBtn(
                        icon: Icons.add_rounded,
                        onPressed: onAdd,
                        tooltip: '添加设备',
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: GearCabinetColors.textPrimary, size: 22),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
