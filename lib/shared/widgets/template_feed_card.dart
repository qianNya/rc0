import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import '../../features/screenplay/data/screenplay_display.dart';
import 'content_card_shared.dart';
import 'pose_cover_image.dart';

class TemplateFeedCard extends StatelessWidget {
  const TemplateFeedCard({
    super.key,
    required this.screenplay,
    this.onFork,
    this.forkLoading = false,
  });

  final Screenplay screenplay;
  final VoidCallback? onFork;
  final bool forkLoading;

  @override
  Widget build(BuildContext context) {
    final view = screenplay.toCardView();

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PoseCoverImage(
                      imagePath: screenplay.effectiveCoverImagePath,
                      expand: true,
                      borderRadius: 0,
                    ),
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: FeedTypeBadge(kind: FeedTypeBadgeKind.template),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.title,
                      style: AppTextStyles.label.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    FeedAuthorRow(author: view.author, showLevel: true),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FeedEngagementRow(
                            likes: view.likes,
                            comments: view.commentCount,
                            showBookmark: true,
                            bookmarks: view.favorites,
                          ),
                        ),
                        if (onFork != null) ...[
                          const SizedBox(width: 8),
                          FeedForkButton(
                            onPressed: onFork,
                            loading: forkLoading,
                          ),
                        ],
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
