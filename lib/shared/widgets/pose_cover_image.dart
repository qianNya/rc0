import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/utils/image_url_utils.dart';
import 'image_preview.dart';
import 'rc0_widgets.dart';

class PoseCoverImage extends StatelessWidget {
  const PoseCoverImage({
    super.key,
    this.imagePath,
    this.aspectRatio = 0.85,
    this.borderRadius = AppDimensions.radiusMd,
    this.iconSize = 32,
    this.expand = false,
    this.enablePreview = false,
    this.previewGallery,
    this.previewIndex = 0,
    this.previewCaptions,
  });

  final String? imagePath;
  final double aspectRatio;
  final double borderRadius;
  final double iconSize;
  /// When true, fills the parent [Expanded] instead of using [AspectRatio].
  final bool expand;
  final bool enablePreview;
  final List<String>? previewGallery;
  final int previewIndex;
  final List<String>? previewCaptions;

  static bool isNetworkUrl(String path) => isNetworkImagePath(path);

  String? _resolvedPath(String? path) {
    if (path == null || path.isEmpty) return null;
    return resolveNetworkImageUrl(path) ?? path;
  }

  bool _hasImage(String? path) {
    final resolved = _resolvedPath(path);
    if (resolved == null || resolved.isEmpty) return false;
    if (isNetworkImagePath(resolved)) {
      return isValidNetworkImageUrl(resolved);
    }
    return _hasLocalImage(resolved);
  }

  bool _hasLocalImage(String path) =>
      path.isNotEmpty && File(path).existsSync();

  bool _canPreview(String? path) =>
      enablePreview && path != null && isPreviewableImagePath(path);

  void _openPreview(BuildContext context) {
    final path = imagePath;
    if (!_canPreview(path)) return;

    final gallery = previewGallery ?? [path!];
    final captions = previewCaptions;
    var index = previewIndex;
    if (previewGallery == null) {
      index = 0;
    } else if (path != null) {
      final found = gallery.indexOf(path);
      if (found >= 0) index = found;
    }

    showImagePreview(
      context,
      imagePaths: gallery,
      initialIndex: index,
      captions: captions,
    );
  }

  Widget _wrapPreview(BuildContext context, Widget child) {
    if (!_canPreview(imagePath)) return child;
    return GestureDetector(
      onTap: () => _openPreview(context),
      child: child,
    );
  }

  Widget _imageWidget(String path, {required bool fill}) {
    final resolved = _resolvedPath(path) ?? path;
    if (isNetworkImagePath(resolved)) {
      if (!isValidNetworkImageUrl(resolved)) {
        return _placeholder(fill: fill);
      }
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        width: fill ? double.infinity : null,
        height: fill ? double.infinity : null,
        errorBuilder: (_, _, _) => _placeholder(fill: fill),
      );
    }
    return Image.file(
      File(resolved),
      fit: BoxFit.cover,
      width: fill ? double.infinity : null,
      height: fill ? double.infinity : null,
      errorBuilder: (_, _, _) => _placeholder(fill: fill),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage = _hasImage(path);

    if (expand) {
      return _wrapPreview(
        context,
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius),
          ),
          child: hasImage
              ? _imageWidget(path!, fill: true)
              : _placeholder(fill: true),
        ),
      );
    }

    if (!hasImage) {
      return PlaceholderImage(
        aspectRatio: aspectRatio,
        borderRadius: borderRadius,
        iconSize: iconSize,
      );
    }

    return _wrapPreview(
      context,
      AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: _imageWidget(path!, fill: false),
        ),
      ),
    );
  }

  Widget _placeholder({required bool fill}) {
    if (fill) {
      return ColoredBox(
        color: AppColors.placeholder,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: iconSize,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return PlaceholderImage(
      aspectRatio: aspectRatio,
      borderRadius: borderRadius,
      iconSize: iconSize,
    );
  }
}
