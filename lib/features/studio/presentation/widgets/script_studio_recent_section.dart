import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import 'script_studio_glass_widgets.dart';
import 'script_studio_theme.dart';

class ScriptStudioRecentSection extends StatelessWidget {
  const ScriptStudioRecentSection({
    super.key,
    required this.projects,
    required this.onDataChanged,
  });

  final List<Screenplay> projects;
  final VoidCallback onDataChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StudioSectionHeader(
            title: '最近项目',
            action: '全部',
            onActionTap: () => context.push(AppRoutes.profileWorks),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          if (projects.isEmpty)
            const _EmptyRecentCard()
          else
            ...projects.map(
              (script) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                child: _RecentProjectTile(
                  screenplay: script,
                  onDataChanged: onDataChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudioSectionHeader extends StatelessWidget {
  const _StudioSectionHeader({
    required this.title,
    required this.action,
    required this.onActionTap,
  });

  final String title;
  final String action;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: ScriptStudioColors.sectionTitle),
        const Spacer(),
        GestureDetector(
          onTap: onActionTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(action, style: ScriptStudioColors.sectionAction),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  const _EmptyRecentCard();

  @override
  Widget build(BuildContext context) {
    return StudioGlassCard(
      minHeight: 220,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingXl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_creation_outlined,
            size: 56,
            color: ScriptStudioColors.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          const Text('暂无项目', style: ScriptStudioColors.cardTitle),
          const SizedBox(height: 6),
          const Text(
            '新建剧本后会显示在这里',
            style: ScriptStudioColors.cardSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentProjectTile extends StatelessWidget {
  const _RecentProjectTile({
    required this.screenplay,
    required this.onDataChanged,
  });

  final Screenplay screenplay;
  final VoidCallback onDataChanged;

  String get _statusLabel {
    final status = screenplay.isPublished ? '已发布' : '创作中';
    return '$status · ${screenplay.actCount}幕 · ${screenplay.sceneCount}场 · ${screenplay.frameCount}画';
  }

  String get _timeLabel {
    final date = screenplay.updatedAt ?? screenplay.createdAt;
    if (date == null) return '';
    return formatRelativeTime(date);
  }

  String get _sourceLabel => screenplay.isLocal ? '草稿' : '云端';

  Color get _sourceFg =>
      screenplay.isLocal ? AppColors.catPurple : AppColors.catBlue;

  Color get _sourceBg =>
      screenplay.isLocal ? AppColors.catPurpleBg : AppColors.catBlueBg;

  void _openProject(BuildContext context) {
    if (screenplay.isLocal && !screenplay.isPublished) {
      context.go(AppRoutes.studioEdit(screenplay.id));
      return;
    }
    context.push(AppRoutes.script(screenplay.detailRouteId));
  }

  Future<void> _delete(BuildContext context) async {
    if (!screenplay.isLocal) return;
    final deleted = await confirmAndDeleteScreenplays(context, [screenplay]);
    if (deleted) onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return StudioGlassCard(
      onTap: () => _openProject(context),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: 10,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: SizedBox(
              width: 56,
              height: 56,
              child: PoseCoverImage(
                imagePath: screenplay.effectiveCoverImagePath,
                expand: true,
                borderRadius: 0,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        screenplay.title.isEmpty ? '未命名剧本' : screenplay.title,
                        style: ScriptStudioColors.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    _SourceBadge(
                      label: _sourceLabel,
                      fg: _sourceFg,
                      bg: _sourceBg,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _statusLabel,
                  style: ScriptStudioColors.cardSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_timeLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _timeLabel,
                    style: ScriptStudioColors.cardSubtitle.copyWith(
                      color: ScriptStudioColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (screenplay.isLocal)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_horiz,
                color: ScriptStudioColors.textSecondary,
              ),
              color: AppColors.surface,
              onSelected: (value) {
                if (value == 'delete') _delete(context);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    '删除',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
