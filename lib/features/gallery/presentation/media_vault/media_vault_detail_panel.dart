import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../domain/media_vault_image.dart';
import 'media_vault_colors.dart';
import 'media_vault_image_card.dart';

/// Right-side detail panel for selected image.
class MediaVaultDetailPanel extends StatelessWidget {
  const MediaVaultDetailPanel({
    super.key,
    required this.image,
    required this.onClose,
    required this.onFavorite,
    this.related = const [],
    this.onRelatedTap,
    this.width = 320,
  });

  final MediaVaultImage image;
  final VoidCallback onClose;
  final VoidCallback onFavorite;
  final List<MediaVaultImage> related;
  final ValueChanged<MediaVaultImage>? onRelatedTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: MediaVaultColors.surface,
          border: Border(left: BorderSide(color: MediaVaultColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: MediaVaultColors.textSecondary,
                    onPressed: onClose,
                    tooltip: '关闭',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      image.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: image.isFavorite
                          ? MediaVaultColors.starGold
                          : MediaVaultColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onFavorite,
                    tooltip: '收藏',
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    color: MediaVaultColors.textSecondary,
                    onPressed: () {},
                    tooltip: '分享',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, size: 20),
                    color: MediaVaultColors.textSecondary,
                    onPressed: () {},
                    tooltip: '更多',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMd,
                  0,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingLg,
                ),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _Preview(image: image),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    image.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: MediaVaultColors.textPrimary,
                    ),
                  ),
                  if (image.rating > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < image.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: MediaVaultColors.starGold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacingMd),
                  _InfoRow(
                    label: '分辨率',
                    value: image.resolutionLabel,
                  ),
                  _InfoRow(
                    label: '文件大小',
                    value: image.fileSizeMb != null
                        ? '${image.fileSizeMb!.toStringAsFixed(1)} MB'
                        : '—',
                  ),
                  _InfoRow(
                    label: '格式',
                    value: image.isRaw ? 'RAW' : (image.format ?? '—'),
                  ),
                  if (image.createdAt != null)
                    _InfoRow(
                      label: '创建时间',
                      value: _formatDate(image.createdAt!),
                    ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  if (image.tags.isNotEmpty) ...[
                    const Text(
                      '标签',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MediaVaultColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: image.tags
                          .map(
                            (t) => Chip(
                              label: Text(t),
                              backgroundColor: MediaVaultColors.accentGlow,
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                color: MediaVaultColors.accent,
                              ),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                  if (image.exif.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingMd),
                    const Text(
                      'EXIF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MediaVaultColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...image.exif.entries.map(
                      (e) => _InfoRow(label: e.key, value: e.value),
                    ),
                  ],
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingMd),
                    const Text(
                      '相似图片',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MediaVaultColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final r = related[i];
                          return SizedBox(
                            width: 72,
                            child: MediaVaultImageCard(
                              image: r,
                              onTap: () => onRelatedTap?.call(r),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacingLg),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: MediaVaultColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('添加到专辑'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.image});

  final MediaVaultImage image;

  @override
  Widget build(BuildContext context) {
    if (image.hasNetworkImage) {
      final path =
          resolveNetworkImageUrl(image.displayUrl) ?? image.displayUrl;
      return Rc0Image(path: path, fit: BoxFit.cover);
    }
    final colors = image.placeholderColors ??
        [MediaVaultColors.surfaceElevated, MediaVaultColors.background];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
      ),
      child: Center(
        child: Icon(
          image.placeholderIcon ?? Icons.image_outlined,
          size: 64,
          color: MediaVaultColors.textPrimary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: MediaVaultColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: MediaVaultColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
