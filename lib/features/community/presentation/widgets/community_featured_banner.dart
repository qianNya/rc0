import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pose_cover_image.dart';

class CommunityFeaturedBanner extends StatelessWidget {
  const CommunityFeaturedBanner({
    super.key,
    this.title = '电影构图模板合集',
    this.subtitle = '精选电影感构图参考',
    this.buttonLabel = '查看合集',
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        12,
        AppDimensions.spacingMd,
        0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.accent, AppColors.profileGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 88,
              height: 88,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? PoseCoverImage(imagePath: imageUrl, expand: true)
                  : Container(
                      color: Colors.black26,
                      child: const Icon(
                        Icons.movie_filter_outlined,
                        size: 36,
                        color: Colors.white38,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
