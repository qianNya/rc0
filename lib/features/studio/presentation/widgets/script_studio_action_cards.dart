import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

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
            children: [
              Expanded(
                child: _SecondaryActionCard(
                  icon: Icons.auto_awesome_outlined,
                  iconColor: AppColors.accent,
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
                  iconColor: AppColors.badgeHot,
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: 20,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '新建剧本',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '从空白开始创作',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.brightness == Brightness.dark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
