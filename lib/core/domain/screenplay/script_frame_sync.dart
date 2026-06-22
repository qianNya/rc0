import '../../../shared/widgets/image_preview_sync.dart';
import 'screenplay_image_resolver.dart';

typedef FrameTreeLocation = ({int actIdx, int sceneIdx, int frameIdx});

List<FrameTreeLocation> frameLocationsFromTree(Map<String, dynamic> tree) {
  final locations = <FrameTreeLocation>[];
  final acts = tree['acts'] as List<dynamic>? ?? [];
  for (var actIdx = 0; actIdx < acts.length; actIdx++) {
    final scenes =
        (acts[actIdx] as Map<String, dynamic>)['scenes'] as List<dynamic>? ??
            [];
    for (var sceneIdx = 0; sceneIdx < scenes.length; sceneIdx++) {
      final frames =
          (scenes[sceneIdx] as Map<String, dynamic>)['frames']
                  as List<dynamic>? ??
              [];
      for (var frameIdx = 0; frameIdx < frames.length; frameIdx++) {
        locations.add((
          actIdx: actIdx,
          sceneIdx: sceneIdx,
          frameIdx: frameIdx,
        ));
      }
    }
  }
  return locations;
}

FrameTreeLocation? frameLocationAtGlobalIndex(
  Map<String, dynamic> tree,
  int globalIndex,
) {
  final locations = frameLocationsFromTree(tree);
  if (globalIndex < 0 || globalIndex >= locations.length) return null;
  return locations[globalIndex];
}

/// Builds preview sync info from a raw screenplay frame map.
ImagePreviewSyncInfo syncInfoFromFrameMap(Map<String, dynamic> frameMap) {
  final serverImageId = (frameMap['acgn_image_id'] as num?)?.toInt();
  final hasServerId = serverImageId != null && serverImageId > 0;
  final remoteUrl = ScreenplayImageResolver.frameRemoteUrl(frameMap);
  final hasRemote = ScreenplayImageResolver.hasRemoteUrl(remoteUrl);
  final localPath = ScreenplayImageResolver.frameLocalPath(frameMap);
  final hasLocal = ScreenplayImageResolver.localUploadPath(localPath) != null;

  if (hasServerId || hasRemote) {
    if (hasLocal) {
      return ImagePreviewSyncInfo(
        status: ImageSyncStatus.localAndRemote,
        serverImageId: hasServerId ? serverImageId : null,
      );
    }
    return ImagePreviewSyncInfo(
      status: ImageSyncStatus.remoteOnly,
      serverImageId: hasServerId ? serverImageId : null,
    );
  }

  if (hasLocal) {
    return ImagePreviewSyncInfo(status: ImageSyncStatus.localOnly);
  }

  return const ImagePreviewSyncInfo(status: ImageSyncStatus.localOnly);
}

List<ImagePreviewSyncInfo> syncInfosFromScreenplayTree(
  Map<String, dynamic> tree,
) {
  final frames = <ImagePreviewSyncInfo>[];
  final acts = tree['acts'] as List<dynamic>? ?? [];
  for (final act in acts) {
    final scenes =
        (act as Map<String, dynamic>)['scenes'] as List<dynamic>? ?? [];
    for (final scene in scenes) {
      final sceneFrames =
          (scene as Map<String, dynamic>)['frames'] as List<dynamic>? ?? [];
      for (final frame in sceneFrames) {
        frames.add(syncInfoFromFrameMap(frame as Map<String, dynamic>));
      }
    }
  }
  return frames;
}
