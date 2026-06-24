import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/domain/shoot_params.dart';
import 'screenplay_editor_sections.dart';

typedef ActReorderCallback = void Function(int oldIndex, int newIndex);
typedef SceneMoveCallback = void Function(
  SceneDragData data,
  int toActIndex,
  int toInsertIndex,
);
typedef FrameMoveCallback = void Function(
  FrameDragData data,
  int toActIndex,
  SceneDraft toScene,
  int toInsertIndex,
);

class UploadStructureEditor extends StatefulWidget {
  const UploadStructureEditor({
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
  State<UploadStructureEditor> createState() => _UploadStructureEditorState();
}

class _UploadStructureEditorState extends State<UploadStructureEditor> {
  final _collapsedActs = <ActDraft>{};
  final _collapsedScenes = <SceneDraft>{};
  final _collapsedFrames = <FrameDraft>{};

  final _knownActs = <ActDraft>{};
  final _knownScenes = <SceneDraft>{};
  final _knownFrames = <FrameDraft>{};

  @override
  void initState() {
    super.initState();
    _applySmartDefaultsForNewItems();
  }

  @override
  void didUpdateWidget(covariant UploadStructureEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pruneStale();
    _applySmartDefaultsForNewItems();
  }

  void _pruneStale() {
    final acts = widget.draft.acts.toSet();
    final scenes = acts.expand((a) => a.scenes).toSet();
    final frames = scenes.expand((s) => s.frames).toSet();

    _collapsedActs.removeWhere((a) => !acts.contains(a));
    _collapsedScenes.removeWhere((s) => !scenes.contains(s));
    _collapsedFrames.removeWhere((f) => !frames.contains(f));
    _knownActs.removeWhere((a) => !acts.contains(a));
    _knownScenes.removeWhere((s) => !scenes.contains(s));
    _knownFrames.removeWhere((f) => !frames.contains(f));
  }

  void _applySmartDefaultsForNewItems() {
    final singleAct = widget.draft.acts.length == 1;

    for (final act in widget.draft.acts) {
      if (_knownActs.add(act) && !singleAct) {
        _collapsedActs.add(act);
      }

      final singleScene = act.scenes.length == 1;
      for (final scene in act.scenes) {
        if (_knownScenes.add(scene) && !singleScene) {
          _collapsedScenes.add(scene);
        }

        final singleFrame = scene.frames.length == 1;
        for (final frame in scene.frames) {
          if (_knownFrames.add(frame) && !singleFrame) {
            _collapsedFrames.add(frame);
          }
        }
      }
    }
  }

  bool _isActExpanded(ActDraft act) => !_collapsedActs.contains(act);

  bool _isSceneExpanded(SceneDraft scene) => !_collapsedScenes.contains(scene);

  bool _isFrameExpanded(FrameDraft frame) => !_collapsedFrames.contains(frame);

  void _toggleAct(ActDraft act) {
    setState(() {
      if (_collapsedActs.contains(act)) {
        _collapsedActs.remove(act);
      } else {
        _collapsedActs.add(act);
      }
    });
  }

  void _toggleScene(SceneDraft scene) {
    setState(() {
      if (_collapsedScenes.contains(scene)) {
        _collapsedScenes.remove(scene);
      } else {
        _collapsedScenes.add(scene);
      }
    });
  }

  void _toggleFrame(FrameDraft frame) {
    setState(() {
      if (_collapsedFrames.contains(frame)) {
        _collapsedFrames.remove(frame);
      } else {
        _collapsedFrames.add(frame);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('幕 · 场 · 画', style: AppTextStyles.title),
            const Spacer(),
            Text(
              '已选 ${widget.frameCount} 画',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: draft.acts.length,
          onReorderItem: widget.onReorderActs,
          itemBuilder: (context, actIndex) {
            final act = draft.acts[actIndex];
            return ActEditorSection(
              key: ValueKey('act-$actIndex'),
              act: act,
              actIndex: actIndex,
              onChanged: widget.onChanged,
              canRemove: widget.canRemoveAct(actIndex),
              onRemove: widget.onRemoveAct(actIndex),
              onAddScene: widget.onAddScene(actIndex),
              expanded: _isActExpanded(act),
              onToggleExpanded: () => _toggleAct(act),
              onMoveScene: (data, insertIndex) => widget.onMoveScene(
                data,
                actIndex,
                insertIndex,
              ),
              poolTags: widget.poolTags,
              onToggleActTag: (tag) => widget.onToggleActTag(actIndex, tag),
              sceneBuilder: (sceneIndex) {
                final scene = act.scenes[sceneIndex];
                return SceneEditorSection(
                  key: ValueKey('scene-$actIndex-$sceneIndex'),
                  scene: scene,
                  draft: draft,
                  actIndex: actIndex,
                  sceneIndex: sceneIndex,
                  onChanged: widget.onChanged,
                  canRemove: widget.canRemoveScene(actIndex, sceneIndex),
                  onRemove: widget.onRemoveScene(actIndex, sceneIndex),
                  frames: scene.frames,
                  onPickFrames: widget.onPickFrames(
                    FramePickTarget(
                      actIndex: actIndex,
                      sceneIndex: sceneIndex,
                    ),
                  ),
                  onRemoveFrame: (frameIndex) =>
                      widget.onRemoveFrame(actIndex, sceneIndex, frameIndex),
                  onCaptionChanged: (frameIndex, value) =>
                      widget.onCaptionChanged(
                    actIndex,
                    sceneIndex,
                    frameIndex,
                    value,
                  ),
                  onActionNoteChanged: (frameIndex, value) =>
                      widget.onActionNoteChanged(
                    actIndex,
                    sceneIndex,
                    frameIndex,
                    value,
                  ),
                  onSceneOverrideChanged: (override) =>
                      widget.onSceneOverrideChanged(
                    actIndex,
                    sceneIndex,
                    override,
                  ),
                  onFrameOverrideChanged: (frameIndex, override) =>
                      widget.onFrameOverrideChanged(
                    actIndex,
                    sceneIndex,
                    frameIndex,
                    override,
                  ),
                  expanded: _isSceneExpanded(scene),
                  onToggleExpanded: () => _toggleScene(scene),
                  isFrameExpanded: _isFrameExpanded,
                  onToggleFrame: _toggleFrame,
                  onMoveFrame: (data, insertIndex) => widget.onMoveFrame(
                    data,
                    actIndex,
                    scene,
                    insertIndex,
                  ),
                  poolTags: widget.poolTags,
                  onToggleSceneTag: (tag) =>
                      widget.onToggleSceneTag(actIndex, sceneIndex, tag),
                  onToggleFrameTag: (frameIndex, tag) =>
                      widget.onToggleFrameTag(
                    actIndex,
                    sceneIndex,
                    frameIndex,
                    tag,
                  ),
                );
              },
            );
          },
        ),
        TextButton.icon(
          onPressed: widget.onAddAct,
          icon: const Icon(Icons.add),
          label: const Text('添加幕'),
        ),
      ],
    );
  }
}
