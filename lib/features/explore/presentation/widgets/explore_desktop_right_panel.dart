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
import '../../../../shared/widgets/pose_cover_image.dart';
import 'explore_desktop_card.dart';

class ExploreDesktopRightPanel extends StatelessWidget {
  const ExploreDesktopRightPanel({
    super.key,
    required this.feedItems,
    required this.onTagTap,
    required this.onCreate,
  });

  final List<Screenplay> feedItems;
  final ValueChanged<String> onTagTap;
  final VoidCallback onCreate;

  List<Screenplay> get _trending {
    final sorted = [...feedItems]
      ..sort((a, b) => b.likes.compareTo(a.likes));
    return sorted.take(5).toList();
  }

  List<String> get _hotTags {
    final tags = buildTagFilters(feedItems).where((t) => t != '全部').take(12).toList();
    if (tags.isNotEmpty) return tags;
    return AppCatalog.suggestedUploadTags.take(12).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ExploreDesktopCard(
      width: 320,
      padding: const EdgeInsets.all(ExploreDesktopChrome.gap * 2),
      child: ListView(
        children: [
          Text('热门标签', style: AppTextStyles.label),
          const SizedBox(height: ExploreDesktopChrome.gap),
          Wrap(
            spacing: ExploreDesktopChrome.gap,
            runSpacing: ExploreDesktopChrome.gap,
            children: [
              for (final tag in _hotTags)
                ActionChip(
                  label: Text(tag),
                  onPressed: () => onTagTap(tag),
                  backgroundColor: AppColors.surfaceSecondary,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: ExploreDesktopChrome.gap * 2),
          Text('今日热门', style: AppTextStyles.label),
          const SizedBox(height: ExploreDesktopChrome.gap),
          if (_trending.isEmpty)
            Text('暂无数据', style: AppTextStyles.bodySecondary)
          else
            for (var i = 0; i < _trending.length; i++)
              _TrendingRow(rank: i + 1, screenplay: _trending[i]),
          const SizedBox(height: ExploreDesktopChrome.gap * 2),
          _CreateBanner(onCreate: onCreate),
          const SizedBox(height: ExploreDesktopChrome.gap * 2),
          Text('最新动态', style: AppTextStyles.label),
          const SizedBox(height: ExploreDesktopChrome.gap),
          for (final activity in _staticActivities)
            _ActivityRow(activity: activity),
        ],
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
      padding: const EdgeInsets.only(bottom: ExploreDesktopChrome.gap),
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
                  color: rank <= 3 ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: PoseCoverImage(
                  imagePath: screenplay.effectiveCoverImagePath,
                  expand: true,
                ),
              ),
            ),
            const SizedBox(width: ExploreDesktopChrome.gap),
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
    );
  }
}

class _CreateBanner extends StatefulWidget {
  const _CreateBanner({required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<_CreateBanner> createState() => _CreateBannerState();
}

class _CreateBannerState extends State<_CreateBanner> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        padding: const EdgeInsets.all(ExploreDesktopChrome.gap * 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.profileGradientStart, AppColors.profileGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '创建你的第一个剧本',
              style: AppTextStyles.title.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: ExploreDesktopChrome.gap),
            Text(
              '从空白开始，或使用模板快速创作',
              style: AppTextStyles.bodySecondary.copyWith(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: ExploreDesktopChrome.gap * 1.5),
            OutlinedButton(
              onPressed: widget.onCreate,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide.none,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
              ),
              child: const Text('开始创作'),
            ),
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: ExploreDesktopChrome.gap * 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accentLight,
            child: Text(
              activity.username.characters.first,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: ExploreDesktopChrome.gap),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.body.copyWith(fontSize: 12, height: 1.4),
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
          ),
        ],
      ),
    );
  }
}
