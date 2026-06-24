import 'package:flutter/material.dart';

import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/domain/shoot_params.dart';
import '../../../../screenplay/domain/cine_params.dart';

/// Shared edit callbacks for script editor tabs and scene detail page.
class ScriptEditorActions {
  const ScriptEditorActions({
    required this.draft,
    required this.onChanged,
    required this.poolTags,
    required this.onPickFrames,
    required this.onRemoveFrame,
    required this.onCaptionChanged,
    required this.onActionNoteChanged,
    required this.onCineParamsChanged,
    required this.onPositivePromptChanged,
    required this.onNegativePromptChanged,
    required this.onSceneOverrideChanged,
    required this.onFrameOverrideChanged,
    required this.onToggleSceneTag,
    required this.onToggleFrameTag,
    required this.onMoveFrame,
    required this.canRemoveScene,
    required this.onRemoveScene,
    this.onSceneFieldChanged,
  });

  final ScreenplayDraft draft;
  final VoidCallback onChanged;
  final List<String> poolTags;
  final void Function(FramePickTarget target) onPickFrames;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)
      onRemoveFrame;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String value)
      onCaptionChanged;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String value)
      onActionNoteChanged;
  final void Function(
    int actIndex,
    int sceneIndex,
    int frameIndex,
    CineParams params,
  ) onCineParamsChanged;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String value)
      onPositivePromptChanged;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String value)
      onNegativePromptChanged;
  final void Function(int actIndex, int sceneIndex, ShootParams? override)
      onSceneOverrideChanged;
  final void Function(
    int actIndex,
    int sceneIndex,
    int frameIndex,
    ShootParams? override,
  ) onFrameOverrideChanged;
  final void Function(int actIndex, int sceneIndex, String tag) onToggleSceneTag;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String tag)
      onToggleFrameTag;
  final void Function(
    FrameDragData data,
    int toActIndex,
    SceneDraft toScene,
    int toInsertIndex,
  ) onMoveFrame;
  final bool Function(int actIndex, int sceneIndex) canRemoveScene;
  final Future<void> Function(int actIndex, int sceneIndex) onRemoveScene;
  final void Function(
    int actIndex,
    int sceneIndex, {
    String? title,
    String? location,
    String? timeOfDay,
    String? weather,
  })? onSceneFieldChanged;
}
