import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import '../../core/domain/screenplay/screenplay_display.dart';
import 'content_card_shared.dart';
import 'pose_cover_image.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              context.push(AppRoutes.script(screenplay.detailRouteId)),
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
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.55, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 12,
                  left: 12,
                  child: FeedTypeBadge(kind: FeedTypeBadgeKind.script),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
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
                      const SizedBox(height: 8),
                      FeedAuthorRow(
                        author: view.author,
                        avatarUrl: screenplay.authorAvatar,
                        light: true,
                      ),
                      const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}
