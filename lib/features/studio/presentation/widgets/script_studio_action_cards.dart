import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import 'script_studio_glass_widgets.dart';
import 'script_studio_theme.dart';

class ScriptStudioActionCards extends StatelessWidget {
  const ScriptStudioActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
      child: Column(
        children: [
          _PrimaryCreateCard(
            onTap: () => context.go(AppRoutes.studioCreate),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SecondaryActionCard(
                  icon: Icons.auto_awesome,
                  glowColor: AppColors.accent,
                  title: 'AI 导入剧本',
                  subtitle: '智能拆解剧本内容',
                  onTap: () =>
                      context.push(AppRoutes.comingSoon('AI 导入剧本')),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: _SecondaryActionCard(
                  icon: Icons.folder_copy_outlined,
                  glowColor: AppColors.badgeHot,
                  title: '模板中心',
                  subtitle: '使用优质模板创作',
                  onTap: () => context.go(AppRoutes.community),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryCreateCard extends StatelessWidget {
  const _PrimaryCreateCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudioGlassCard(
      onTap: onTap,
      glowColor: const Color(0xFF6366F1),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        children: [
          const StudioGlowIconBox(icon: Icons.add),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('新建剧本', style: ScriptStudioColors.cardTitle),
                const SizedBox(height: 4),
                Text('从空白开始创作', style: ScriptStudioColors.cardSubtitle),
              ],
            ),
          ),
          const StudioChevronBadge(),
        ],
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.icon,
    required this.glowColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color glowColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudioGlassCard(
      onTap: onTap,
      glowColor: glowColor,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: SizedBox(
        height: 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: glowColor, size: 28),
            const Spacer(),
            Text(title, style: ScriptStudioColors.cardTitle),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: ScriptStudioColors.cardSubtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: StudioChevronBadge(),
            ),
          ],
        ),
      ),
    );
  }
}
