import '../domain/cine_params.dart';
import 'screenplay_draft.dart';

CineParams effectiveCineParamsForFrame(
  ScreenplayDraft draft,
  int actIndex,
  int sceneIndex,
  int frameIndex,
) {
  final frame = draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex];
  return frame.cineParams;
}

int draftTotalDurationSec(
  ScreenplayDraft draft, {
  int? filterActIndex,
  int? filterSceneIndex,
}) {
  var total = 0;
  for (var actIndex = 0; actIndex < draft.acts.length; actIndex++) {
    if (filterActIndex != null && actIndex != filterActIndex) continue;
    final act = draft.acts[actIndex];
    for (var sceneIndex = 0; sceneIndex < act.scenes.length; sceneIndex++) {
      if (filterSceneIndex != null && sceneIndex != filterSceneIndex) {
        continue;
      }
      for (final frame in act.scenes[sceneIndex].frames) {
        total += frame.cineParams.durationSec;
      }
    }
  }
  return total;
}

void applyCineParamsFromFrameMap(
  FrameDraft frameDraft,
  Map<String, dynamic> frameMap,
) {
  frameDraft.cineParams = CineParams.fromFrameMap(frameMap);
  final extra = frameMap['extra_params'];
  final extraMap = extra is Map<String, dynamic>
      ? extra
      : (extra is Map ? Map<String, dynamic>.from(extra) : <String, dynamic>{});
  frameDraft.positivePrompt =
      CineParams.promptsFromExtra(extraMap, 'positive_prompt') ?? '';
  frameDraft.negativePrompt =
      CineParams.promptsFromExtra(extraMap, 'negative_prompt') ?? '';
  final characterNote = extraMap['character_note'];
  if (characterNote is String) {
    frameDraft.characterNote = characterNote;
  }
  final characterId = frameMap['acgn_character_id'];
  if (characterId is num && characterId.toInt() > 0) {
    frameDraft.characterId = characterId.toInt();
  } else {
    frameDraft.characterId = null;
  }
  final cachedName = extraMap['character_name'];
  if (cachedName is String) {
    frameDraft.characterName = cachedName;
  }
}

void writeCineParamsToFrameMap(
  Map<String, dynamic> frameMap,
  FrameDraft frameDraft,
) {
  final cine = frameDraft.cineParams;
  frameMap['duration_sec'] = cine.durationSec;
  frameMap['shot_type'] = cine.shotType ?? '';
  if (cine.lensMm != null && cine.lensMm!.isNotEmpty) {
    frameMap['lens_mm'] = cine.lensMm;
  } else {
    frameMap.remove('lens_mm');
  }

  final existingExtra = frameMap['extra_params'];
  final extraMap = existingExtra is Map<String, dynamic>
      ? Map<String, dynamic>.from(existingExtra)
      : (existingExtra is Map
          ? Map<String, dynamic>.from(existingExtra)
          : <String, dynamic>{});

  extraMap.remove('angle');
  extraMap.remove('movement');
  extraMap.remove('composition');
  extraMap.remove('positive_prompt');
  extraMap.remove('negative_prompt');
  extraMap.remove('character_note');
  extraMap.remove('character_name');

  extraMap.addAll(
    cine.toExtraParams(
      positivePrompt: frameDraft.positivePrompt,
      negativePrompt: frameDraft.negativePrompt,
    ),
  );
  if (frameDraft.characterNote.trim().isNotEmpty) {
    extraMap['character_note'] = frameDraft.characterNote.trim();
  }
  if (frameDraft.characterId != null &&
      frameDraft.characterId! > 0 &&
      frameDraft.characterName.trim().isNotEmpty) {
    extraMap['character_name'] = frameDraft.characterName.trim();
  }

  if (frameDraft.characterId != null && frameDraft.characterId! > 0) {
    frameMap['acgn_character_id'] = frameDraft.characterId;
  } else {
    frameMap['acgn_character_id'] = null;
  }

  frameMap['extra_params'] = extraMap;
}

Iterable<FrameDraft> draftFramesInScope(
  ScreenplayDraft draft, {
  int? actIndex,
  int? sceneIndex,
}) sync* {
  for (var a = 0; a < draft.acts.length; a++) {
    if (actIndex != null && a != actIndex) continue;
    for (var s = 0; s < draft.acts[a].scenes.length; s++) {
      if (sceneIndex != null && s != sceneIndex) continue;
      yield* draft.acts[a].scenes[s].frames;
    }
  }
}
