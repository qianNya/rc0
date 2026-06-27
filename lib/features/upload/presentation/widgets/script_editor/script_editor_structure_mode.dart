import 'package:flutter/material.dart';

import '../../../../../shared/widgets/shell_insets.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/domain/shoot_params.dart';
import '../upload_structure_editor.dart';

/// Thin wrapper around [UploadStructureEditor] for hub「剧本模式」.
class ScriptEditorStructureMode extends StatelessWidget {
  const ScriptEditorStructureMode({
    super.key,
    required this.draft,
    required this.frameCount,
    required this.onChanged,
    required this.canRemoveAct,
    required this.onRemoveAct,
    required this.onAddScene,
    required this.canRemoveScene,
    required this.onRemoveScene,
    required this.onPickFrames,
    required this.onRemoveFrame,
    required this.onCaptionChanged,
    required this.onActionNoteChanged,
    required this.onSceneOverrideChanged,
    required this.onFrameOverrideChanged,
    required this.onAddAct,
    required this.onReorderActs,
    required this.onMoveScene,
    required this.onMoveFrame,
    required this.poolTags,
    required this.onToggleActTag,
    required this.onToggleSceneTag,
    required this.onToggleFrameTag,
  });

  final ScreenplayDraft draft;
  final int frameCount;
  final VoidCallback onChanged;
  final bool Function(int actIndex) canRemoveAct;
  final VoidCallback Function(int actIndex) onRemoveAct;
  final VoidCallback Function(int actIndex) onAddScene;
  final bool Function(int actIndex, int sceneIndex) canRemoveScene;
  final VoidCallback Function(int actIndex, int sceneIndex) onRemoveScene;
  final VoidCallback Function(FramePickTarget target) onPickFrames;
  final void Function(int actIndex, int sceneIndex, int frameIndex) onRemoveFrame;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String value)
      onCaptionChanged;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String value)
      onActionNoteChanged;
  final void Function(int actIndex, int sceneIndex, ShootParams? override)
      onSceneOverrideChanged;
  final void Function(
    int actIndex,
    int sceneIndex,
    int frameIndex,
    ShootParams? override,
  ) onFrameOverrideChanged;
  final VoidCallback onAddAct;
  final ActReorderCallback onReorderActs;
  final SceneMoveCallback onMoveScene;
  final FrameMoveCallback onMoveFrame;
  final List<String> poolTags;
  final void Function(int actIndex, String tag) onToggleActTag;
  final void Function(int actIndex, int sceneIndex, String tag) onToggleSceneTag;
  final void Function(int actIndex, int sceneIndex, int frameIndex, String tag)
      onToggleFrameTag;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        ShellInsets.scrollBottom(context, extra: 16),
      ),
      child: UploadStructureEditor(
        draft: draft,
        frameCount: frameCount,
        onChanged: onChanged,
        canRemoveAct: canRemoveAct,
        onRemoveAct: onRemoveAct,
        onAddScene: onAddScene,
        canRemoveScene: canRemoveScene,
        onRemoveScene: onRemoveScene,
        onPickFrames: onPickFrames,
        onRemoveFrame: onRemoveFrame,
        onCaptionChanged: onCaptionChanged,
        onActionNoteChanged: onActionNoteChanged,
        onSceneOverrideChanged: onSceneOverrideChanged,
        onFrameOverrideChanged: onFrameOverrideChanged,
        onAddAct: onAddAct,
        onReorderActs: onReorderActs,
        onMoveScene: onMoveScene,
        onMoveFrame: onMoveFrame,
        poolTags: poolTags,
        onToggleActTag: onToggleActTag,
        onToggleSceneTag: onToggleSceneTag,
        onToggleFrameTag: onToggleFrameTag,
      ),
    );
  }
}
