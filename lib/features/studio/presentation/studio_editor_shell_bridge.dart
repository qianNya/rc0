import 'package:flutter/foundation.dart';

import '../../upload/presentation/widgets/editor/editor_quick_action_row.dart';

/// Bridges screenplay editor actions to [AdaptiveShellPage] bottom bar.
class StudioEditorShellBridge extends ChangeNotifier {
  StudioEditorShellBridge._();

  static final StudioEditorShellBridge instance = StudioEditorShellBridge._();

  VoidCallback? onAddAct;
  VoidCallback? onAddScene;
  Future<void> Function({bool goHome, bool? requireFrames})? onSaveLocal;
  bool saveBusy = false;

  EditorHubMode hubMode = EditorHubMode.outline;
  VoidCallback? onAiDecompose;
  VoidCallback? onMore;

  bool _editorSessionActive = false;
  Object? _hubCallbackOwner;

  bool get hasActions => onAddAct != null && onAddScene != null;

  /// Shell should show the editor hub tab bar while a screenplay session is open.
  bool get editorSessionActive => _editorSessionActive;

  bool get hasHubCallbacks => onAiDecompose != null && onMore != null;

  bool get canSave => onSaveLocal != null && !saveBusy;

  void register({
    VoidCallback? onAddAct,
    VoidCallback? onAddScene,
    Future<void> Function({bool goHome, bool? requireFrames})? onSaveLocal,
    bool saveBusy = false,
  }) {
    final changed = this.onAddAct != onAddAct ||
        this.onAddScene != onAddScene ||
        this.onSaveLocal != onSaveLocal ||
        this.saveBusy != saveBusy;
    this.onAddAct = onAddAct;
    this.onAddScene = onAddScene;
    this.onSaveLocal = onSaveLocal;
    this.saveBusy = saveBusy;
    if (changed) notifyListeners();
  }

  void ensureEditorSession() {
    if (_editorSessionActive) return;
    _editorSessionActive = true;
    hubMode = EditorHubMode.outline;
    notifyListeners();
  }

  void beginEditorSession() => ensureEditorSession();

  void attachHubCallbacks({
    required Object owner,
    required VoidCallback onAiDecompose,
    required VoidCallback onMore,
  }) {
    _hubCallbackOwner = owner;
    this.onAiDecompose = onAiDecompose;
    this.onMore = onMore;
    notifyListeners();
  }

  void detachHubCallbacks(Object owner) {
    if (_hubCallbackOwner != owner) return;
    _hubCallbackOwner = null;
    onAiDecompose = null;
    onMore = null;
    notifyListeners();
  }

  void setHubMode(EditorHubMode mode) {
    if (hubMode == mode) return;
    hubMode = mode;
    notifyListeners();
  }

  /// Persists the current draft locally without cloud sync or navigation.
  Future<void> saveFromShell() async {
    final save = onSaveLocal;
    if (save == null || saveBusy) return;
    await save(
      goHome: false,
      requireFrames: false,
    );
  }

  void endEditorSession() {
    _editorSessionActive = false;
    _hubCallbackOwner = null;
    onAiDecompose = null;
    onMore = null;
    hubMode = EditorHubMode.outline;
    notifyListeners();
  }

  void clear() {
    register(
      onAddAct: null,
      onAddScene: null,
      onSaveLocal: null,
      saveBusy: false,
    );
    endEditorSession();
  }
}
