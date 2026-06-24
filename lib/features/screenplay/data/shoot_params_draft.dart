import '../domain/shoot_params.dart';
import 'screenplay_draft.dart';
import 'screenplay_draft_tags.dart';
import 'screenplay_tree_document.dart';

ShootParams effectiveParamsForScene(
  ScreenplayDraft draft,
  int actIndex,
  int sceneIndex,
) {
  final scene = draft.acts[actIndex].scenes[sceneIndex];
  return ShootParams.resolve(draft.defaultParams, scene.paramOverride);
}

ShootParams effectiveParamsForFrame(
  ScreenplayDraft draft,
  int actIndex,
  int sceneIndex,
  int frameIndex,
) {
  final sceneParams = effectiveParamsForScene(draft, actIndex, sceneIndex);
  final frame = draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex];
  return ShootParams.resolve(sceneParams, frame.paramOverride);
}

bool sceneHasParamOverride(SceneDraft scene) =>
    scene.paramOverride != null && scene.paramOverride!.hasAnyValue;

bool frameHasParamOverride(FrameDraft frame) =>
    frame.paramOverride != null && frame.paramOverride!.hasAnyValue;

ScreenplayDraft screenplayDraftFromTreeDocument(ScreenplayTreeDocument doc) {
  final screenplay = doc.toScreenplay();
  final draft = ScreenplayDraft.fromScreenplay(screenplay);

  final tree = doc.tree;
  final screenplayMap = tree['screenplay'] as Map<String, dynamic>?;
  if (screenplayMap != null) {
    final defaults = screenplayMap['shoot_defaults'];
    if (defaults is Map<String, dynamic>) {
      final parsed = ShootParams.fromJson(defaults);
      if (parsed.hasAnyValue) {
        draft.defaultParams = parsed;
      }
    }
  }

  final acts = tree['acts'] as List<dynamic>? ?? [];
  for (var actIndex = 0; actIndex < acts.length; actIndex++) {
    if (actIndex >= draft.acts.length) break;
    final actNode = acts[actIndex] as Map<String, dynamic>;
    final actMap = actNode['act'] as Map<String, dynamic>?;
    final actDraft = draft.acts[actIndex];
    if (actMap != null) {
      actDraft.tags = parseDraftTagList(actMap['tags']);
    }

    final scenes = actNode['scenes'] as List<dynamic>? ?? [];
    for (var sceneIndex = 0; sceneIndex < scenes.length; sceneIndex++) {
      if (sceneIndex >= draft.acts[actIndex].scenes.length) break;
      final sceneNode = scenes[sceneIndex] as Map<String, dynamic>;
      final sceneMap = sceneNode['scene'] as Map<String, dynamic>?;
      final sceneDraft = draft.acts[actIndex].scenes[sceneIndex];

      if (sceneMap != null) {
        sceneDraft.tags = parseDraftTagList(sceneMap['tags']);
        final override = sceneMap['shoot_override'];
        if (override is Map<String, dynamic>) {
          final parsed = ShootParams.fromJson(override);
          if (parsed.hasAnyValue) {
            sceneDraft.paramOverride = parsed;
          }
        }
      }

      final frames = sceneNode['frames'] as List<dynamic>? ?? [];
      for (var frameIndex = 0; frameIndex < frames.length; frameIndex++) {
        if (frameIndex >= sceneDraft.frames.length) break;
        final frameMap = frames[frameIndex] as Map<String, dynamic>;
        final frameDraft = sceneDraft.frames[frameIndex];

        frameDraft.tags = parseDraftTagList(frameMap['tags']);

        final frameOverride = frameMap['shoot_override'];
        if (frameOverride is Map<String, dynamic>) {
          final parsed = ShootParams.fromJson(frameOverride);
          if (parsed.hasAnyValue) {
            frameDraft.paramOverride = parsed;
            continue;
          }
        }
      }
    }
  }

  return draft;
}

ShootParams? shootDefaultsFromLocalDocument(ScreenplayTreeDocument? doc) {
  if (doc == null) return null;
  final screenplayMap = doc.tree['screenplay'] as Map<String, dynamic>?;
  if (screenplayMap == null) return null;
  final defaults = screenplayMap['shoot_defaults'];
  if (defaults is! Map<String, dynamic>) return null;
  final parsed = ShootParams.fromJson(defaults);
  return parsed.hasAnyValue ? parsed : null;
}
