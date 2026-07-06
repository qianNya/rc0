import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../domain/media_vault_image.dart';
import 'media_vault_colors.dart';

class MediaVaultAlbumsGrid extends StatelessWidget {
  const MediaVaultAlbumsGrid({
    super.key,
    required this.albums,
    required this.onAlbumTap,
    this.onCreate,
  });

  final List<MediaAlbum> albums;
  final ValueChanged<MediaAlbum> onAlbumTap;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.spacingMd,
        crossAxisSpacing: AppDimensions.spacingMd,
        childAspectRatio: 1.1,
      ),
      itemCount: albums.length + 1,
      itemBuilder: (context, index) {
        if (index == albums.length) {
          return _CreateAlbumCard(onTap: onCreate);
        }
        final album = albums[index];
        return _AlbumCard(album: album, onTap: () => onAlbumTap(album));
      },
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album, required this.onTap});

  final MediaAlbum album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = album.coverColors ??
        [MediaVaultColors.surface, MediaVaultColors.surfaceElevated];
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MediaVaultColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                  ),
                  child: Center(
                    child: Icon(
                      album.coverIcon ?? Icons.photo_album_outlined,
                      size: 36,
                      color: MediaVaultColors.textPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MediaVaultColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${album.imageCount} 张',
                    style: const TextStyle(
                      fontSize: 11,
                      color: MediaVaultColors.textTertiary,
                    ),
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

class _CreateAlbumCard extends StatelessWidget {
  const _CreateAlbumCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MediaVaultColors.border,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: MediaVaultColors.textTertiary),
              SizedBox(height: 6),
              Text(
                '新建专辑',
                style: TextStyle(
                  fontSize: 12,
                  color: MediaVaultColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
