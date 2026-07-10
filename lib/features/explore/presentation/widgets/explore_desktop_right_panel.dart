import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';
import '../../../../shared/widgets/pose_cover_image.dart';

class ExploreDesktopRightPanel extends StatelessWidget {
  const ExploreDesktopRightPanel({
    super.key,
    required this.feedItems,
    required this.onTagTap,
    required this.onCreate,
    this.onBrowseTemplates,
  });

  final List<Screenplay> feedItems;
  final ValueChanged<String> onTagTap;
  final VoidCallback onCreate;
  final VoidCallback? onBrowseTemplates;

  List<Screenplay> get _trending {
    final sorted = [...feedItems]
      ..sort((a, b) => b.likes.compareTo(a.likes));
    return sorted.take(5).toList();
  }

  List<String> get _hotTags {
    final tags =
        buildTagFilters(feedItems).where((t) => t != '全部').take(12).toList();
    if (tags.isNotEmpty) return tags;
    return AppCatalog.suggestedUploadTags.take(12).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: GlassCard(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: ListView(
          children: [
            Text('热门标签', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: [
                for (final tag in _hotTags)
                  _GlassTagChip(label: tag, onTap: () => onTagTap(tag)),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text('今日热门', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.spacingSm),
            if (_trending.isEmpty)
              Text('暂无数据', style: AppTextStyles.bodySecondary)
            else
              for (var i = 0; i < _trending.length; i++)
                _TrendingRow(rank: i + 1, screenplay: _trending[i]),
            const SizedBox(height: AppDimensions.spacingLg),
            _CreateBanner(
              onCreate: onCreate,
              onBrowseTemplates: onBrowseTemplates,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text('最新动态', style: AppTextStyles.label),
            const SizedBox(height: AppDimensions.spacingSm),
            for (final activity in _staticActivities)
              _ActivityRow(activity: activity),
          ],
        ),
      ),
    );
  }
}

class _GlassTagChip extends StatelessWidget {
  const _GlassTagChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border =
        isDark ? AppColors.glassNavBorderDark : AppColors.glassNavBorderLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppDimensions.tabFloatingRadius),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            color: secondary,
          ),
        ),
      ),
    );
  }
}

class _TrendingRow extends StatelessWidget {
  const _TrendingRow({required this.rank, required this.screenplay});

  final int rank;
  final Screenplay screenplay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.push(AppRoutes.script(screenplay.detailRouteId)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:
                        rank <= 3 ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: PoseCoverImage(
                    imagePath: screenplay.effectiveCoverImagePath,
                    expand: true,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screenplay.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                    Text(
                      '${formatFeedCount(screenplay.likes)} 赞',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateBanner extends StatelessWidget {
  const _CreateBanner({
    required this.onCreate,
    this.onBrowseTemplates,
  });

  final VoidCallback onCreate;
  final VoidCallback? onBrowseTemplates;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '创建你的第一个剧本',
            style: AppTextStyles.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            '从空白开始，或使用模板快速创作',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          GlassButton(
            label: '开始创作',
            filled: true,
            expand: true,
            onPressed: onCreate,
          ),
          if (onBrowseTemplates != null) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            GlassButton(
              label: '浏览模板',
              expand: true,
              onPressed: onBrowseTemplates,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.username,
    required this.action,
    required this.target,
  });

  final String username;
  final String action;
  final String target;
}

const _staticActivities = [
  _ActivityItem(
    username: 'LensWalker',
    action: '点赞了你的作品',
    target: '海边少女',
  ),
  _ActivityItem(
    username: '小熊同学',
    action: '收藏了你的模板',
    target: '光影人像',
  ),
  _ActivityItem(
    username: 'PoseMaster',
    action: '发布了新模板',
    target: '构图练习',
  ),
];

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final _ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          children: [
            TextSpan(
              text: activity.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: ' ${activity.action} '),
            TextSpan(
              text: activity.target,
              style: const TextStyle(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
