import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/pose_cover_image.dart';

class ExploreFeedGridCard extends StatelessWidget {
  const ExploreFeedGridCard({
    super.key,
    required this.screenplay,
    this.onDelete,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectedToggle,
    this.onLongPressEnterSelection,
  });

  final Screenplay screenplay;
  final VoidCallback? onDelete;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectedToggle;
  final VoidCallback? onLongPressEnterSelection;

  bool get _show4kBadge =>
      screenplay.allTags.any((t) => t.contains('4K') || t.contains('4k'));

  bool get _showVideoBadge =>
      screenplay.allTags.any((t) => t.contains('视频') || t.contains('video'));

  void _handleTap(BuildContext context) {
    if (selectionMode) {
      onSelectedToggle?.call();
      return;
    }
    context.push(AppRoutes.script(screenplay.detailRouteId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final structureLabel = feedStructureLabel(screenplay);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context),
        onLongPress: selectionMode
            ? onSelectedToggle
            : onLongPressEnterSelection ?? onDelete,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: selectionMode && selected
                ? Border.all(color: AppColors.accent, width: 2)
                : null,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PoseCoverImage(
                    imagePath: screenplay.effectiveCoverImagePath,
                    expand: true,
                  ),
                  if (selectionMode)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Checkbox(
                        value: selected,
                        onChanged: (_) => onSelectedToggle?.call(),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  if (_show4kBadge)
                    Positioned(
                      top: 8,
                      left: selectionMode ? 36 : 8,
                      child: const _CornerBadge(label: '4K'),
                    ),
                  if (_showVideoBadge)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.scrim,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    screenplay.title,
                    style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  FeedAuthorRow(
                    author: screenplay.author,
                    avatarUrl: screenplay.authorAvatar,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    structureLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatFeedCount(screenplay.likes),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatFeedCount(screenplay.views),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: secondary,
                        ),
                      ),
                    ],
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

class _CornerBadge extends StatelessWidget {
  const _CornerBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
