import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final path = resolveNetworkImageUrl(image.displayUrl) ?? image.displayUrl;

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
                errorWidget: const ColoredBox(
                  color: Color(0xFF2A2A2A),
                  child: Icon(Icons.broken_image_outlined),
                ),
              )
            else
              const ColoredBox(
                color: Color(0xFF2A2A2A),
                child: Icon(Icons.image_outlined),
              ),
            if (image.title.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  color: Colors.black54,
                  child: Text(
                    image.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
