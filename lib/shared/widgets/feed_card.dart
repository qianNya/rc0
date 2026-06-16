import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/data/app_catalog.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../features/screenplay/data/screenplay_display.dart';
import 'pose_cover_image.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.screenplay,
    this.onFork,
    this.onAuthorTap,
  });

  final Screenplay screenplay;
  final VoidCallback? onFork;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final author = screenplay.author.isNotEmpty
        ? screenplay.author
        : AppCatalog.placeholderAuthor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.script(screenplay.detailRouteId)),
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
                      borderRadius: 0,
                    ),
                    if (onFork != null)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: AppColors.accent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onFork,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.star_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
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
                      screenplay.title,
                      style: AppTextStyles.label.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: screenplay.ownerUserId != null && screenplay.ownerUserId! > 0
                          ? () {
                              if (onAuthorTap != null) {
                                onAuthorTap!();
                              } else {
                                context.push(AppRoutes.user(screenplay.ownerUserId!));
                              }
                            }
                          : null,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.placeholder,
                            backgroundImage: screenplay.authorAvatar != null &&
                                    screenplay.authorAvatar!.isNotEmpty
                                ? NetworkImage(screenplay.authorAvatar!)
                                : null,
                            child: screenplay.authorAvatar == null ||
                                    screenplay.authorAvatar!.isEmpty
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              author,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    EngagementRow(
                      likes: screenplay.likes,
                      comments: 0,
                      forks: screenplay.favorites,
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

class EngagementRow extends StatelessWidget {
  const EngagementRow({
    super.key,
    required this.likes,
    required this.comments,
    this.forks,
    this.views,
    this.compact = false,
  });

  final int likes;
  final int comments;
  final int? forks;
  final int? views;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(icon: Icons.favorite_border, value: _formatCount(likes)),
        SizedBox(width: compact ? 12 : 16),
        _StatItem(icon: Icons.chat_bubble_outline, value: _formatCount(comments)),
        if (forks != null) ...[
          SizedBox(width: compact ? 12 : 16),
          _StatItem(icon: Icons.call_split, value: _formatCount(forks!)),
        ],
        if (views != null) ...[
          const Spacer(),
          _StatItem(icon: Icons.visibility_outlined, value: _formatCount(views!)),
        ],
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
