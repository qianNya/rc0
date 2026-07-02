import '../../upload/domain/upload_image_file.dart';
import 'screenplay_draft.dart';

/// Stable ref for a frame reference image in publish `asset_map`.
String referenceImageRef(int actIdx, int sceneIdx, int frameIdx, int refIdx) =>
    'frame-$actIdx-$sceneIdx-$frameIdx-ref-$refIdx';

void applyReferenceImagesFromFrameMap(
  FrameDraft frameDraft,
  Map<String, dynamic> frameMap,
) {
  frameDraft.referenceImages.clear();
  final raw = frameMap['reference_local_paths'];
  if (raw is! List) return;

  for (final item in raw) {
    if (item is! String || item.isEmpty) continue;
    final normalized = item.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    final name = slash >= 0 ? normalized.substring(slash + 1) : normalized;
    frameDraft.referenceImages.add(
      UploadImageFile(path: item, name: name),
    );
  }
}

/// Writes reference image local paths into tree JSON from draft.
Map<String, dynamic> applyDraftReferenceImagesToTree(
  Map<String, dynamic> tree,
  ScreenplayDraft draft, {
  Map<UploadImageFile, String>? persistedPaths,
}) {
  final copy = Map<String, dynamic>.from(tree);
  final acts = copy['acts'] as List<dynamic>? ?? [];

  for (var actIndex = 0;
      actIndex < acts.length && actIndex < draft.acts.length;
      actIndex++) {
    final actNode = acts[actIndex] as Map<String, dynamic>;
    final scenes = actNode['scenes'] as List<dynamic>? ?? [];
    for (var sceneIndex = 0;
        sceneIndex < scenes.length &&
            sceneIndex < draft.acts[actIndex].scenes.length;
        sceneIndex++) {
      final sceneNode = scenes[sceneIndex] as Map<String, dynamic>;
      final frames = sceneNode['frames'] as List<dynamic>? ?? [];
      for (var frameIndex = 0;
          frameIndex < frames.length &&
              frameIndex <
                  draft.acts[actIndex].scenes[sceneIndex].frames.length;
          frameIndex++) {
        final frameMap = frames[frameIndex] as Map<String, dynamic>;
        final frameDraft =
            draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex];

        if (frameDraft.referenceImages.isEmpty) {
          frameMap.remove('reference_local_paths');
          frameMap.remove('reference_refs');
          continue;
        }

        final paths = <String>[];
        for (final ref in frameDraft.referenceImages) {
          final path = persistedPaths?[ref] ?? ref.path;
          if (path.isNotEmpty) paths.add(path);
        }
        if (paths.isEmpty) {
          frameMap.remove('reference_local_paths');
        } else {
          frameMap['reference_local_paths'] = paths;
        }
      }
    }
  }

  return copy;
}
