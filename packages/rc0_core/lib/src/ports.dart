import 'package:flutter/widgets.dart';

/// Target frame/scene in a screenplay draft (draft is [Object] to keep rc0_core free of feature types).
@immutable
class FrameBindingTarget {
  const FrameBindingTarget({
    required this.draft,
    required this.actIndex,
    required this.sceneIndex,
    this.frameIndex,
  });

  final Object draft;
  final int actIndex;
  final int sceneIndex;
  final int? frameIndex;
}

@immutable
class SceneRef {
  const SceneRef({
    required this.id,
    this.title,
    this.location,
    this.description,
    this.tags = const [],
    this.themes = const [],
  });

  final String id;
  final String? title;
  final String? location;
  final String? description;
  final List<String> tags;
  final List<String> themes;
}

@immutable
class CharacterRef {
  const CharacterRef({
    required this.id,
    this.name,
    this.appearance,
    this.defaultCostumeId,
    this.styleLabel,
  });

  final int id;
  final String? name;
  final String? appearance;
  final int? defaultCostumeId;
  final String? styleLabel;
}

enum PresetScope { action, lighting, camera, shoot }

@immutable
class PresetRef {
  const PresetRef({required this.id, required this.scope, this.label});
  final String id;
  final PresetScope scope;
  final String? label;
}

/// Editor consumes these ports; app shell injects feature implementations.
abstract interface class ScenePickerPort {
  Future<SceneRef?> pickScene(
    BuildContext context, {
    String? selectedSceneId,
  });
}

abstract interface class CharacterPickerPort {
  Future<CharacterRef?> pickCharacter(
    BuildContext context, {
    int? selectedCharacterId,
  });
}

/// Pick + apply library scene to a scene draft node.
abstract interface class SceneBindingPort {
  Future<bool> pickAndApplyLibraryScene(
    BuildContext context,
    FrameBindingTarget target, {
    String? selectedSceneId,
  });
}

/// Pick + apply character to a frame; returns applied [CharacterRef] or null if cleared/cancelled.
abstract interface class CharacterBindingPort {
  Future<CharacterRef?> pickAndApplyCharacter(
    BuildContext context,
    FrameBindingTarget target, {
    int? selectedCharacterId,
  });

  Future<CharacterRef?> createAndApplyCharacter(BuildContext context, FrameBindingTarget target);
}

abstract interface class LightingBindingPort {
  String displayLabel(FrameBindingTarget target);

  Future<bool> pickQuick(BuildContext context, FrameBindingTarget target);

  Future<bool> pickFromHub(
    BuildContext context,
    FrameBindingTarget target, {
    int? characterId,
    String? schemeId,
  });
}

abstract interface class CameraBindingPort {
  String displayLabel(FrameBindingTarget target);

  Future<bool> pickQuick(BuildContext context, FrameBindingTarget target);

  Future<bool> pickControlSheet(BuildContext context, FrameBindingTarget target);

  Future<bool> pickFromHub(
    BuildContext context,
    FrameBindingTarget target, {
    String? setupId,
  });
}

abstract interface class PresetPickerPort {
  Future<PresetRef?> pickPreset(BuildContext context, PresetScope scope);
}
