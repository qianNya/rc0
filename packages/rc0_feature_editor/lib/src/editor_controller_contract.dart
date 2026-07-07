import 'editor_open_args.dart';
import 'editor_save_status.dart';
import 'editor_session_state.dart';

/// Read-only view of editor controller state (package boundary).
///
/// App-layer [ScreenplayEditorController] implements this while UI
/// migrates into `rc0_feature_editor`.
abstract interface class EditorControllerView {
  EditorOpenMode get openMode;
  EditorSaveStatus get saveStatus;
  EditorSessionSnapshot get sessionSnapshot;

  bool get isEditing;
  bool get isCreateMode;
  bool get isPublishing;
  bool get isPicking;
  bool get canUndo;
  bool get canRedo;

  String? get saveError;
  DateTime? get lastSavedAt;

  /// Frame count for status header (app provides draft metrics).
  int get frameCount;

  /// e.g. "2幕 · 5场 · 12画"
  String get hierarchySummary;
}

/// Maps open args to editor mode flags.
EditorOpenMode editorOpenModeFromArgs(EditorOpenArgs args) {
  if (args.localScriptId != null && args.localScriptId!.isNotEmpty) {
    return EditorOpenMode.editLocal;
  }
  if (args.remoteScreenplayId != null) {
    return EditorOpenMode.editRemote;
  }
  return EditorOpenMode.create;
}
