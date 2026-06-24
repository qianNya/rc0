import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/profile_widgets.dart';

class ExploreQuickActions extends StatelessWidget {
  const ExploreQuickActions({super.key});

  void _onTap(BuildContext context, String label) {
    switch (label) {
      case '图片':
        context.go(AppRoutes.library);
      case '剧本':
        context.push(AppRoutes.community);
      case '分镜':
        context.push(AppRoutes.comingSoon('分镜'));
      case '预设':
        context.push(AppRoutes.shootPresetPicker(mode: 'manage'));
      case '用户':
        context.push(AppRoutes.search);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = AppCatalog.discoveryQuickActions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        20,
        AppDimensions.spacingMd,
        4,
      ),
      child: Row(
        children: [
          for (final action in actions)
            Expanded(
              child: QuickActionCircle(
                label: action.label,
                icon: action.icon,
                backgroundColor: isDark
                    ? action.iconColor.withValues(alpha: 0.18)
                    : action.backgroundColor,
                iconColor: action.iconColor,
                onTap: () => _onTap(context, action.label),
              ),
            ),
        ],
      ),
    );
  }
}
