import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/data/app_catalog.dart';
import 'glass/glass.dart';
import 'pose_cover_image.dart';

/// Full-bleed cinematic hero for the template market — Level 0 content.
class TemplateMarketHero extends StatelessWidget {
  const TemplateMarketHero({
    super.key,
    this.onViewTap,
    this.bleedUnderHeader = true,
    this.title,
    this.eyebrow,
    this.viewLabel = '查看',
    this.imagePath,
  });

  final VoidCallback? onViewTap;

  /// When true, hero spans the full screen width and can extend under the
  /// floating status bar / app bar.
  final bool bleedUnderHeader;

  final String? title;
  final String? eyebrow;
  final String? viewLabel;
  final String? imagePath;

  static const double aspectRatio = 2.35;

  @override
  Widget build(BuildContext context) {
    final banners = AppCatalog.discoveryBanners;
    final banner = banners.isNotEmpty ? banners.first : null;
    final width = MediaQuery.sizeOf(context).width;
    final height = width / aspectRatio;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColors = isDark
        ? const [
            AppColors.explorePlaceholderStart,
            AppColors.explorePlaceholderEnd,
          ]
        : const [
            Color(0xFFE4EBFA),
            Color(0xFFC9D6F2),
          ];

    final resolvedImage = imagePath ?? banner?.imagePath;
    final resolvedTitle = title ?? banner?.title ?? '电影构图模板合集';
    final resolvedEyebrow =
        eyebrow ?? banner?.eyebrow ?? '精选电影感构图参考';

    final bottomRadius = bleedUnderHeader
        ? const BorderRadius.vertical(
            bottom: Radius.circular(AppDimensions.radiusLg),
          )
        : BorderRadius.circular(AppDimensions.radiusLg);

    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: bottomRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (resolvedImage != null && resolvedImage.isNotEmpty)
              PoseCoverImage(
                imagePath: resolvedImage,
                expand: true,
                borderRadius: 0,
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: placeholderColors,
                  ),
                ),
                child: const Icon(
                  Icons.landscape_outlined,
                  size: 64,
                  color: Colors.white24,
                ),
              ),
            const Positioned.fill(child: _HeroScrim()),
            Positioned(
              left: AppDimensions.spacingLg,
              right: AppDimensions.spacingLg,
              bottom: AppDimensions.spacingLg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          resolvedTitle,
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          resolvedEyebrow,
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  GlassButton(
                    label: viewLabel ?? '查看',
                    onPressed: onViewTap,
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

class _HeroScrim extends StatelessWidget {
  const _HeroScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.heroScrimTop,
            AppColors.heroScrimMid,
            AppColors.heroScrimBottom,
          ],
          stops: [0, 0.45, 1],
        ),
      ),
    );
  }
}
