import '../../screenplay/data/screenplay_draft.dart';
import '../../screenplay/domain/shoot_params.dart';
import '../data/lighting_scheme_mapper.dart';
import '../domain/lighting_scheme.dart';

/// Applies a lighting scheme to screenplay draft levels.
void applyLightingSchemeToDraft(
  ScreenplayDraft draft,
  LightingScheme scheme, {
  int? actIndex,
  int? sceneIndex,
  int? frameIndex,
}) {
  final shoot = LightingSchemeMapper.shootParamsFromScheme(scheme);
  final rigJson = LightingSchemeMapper.rigToJson(scheme);

  if (actIndex == null || sceneIndex == null || frameIndex == null) {
    draft.defaultParams = ShootParams(
      device: draft.defaultParams.device,
      aspectRatio: draft.defaultParams.aspectRatio,
      lighting: shoot.lighting,
    );
    draft.lightingSchemeId = scheme.id;
    draft.lightingRig = rigJson;
    return;
  }

  if (actIndex < draft.acts.length &&
      sceneIndex < draft.acts[actIndex].scenes.length &&
      frameIndex <
          draft.acts[actIndex].scenes[sceneIndex].frames.length) {
    final frame =
        draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex];
    final base = draft.defaultParams;
    frame.paramOverride = ShootParams(
      device: frame.paramOverride?.device ?? base.device,
      aspectRatio: frame.paramOverride?.aspectRatio ?? base.aspectRatio,
      lighting: shoot.lighting,
    );
    frame.lightingSchemeId = scheme.id;
    frame.lightingRig = rigJson;
  }
}

LightingScheme? lightingSchemeFromDraftFrame(FrameDraft frame) {
  return LightingSchemeMapper.rigFromJson(frame.lightingRig);
}
