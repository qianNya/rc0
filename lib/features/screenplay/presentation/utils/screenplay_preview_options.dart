import '../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../core/domain/screenplay/script_frame_sync.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../data/screenplay_tree_document.dart';
import '../../../../core/domain/screenplay/screenplay.dart';

ImagePreviewOptions buildScreenplayPreviewOptions({
  required Screenplay screenplay,
  ScreenplayTreeDocument? document,
  Future<bool> Function(int actIdx, int sceneIdx, int frameIdx)? onUploadFrame,
}) {
  final tree = document?.tree;
  final syncInfos = tree == null
      ? screenplay.allFrames
          .map((frame) => frame.isRemoteUploaded
              ? ImagePreviewSyncInfo.uploaded()
              : const ImagePreviewSyncInfo(status: ImageSyncStatus.localOnly))
          .toList()
      : syncInfosFromScreenplayTree(tree);

  return ImagePreviewOptions(
    sourceLabel: screenplay.title,
    syncInfos: syncInfos,
    onUpload: tree != null && onUploadFrame != null
        ? (index) async {
            final location = frameLocationAtGlobalIndex(tree, index);
            if (location == null) return false;
            return onUploadFrame(
              location.actIdx,
              location.sceneIdx,
              location.frameIdx,
            );
          }
        : null,
  );
}
