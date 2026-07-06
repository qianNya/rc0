import 'package:flutter/material.dart';

import '../../../../core/utils/image_url_utils.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../data/image_gallery_repository.dart';
import '../../data/image_tags_repository.dart';
import '../../domain/gallery_image.dart';

/// Opens the legacy full-screen image preview with tag editing.
void openGalleryPreview(
  BuildContext context, {
  required List<GalleryImage> items,
  required int index,
  void Function(String message)? showSnack,
}) {
  final paths = items
      .map((e) => resolveNetworkImageUrl(e.displayUrl) ?? e.displayUrl)
      .where((p) => p.isNotEmpty)
      .toList(growable: false);

  if (paths.isEmpty) {
    showSnack?.call('暂无可用预览地址');
    return;
  }

  final item = items[index.clamp(0, items.length - 1)];
  final path = resolveNetworkImageUrl(item.displayUrl) ?? item.displayUrl;
  var previewIndex = paths.indexOf(path);
  if (previewIndex < 0) previewIndex = 0;

  final tags = ImageTagsRepository.instance;
  final gallery = ImageGalleryRepository.instance;

  showImagePreview(
    context,
    imagePaths: paths,
    initialIndex: previewIndex,
    captions: items.map((e) => e.title).toList(),
    options: ImagePreviewOptions(
      sourceLabel: '我的图库',
      enableTagEditing: true,
      tagStates: items
          .map(
            (e) => ImagePreviewTagState(
              serverImageId: e.id,
              tags: e.tags,
              tagIds: e.tagIds,
            ),
          )
          .toList(),
      metadatas: items
          .map(ImagePreviewMetaInfo.fromGalleryImage)
          .toList(growable: false),
      onLoadSuggestedTags: () async {
        if (tags.tags.isEmpty) await tags.loadTags();
        return tags.suggestedNames;
      },
      onLoadMetadata: (previewIndex) async {
        final previewItem = items[previewIndex];
        final detail = await gallery.fetchDetail(previewItem.id);
        final image = detail.image;
        if (image == null) return null;
        return ImagePreviewMetaInfo.fromGalleryImage(image);
      },
      onSaveImageTags: (previewIndex, desired, currentIds) async {
        final previewItem = items[previewIndex];
        final error = await tags.applyTagsToImage(
          imageId: previewItem.id,
          currentTagIds: currentIds,
          desiredNames: desired,
        );
        if (error != null) {
          return (tags: previewItem.tags, tagIds: previewItem.tagIds, error: error);
        }
        final detail = await gallery.fetchDetail(previewItem.id);
        final image = detail.image ?? previewItem;
        return (tags: image.tags, tagIds: image.tagIds, error: null);
      },
      syncInfos: items
          .map((e) => ImagePreviewSyncInfo.uploaded(serverImageId: e.id))
          .toList(),
    ),
  );
}
