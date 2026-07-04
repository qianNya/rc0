import '../../screenplay/data/screenplay_draft.dart';
import '../domain/cine_camera_setup.dart';
import 'equipment_repository.dart';
import 'equipment_setup_mapper.dart';

/// Applies a [CineCameraSetup] to screenplay draft levels.
void applyCineSetupToDraft(
  ScreenplayDraft draft,
  CineCameraSetup setup, {
  int? actIndex,
  int? sceneIndex,
  int? frameIndex,
}) {
  final json = EquipmentSetupMapper.setupToJson(setup);

  if (actIndex == null || sceneIndex == null || frameIndex == null) {
    draft.cineSetupId = setup.id.isNotEmpty ? setup.id : null;
    draft.cineSetup = json;
    return;
  }

  if (actIndex < draft.acts.length &&
      sceneIndex < draft.acts[actIndex].scenes.length &&
      frameIndex <
          draft.acts[actIndex].scenes[sceneIndex].frames.length) {
    final frame =
        draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex];
    frame.cineSetupId = setup.id.isNotEmpty ? setup.id : null;
    frame.cineSetup = Map<String, dynamic>.from(json);
  }
}

CineCameraSetup? cineSetupFromDraftFrame(FrameDraft frame) {
  return EquipmentRepository.instance.resolveSetup(
    setupId: frame.cineSetupId,
    inlineSetup: frame.cineSetup,
  );
}

CineCameraSetup? cineSetupFromDraft(ScreenplayDraft draft) {
  return EquipmentRepository.instance.resolveSetup(
    setupId: draft.cineSetupId,
    inlineSetup: draft.cineSetup,
  );
}
