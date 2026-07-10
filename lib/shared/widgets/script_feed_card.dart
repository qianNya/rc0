import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import '../../core/domain/screenplay/screenplay_display.dart';
import 'content_card_shared.dart';
import 'glass/glass.dart';
import 'pose_cover_image.dart';

/// Wide feed card for script-type screenplays in list feeds.
class ScriptFeedCard extends StatelessWidget {
  const ScriptFeedCard({
    super.key,
    required this.screenplay,
    this.onMore,
    this.onDelete,
    this.onFork,
  });

  final Screenplay screenplay;
  final VoidCallback? onMore;
  final VoidCallback? onDelete;
  final VoidCallback? onFork;

  @override
  Widget build(BuildContext context) {
    final view = screenplay.toCardView();

    return GlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      onTap: () => context.push(AppRoutes.script(screenplay.detailRouteId)),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PoseCoverImage(
              imagePath: screenplay.effectiveCoverImagePath,
              expand: true,
              borderRadius: 0,
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.heroScrimTop,
                      AppColors.heroScrimMid,
                      AppColors.heroScrimBottom,
                    ],
                    stops: [0.35, 0.65, 1],
                  ),
                ),
              ),
            ),
            const Positioned(
              top: AppDimensions.spacingMd,
              left: AppDimensions.spacingMd,
              child: FeedTypeBadge(kind: FeedTypeBadgeKind.script),
            ),
            Positioned(
              left: AppDimensions.spacingMd,
              right: AppDimensions.spacingMd,
              bottom: AppDimensions.spacingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    view.title,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  FeedAuthorRow(
                    author: view.author,
                    avatarUrl: screenplay.authorAvatar,
                    light: true,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  FeedEngagementRow(
                    likes: view.likes,
                    comments: view.commentCount,
                    light: true,
                    onMore: onMore ??
                        () => showFeedMoreSheet(
                              context,
                              screenplay: screenplay,
                              onFork: onFork,
                              onDelete: onDelete,
                            ),
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
