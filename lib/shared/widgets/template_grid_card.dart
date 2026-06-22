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
    this.onDelete,
    this.onMore,
  });

  final Screenplay screenplay;
  final bool compact;
  final ContentBadgeType? showBadge;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final view = screenplay.toCardView();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              context.push(AppRoutes.script(screenplay.detailRouteId)),
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
                        left: 8,
                        child: ContentCardBadge(type: showBadge!),
                      ),
                    if (onDelete != null)
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
