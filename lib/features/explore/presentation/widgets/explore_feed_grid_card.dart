import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
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
    this.overlayMetrics = false,
  });

  final Screenplay screenplay;
  final VoidCallback? onDelete;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectedToggle;
  final VoidCallback? onLongPressEnterSelection;
  final bool overlayMetrics;

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
                    if (overlayMetrics)
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.heroScrimBottom,
                            ],
                            stops: [0.45, 1.0],
                          ),
                        ),
                      ),
                    if (selectionMode)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Checkbox(
                          value: selected,
                          onChanged: (_) => onSelectedToggle?.call(),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
                          padding:
                              const EdgeInsets.all(AppDimensions.spacingXs),
                          decoration: BoxDecoration(
                            color: AppColors.scrim,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (overlayMetrics)
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: _OverlayMetricPill(
                                icon: Icons.auto_stories_outlined,
                                label: structureLabel,
                                shrinkLabel: true,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _OverlayMetricPill(
                              icon: Icons.visibility_outlined,
                              label: formatFeedCount(screenplay.views),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  overlayMetrics ? 8 : 10,
                  overlayMetrics ? 6 : 8,
                  overlayMetrics ? 8 : 10,
                  overlayMetrics ? 8 : 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screenplay.title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: overlayMetrics ? 11 : 13,
                        fontWeight: overlayMetrics
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: overlayMetrics ? 4 : 6),
                    _CompactAuthorRow(
                      author: screenplay.author,
                      avatarUrl: screenplay.authorAvatar,
                      compact: overlayMetrics,
                    ),
                    if (!overlayMetrics) ...[
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

class _CompactAuthorRow extends StatelessWidget {
  const _CompactAuthorRow({
    required this.author,
    this.avatarUrl,
    this.compact = false,
  });

  final String author;
  final String? avatarUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatar = avatarUrl?.trim();
    final hasAvatar = resolvedAvatar != null && resolvedAvatar.isNotEmpty;
    final avatarRadius = compact ? 8.0 : 12.0;
    final fontSize = compact ? 10.0 : 13.0;
    final iconSize = compact ? 10.0 : 14.0;

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: AppColors.placeholder,
          backgroundImage:
              hasAvatar ? NetworkImage(resolvedAvatar) : null,
          child: hasAvatar
              ? null
              : Icon(Icons.person, size: iconSize, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            author.isNotEmpty ? author : '作者',
            style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OverlayMetricPill extends StatelessWidget {
  const _OverlayMetricPill({
    required this.label,
    required this.icon,
    this.shrinkLabel = false,
  });

  final String label;
  final IconData icon;
  final bool shrinkLabel;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: AppTextStyles.label.copyWith(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          if (shrinkLabel) Flexible(child: labelWidget) else labelWidget,
        ],
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
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
