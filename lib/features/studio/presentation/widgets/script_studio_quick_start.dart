import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import 'script_studio_glass_widgets.dart';
import 'script_studio_theme.dart';

class ScriptStudioQuickStart extends StatelessWidget {
  const ScriptStudioQuickStart({super.key});

  void _onTap(BuildContext context, String label) {
    switch (label) {
      case '角色库':
        context.push(AppRoutes.character);
      case '场景库':
        context.go(AppRoutes.scenes);
      case '摄影预设':
        context.push(AppRoutes.shootPresetPicker(mode: 'manage'));
      case '灯光':
        context.push(AppRoutes.lighting);
      case '我的素材':
        context.push(AppRoutes.library);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = AppCatalog.studioQuickStartActions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('快速开始', style: ScriptStudioColors.sectionTitle),
          const SizedBox(height: AppDimensions.spacingLg),
          Row(
            children: [
              for (final action in actions)
                Expanded(
                  child: StudioQuickActionOrb(
                    label: action.label,
                    icon: action.icon,
                    glowColor: action.iconColor,
                    onTap: () => _onTap(context, action.label),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
