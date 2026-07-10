import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../data/image_tags_repository.dart';
import '../../domain/image_tag.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';

class GalleryTagsTab extends StatefulWidget {
  const GalleryTagsTab({
    super.key,
    required this.onTagSelected,
  });

  final ValueChanged<ImageTag> onTagSelected;

  @override
  State<GalleryTagsTab> createState() => _GalleryTagsTabState();
}

class _GalleryTagsTabState extends State<GalleryTagsTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = ImageTagsRepository.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tags = _repo.tags;
    final theme = Theme.of(context);
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    if (_repo.loading && tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: FeedGridSkeleton(tileCount: 4),
      );
    }

    if (tags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: GlassEmptyState(
          icon: Icons.label_outline,
          title: _repo.error != null ? '加载失败' : '暂无标签',
          subtitle: _repo.error ?? '上传图片后可在此查看分类标签',
          actionLabel: _repo.error != null ? '重试' : null,
          onAction: _repo.error != null ? () => _repo.loadTags() : null,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
      ),
      itemCount: tags.length + (_repo.error != null ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (_repo.error != null && index == 0) {
          return InlineErrorBanner(
            message: _repo.error!,
            onRetry: () => _repo.loadTags(),
          );
        }
        final tagIndex = _repo.error != null ? index - 1 : index;
        final tag = tags[tagIndex];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tag.name, style: AppTextStyles.body),
          subtitle: tag.slug.isNotEmpty
              ? Text(tag.slug, style: TextStyle(fontSize: 12, color: secondary))
              : null,
          trailing: tag.imageCount > 0
              ? Text(
                  '${tag.imageCount}',
                  style: TextStyle(color: secondary, fontSize: 13),
                )
              : const Icon(Icons.chevron_right, size: 20),
          onTap: () => widget.onTagSelected(tag),
        );
      },
    );
  }
}
