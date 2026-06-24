import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../domain/gallery_image.dart';
import '../../../../shared/widgets/rc0_image.dart';

class GalleryImageTile extends StatelessWidget {
  const GalleryImageTile({
    super.key,
    required this.image,
    required this.onTap,
  });

  final GalleryImage image;
  final VoidCallback onTap;

  List<String> get _badges {
    if (image.tags.isNotEmpty) {
      return image.tags.take(2).toList(growable: false);
    }
    final title = image.title.trim();
    if (title.isNotEmpty && title.length <= 8) return [title];
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final path = resolveNetworkImageUrl(image.displayUrl) ?? image.displayUrl;
    final badges = _badges;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (path.isNotEmpty)
              Rc0Image(
                path: path,
                fit: BoxFit.cover,
                errorWidget: ColoredBox(
                  color: AppColors.placeholderDark,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              )
            else
              ColoredBox(
                color: AppColors.placeholderDark,
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            if (badges.isNotEmpty)
              Positioned(
                left: 6,
                bottom: 6,
                child: _GalleryCornerBadge(label: badges.first),
              ),
            if (badges.length > 1)
              Positioned(
                right: 6,
                bottom: 6,
                child: _GalleryCornerBadge(label: badges[1]),
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCornerBadge extends StatelessWidget {
  const _GalleryCornerBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
