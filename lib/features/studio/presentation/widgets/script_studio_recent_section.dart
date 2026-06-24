import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

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
          SectionHeader(
            title: '最近项目',
            action: '全部',
            showChevron: true,
            onActionTap: () => context.push(AppRoutes.profileWorks),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          if (projects.isEmpty)
            EmptyStateView(
              icon: Icons.movie_creation_outlined,
              title: '暂无项目',
              subtitle: '新建剧本后会显示在这里',
              actionLabel: '新建剧本',
              onAction: () => context.push(AppRoutes.create),
            )
          else
            ...projects.map(
              (script) => _RecentProjectTile(
                screenplay: script,
                onDataChanged: onDataChanged,
              ),
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
    final date = screenplay.createdAt;
    if (date == null) return '';
    return formatRelativeTime(date);
  }

  void _openProject(BuildContext context) {
    if (screenplay.isLocal && !screenplay.isPublished) {
      context.push(AppRoutes.studioEdit(screenplay.id));
      return;
    }
    context.push(AppRoutes.script(screenplay.detailRouteId));
  }

  Future<void> _delete(BuildContext context) async {
    final deleted = await confirmAndDeleteScreenplays(context, [screenplay]);
    if (deleted) onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final tertiary = theme.brightness == Brightness.dark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openProject(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
                    Text(
                      screenplay.title.isEmpty ? '未命名剧本' : screenplay.title,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel,
                      style: TextStyle(fontSize: 12, color: secondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_timeLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _timeLabel,
                        style: TextStyle(fontSize: 12, color: tertiary),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: secondary),
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
        ),
      ),
    );
  }
}
