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

class ExploreFeaturedSection extends StatelessWidget {
  const ExploreFeaturedSection({super.key, required this.items});

  final List<Screenplay> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final featured = items.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingSm * 2,
            0,
            AppDimensions.spacingSm * 2,
            AppDimensions.spacingSm,
          ),
          child: Text('为你推荐', style: AppTextStyles.title.copyWith(fontSize: 18)),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm * 2,
            ),
            itemCount: featured.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.spacingSm),
            itemBuilder: (context, index) {
              return _FeaturedCard(screenplay: featured[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  const _FeaturedCard({required this.screenplay});

  final Screenplay screenplay;

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final sp = widget.screenplay;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 320,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(AppRoutes.script(sp.detailRouteId)),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 200,
                  child: PoseCoverImage(
                    imagePath: sp.effectiveCoverImagePath,
                    expand: true,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FeedTypeBadge(kind: FeedTypeBadgeKind.script),
                        const SizedBox(height: 8),
                        Text(
                          sp.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        FeedAuthorRow(
                          author: sp.author,
                          avatarUrl: sp.authorAvatar,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.favorite_border, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              formatFeedCount(sp.likes),
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.bookmark_border, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              formatFeedCount(sp.favorites),
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
