import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/pose_cover_image.dart';

class ExploreFeaturedCarousel extends StatefulWidget {
  const ExploreFeaturedCarousel({super.key});

  @override
  State<ExploreFeaturedCarousel> createState() =>
      _ExploreFeaturedCarouselState();
}

class _ExploreFeaturedCarouselState extends State<ExploreFeaturedCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final banners = AppCatalog.discoveryBanners;
    if (banners.isEmpty) return const SizedBox.shrink();

    final height = Breakpoints.isDesktop(context) ? 240.0 : 188.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        12,
        AppDimensions.spacingMd,
        0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, index) {
                final banner = banners[index];
                return GestureDetector(
                  onTap: () => context.push(AppRoutes.community),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (banner.imagePath != null &&
                            banner.imagePath!.isNotEmpty)
                          PoseCoverImage(
                            imagePath: banner.imagePath,
                            expand: true,
                            borderRadius: 0,
                          )
                        else
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF3B4A6B),
                                  Color(0xFF1A1F2E),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.landscape_outlined,
                              size: 64,
                              color: Colors.white24,
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xCC000000),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner.eyebrow,
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  banner.title,
                                  style: AppTextStyles.title.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _index == i ? 8 : 6,
                  height: _index == i ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _index == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
