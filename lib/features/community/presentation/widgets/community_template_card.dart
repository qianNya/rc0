import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/profile_widgets.dart';

String communityAspectRatioLabel(Screenplay screenplay) {
  for (final preset in AppCatalog.aspectRatioPresets) {
    if (screenplay.allTags.contains(preset)) return preset;
  }
  return '4:3';
}

String communityStructureLabel(Screenplay screenplay) {
  final acts = screenplay.actCount;
  final scenes = screenplay.sceneCount;
  if (acts <= 0 && scenes <= 0) return 'Template';
  if (acts > 0 && scenes > 0) return '$acts Acts · $scenes Scenes';
  if (acts > 0) return '$acts Acts';
  return '$scenes Scenes';
}

class CommunityTemplateCard extends StatelessWidget {
  const CommunityTemplateCard({
    super.key,
    required this.screenplay,
    this.showHotBadge = false,
  });

  final Screenplay screenplay;
  final bool showHotBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aspectLabel = communityAspectRatioLabel(screenplay);
    final structureLabel = communityStructureLabel(screenplay);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.script(screenplay.detailRouteId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PoseCoverImage(
                    imagePath: screenplay.effectiveCoverImagePath,
                    expand: true,
                  ),
                  if (showHotBadge)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: ContentCardBadge(type: ContentBadgeType.hot),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.scrim,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        aspectLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    screenplay.title,
                    style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FeedAuthorRow(
                    author: screenplay.author,
                    avatarUrl: screenplay.authorAvatar,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    structureLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatFeedCount(screenplay.likes),
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatFeedCount(screenplay.views),
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                      const Spacer(),
                      Text(
                        aspectLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: AppColors.accent,
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
    );
  }
}
