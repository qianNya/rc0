import 'package:flutter/widgets.dart';
import 'package:rc0_core/rc0_core.dart';

import '../../features/character/domain/character_entry.dart';
import '../../features/character/presentation/widgets/character_picker_sheet.dart';
import '../../features/scene/domain/scene_entry.dart';
import '../../features/scene/presentation/widgets/scene_picker_sheet.dart';
import '../../features/screenplay/data/screenplay_draft.dart';
import '../../features/screenplay/data/screenplay_scene_binding.dart';

SceneRef _toSceneRef(SceneEntry entry) => SceneRef(
      id: entry.id,
      title: entry.title,
      location: entry.location,
      description: entry.description,
      tags: List<String>.from(entry.tags),
      themes: List<String>.from(entry.themes),
    );

CharacterRef _toCharacterRef(CharacterEntry entry) => CharacterRef(
      id: entry.id,
      name: entry.name,
      appearance: entry.appearance,
    );

final class AppScenePickerPort implements ScenePickerPort {
  const AppScenePickerPort();

  @override
  Future<SceneRef?> pickScene(
    BuildContext context, {
    String? selectedSceneId,
  }) async {
    final picked = await ScenePickerSheet.show(
      context,
      selectedSceneId: selectedSceneId,
    );
    return picked == null ? null : _toSceneRef(picked);
  }
}

final class AppSceneBindingPort implements SceneBindingPort {
  const AppSceneBindingPort();

  @override
  Future<bool> pickAndApplyLibraryScene(
    BuildContext context,
    FrameBindingTarget target, {
    String? selectedSceneId,
  }) async {
    final draft = target.draft as ScreenplayDraft;
    final scene = draft.acts[target.actIndex].scenes[target.sceneIndex];
    final picked = await ScenePickerSheet.show(
      context,
      selectedSceneId: selectedSceneId ?? scene.sceneLibraryId,
    );
    if (picked == null || !context.mounted) return false;
    applyLibrarySceneToSceneDraft(picked, scene, draft);
    return true;
  }
}

final class AppCharacterPickerPort implements CharacterPickerPort {
  const AppCharacterPickerPort();

  @override
  Future<CharacterRef?> pickCharacter(
    BuildContext context, {
    int? selectedCharacterId,
  }) async {
    final picked = await CharacterPickerSheet.show(
      context,
      selectedCharacterId: selectedCharacterId,
    );
    return picked == null ? null : _toCharacterRef(picked);
  }
}

final class AppCharacterBindingPort implements CharacterBindingPort {
  const AppCharacterBindingPort();

  @override
  Future<CharacterRef?> pickAndApplyCharacter(
    BuildContext context,
    FrameBindingTarget target, {
    int? selectedCharacterId,
  }) async {
    final draft = target.draft as ScreenplayDraft;
    final frameIndex = target.frameIndex;
    if (frameIndex == null) return null;

    final frame = draft.acts[target.actIndex].scenes[target.sceneIndex].frames[frameIndex];
    final picked = await CharacterPickerSheet.show(
      context,
      selectedCharacterId: selectedCharacterId ?? frame.characterId,
    );
    if (picked == null) return null;

    ensureDraftCharacterLinked(draft, id: picked.id, name: picked.name);
    return _toCharacterRef(picked);
  }

  @override
  Future<CharacterRef?> createAndApplyCharacter(
    BuildContext context,
    FrameBindingTarget target,
  ) async {
    // Navigation handled by caller; this port only fetches after create id is known.
    return null;
  }
}
