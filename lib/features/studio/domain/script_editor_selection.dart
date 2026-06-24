import '../../screenplay/data/screenplay_draft.dart';

/// Selection state driving the three-column Script Studio workspace.
class ScriptEditorSelection {
  const ScriptEditorSelection({
    this.actIndex,
    this.sceneIndex,
    this.frameIndex,
  });

  final int? actIndex;
  final int? sceneIndex;

  /// When null with scene selected, filters center list to scene only.
  final int? frameIndex;

  static const none = ScriptEditorSelection();

  bool get hasScene =>
      actIndex != null && sceneIndex != null && actIndex! >= 0 && sceneIndex! >= 0;

  bool get hasFrame => hasScene && frameIndex != null && frameIndex! >= 0;

  ScriptEditorSelection copyWith({
    int? actIndex,
    int? sceneIndex,
    int? frameIndex,
    bool clearAct = false,
    bool clearScene = false,
    bool clearFrame = false,
  }) {
    return ScriptEditorSelection(
      actIndex: clearAct ? null : (actIndex ?? this.actIndex),
      sceneIndex: clearScene ? null : (sceneIndex ?? this.sceneIndex),
      frameIndex: clearFrame ? null : (frameIndex ?? this.frameIndex),
    );
  }

  ScriptEditorSelection selectScene(int act, int scene) {
    return ScriptEditorSelection(actIndex: act, sceneIndex: scene);
  }

  ScriptEditorSelection selectFrame(int act, int scene, int frame) {
    return ScriptEditorSelection(
      actIndex: act,
      sceneIndex: scene,
      frameIndex: frame,
    );
  }

  bool matchesRef(DraftFrameRef ref) {
    if (!hasFrame) return false;
    return actIndex == ref.actIndex &&
        sceneIndex == ref.sceneIndex &&
        frameIndex == ref.frameIndex;
  }

  bool matchesScene(int act, int scene) {
    return hasScene && actIndex == act && sceneIndex == scene;
  }

  bool shouldShowRef(DraftFrameRef ref) {
    if (!hasScene) return true;
    if (actIndex != ref.actIndex || sceneIndex != ref.sceneIndex) {
      return false;
    }
    return true;
  }
}
