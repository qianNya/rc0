import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import '../../core/domain/screenplay/screenplay_display.dart';
import 'content_card_shared.dart';
import 'glass/glass.dart';
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

    return GlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      onTap: () => context.push(AppRoutes.script(screenplay.detailRouteId)),
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
                  top: AppDimensions.spacingMd,
                  left: AppDimensions.spacingMd,
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
                const SizedBox(height: AppDimensions.spacingSm),
                FeedAuthorRow(author: view.author, showLevel: true),
                const SizedBox(height: AppDimensions.spacingSm),
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
                      const SizedBox(width: AppDimensions.spacingSm),
                      GlassButton(
                        label: 'Fork',
                        icon: Icons.call_split,
                        filled: true,
                        loading: forkLoading,
                        onPressed: onFork,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
