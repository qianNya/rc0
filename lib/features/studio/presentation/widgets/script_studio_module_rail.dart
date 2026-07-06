import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';

class ScriptStudioModuleRail extends StatelessWidget {
  const ScriptStudioModuleRail({super.key});

  List<_RailItem> get _items => [
    const _RailItem(
      icon: Icons.movie_creation_outlined,
      label: '创作',
      isActive: true,
    ),
    const _RailItem(
      icon: Icons.perm_media_outlined,
      label: '素材库',
      route: AppRoutes.gallery,
    ),
    const _RailItem(
      icon: Icons.person_outline,
      label: '角色库',
      route: AppRoutes.character,
    ),
    const _RailItem(
      icon: Icons.view_in_ar_outlined,
      label: '场景库',
      route: AppRoutes.scenes,
    ),
    _RailItem(
      icon: Icons.camera_outlined,
      label: '预设',
      route: AppRoutes.shootPresetPicker(mode: 'manage'),
    ),
    _RailItem(
      icon: Icons.videocam_outlined,
      label: '设备',
      route: AppRoutes.library,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacingSm),
            for (final item in _items) _RailButton(item: item),
            const Spacer(),
            IconButton(
              tooltip: '帮助',
              onPressed: () => context.push(AppRoutes.labsFeature('help_center')),
              icon: const Icon(Icons.help_outline, size: 20),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
          ],
        ),
      ),
    );
  }
}

class _RailItem {
  const _RailItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.route,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final String? route;
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.item});

  final _RailItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isActive ? AppColors.accent : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: item.isActive
            ? null
            : () {
                final route = item.route;
                if (route != null) {
                  context.push(route);
                }
              },
        child: Container(
          width: 48,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: item.isActive
              ? BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 20, color: color),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(fontSize: 9, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
