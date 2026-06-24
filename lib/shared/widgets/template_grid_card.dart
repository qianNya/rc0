import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import '../../core/domain/screenplay/screenplay_display.dart';
import 'content_card_shared.dart';
import 'pose_cover_image.dart';
import 'profile_widgets.dart';

class TemplateGridCard extends StatelessWidget {
  const TemplateGridCard({
    super.key,
    required this.screenplay,
    this.compact = false,
    this.showBadge,
    this.showVisibilityBadge = false,
    this.onDelete,
    this.onMore,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectedToggle,
    this.onLongPressEnterSelection,
  });

  final Screenplay screenplay;
  final bool compact;
  final ContentBadgeType? showBadge;
  final bool showVisibilityBadge;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectedToggle;
  final VoidCallback? onLongPressEnterSelection;

  void _handleTap(BuildContext context) {
    if (selectionMode) {
      onSelectedToggle?.call();
      return;
    }
    context.push(AppRoutes.script(screenplay.detailRouteId));
  }

  @override
  Widget build(BuildContext context) {
    final view = screenplay.toCardView();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
        border: selectionMode && selected
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          onLongPress: selectionMode
              ? onSelectedToggle
              : onLongPressEnterSelection ?? onDelete,
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
                    if (showBadge != null)
                      Positioned(
                        top: 8,
                        left: selectionMode ? 36 : 8,
                        child: ContentCardBadge(type: showBadge!),
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
                    if (showVisibilityBadge &&
                        !screenplay.isLocal &&
                        screenplay.remoteScreenplayId != null &&
                        screenplay.visibility != null)
                      Positioned(
                        top: 8,
                        right: onDelete != null ? 40 : 8,
                        child: _VisibilityBadge(
                          isPublic: screenplay.visibility == 1,
                        ),
                      ),
                    if (onDelete != null && !selectionMode)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: AppColors.scrim,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onDelete,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ContentCardImageFooter(
                        categoryLabel: view.categoryLabel,
                        frameCount: view.frameCount,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 8 : 10,
                  compact ? 8 : 10,
                  compact ? 8 : 10,
                  compact ? 8 : 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.title,
                      style: AppTextStyles.label.copyWith(
                        fontSize: compact ? 13 : 14,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ContentCardEngagementRow(
                      likes: view.likes,
                      comments: view.commentCount,
                      onMore: onMore ??
                          () => showFeedMoreSheet(
                                context,
                                screenplay: screenplay,
                                onDelete: onDelete,
                              ),
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

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.isPublic});

  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPublic ? '公开' : '非公开',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
