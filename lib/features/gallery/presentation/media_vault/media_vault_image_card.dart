import 'package:flutter/material.dart';

import '../../../../app/theme/app_motion.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../domain/media_vault_image.dart';
import 'media_vault_colors.dart';

/// Image-only tile — native aspect ratio, filename overlay top-left.
class MediaVaultImageCard extends StatelessWidget {
  const MediaVaultImageCard({
    super.key,
    required this.image,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  final MediaVaultImage image;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final format = image.formatLabel;
    final resolution = image.resolutionLabel;
    final sizeLabel = image.fileSizeLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? MediaVaultColors.accent
                  : MediaVaultColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? MediaVaultColors.accent.withValues(alpha: 0.14)
                    : MediaVaultColors.shadowSoft,
                blurRadius: selected ? 14 : 8,
                offset: Offset(0, selected ? 4 : 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: AspectRatio(
              aspectRatio: image.displayAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: MediaVaultColors.surfaceElevated,
                    child: _ImageArea(image: image),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.52),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 36,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.42),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    right: 52,
                    child: Text(
                      image.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 7,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (sizeLabel != '—')
                          _Badge(
                            label: sizeLabel,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        if (image.rating > 0 || image.isFavorite) ...[
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (image.rating > 0)
                                _StarRating(rating: image.rating),
                              if (image.isFavorite) ...[
                                if (image.rating > 0) const SizedBox(width: 3),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 8,
                                  color: MediaVaultColors.starGold,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: 5,
                    right: 5,
                    bottom: 5,
                    child: Row(
                      children: [
                        if (format != '—')
                          _Badge(
                            label: format,
                            color: image.isRaw
                                ? MediaVaultColors.statusSuccess
                                : Colors.black.withValues(alpha: 0.55),
                            textColor: image.isRaw
                                ? Colors.black
                                : Colors.white,
                          ),
                        const Spacer(),
                        if (resolution != '—')
                          _Badge(
                            label: resolution,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageArea extends StatelessWidget {
  const _ImageArea({required this.image});

  final MediaVaultImage image;

  @override
  Widget build(BuildContext context) {
    if (image.hasNetworkImage) {
      final path =
          resolveNetworkImageUrl(image.displayUrl) ?? image.displayUrl;
      return Rc0Image(
        path: path,
        fit: BoxFit.contain,
        errorWidget: _Placeholder(image: image),
      );
    }
    return _Placeholder(image: image);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.image});

  final MediaVaultImage image;

  @override
  Widget build(BuildContext context) {
    final colors = image.placeholderColors ??
        [MediaVaultColors.surfaceElevated, MediaVaultColors.surface];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          image.placeholderIcon ?? Icons.image_outlined,
          size: 18,
          color: MediaVaultColors.textTertiary,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: color.a < 1 ? 1 : 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 5.5,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1.1,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 5,
            color: MediaVaultColors.starGold,
          ),
          const SizedBox(width: 1),
          Text(
            '$rating',
            style: const TextStyle(
              fontSize: 5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

extension _GalleryMeta on MediaVaultImage {
  String get formatLabel {
    if (isRaw) return 'RAW';
    if (format != null && format!.isNotEmpty) return format!.toUpperCase();
    return '—';
  }

  String get fileSizeLabel {
    if (fileSizeMb == null || fileSizeMb! <= 0) return '—';
    if (fileSizeMb! < 1) {
      return '${(fileSizeMb! * 1024).round()} KB';
    }
    return '${fileSizeMb!.toStringAsFixed(1)} MB';
  }
}
