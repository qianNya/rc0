import 'dart:async';

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
  bool _notifyScheduled = false;

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
    final hadActions = hasActions;
    final wasSaveBusy = this.saveBusy;
    this.onAddAct = onAddAct;
    this.onAddScene = onAddScene;
    this.onSaveLocal = onSaveLocal;
    this.saveBusy = saveBusy;
    if (hadActions != hasActions || wasSaveBusy != saveBusy) {
      _notifyListenersSoon();
    }
  }

  void ensureEditorSession() {
    if (_editorSessionActive) return;
    _editorSessionActive = true;
    hubMode = EditorHubMode.outline;
    _notifyListenersSoon();
  }

  void beginEditorSession() => ensureEditorSession();

  void attachHubCallbacks({
    required Object owner,
    required VoidCallback onAiDecompose,
    required VoidCallback onMore,
  }) {
    final hadCallbacks = hasHubCallbacks;
    final ownerChanged = _hubCallbackOwner != owner;
    _hubCallbackOwner = owner;
    this.onAiDecompose = onAiDecompose;
    this.onMore = onMore;
    if (ownerChanged || hadCallbacks != hasHubCallbacks) {
      _notifyListenersSoon();
    }
  }

  void detachHubCallbacks(Object owner) {
    if (_hubCallbackOwner != owner) return;
    _hubCallbackOwner = null;
    onAiDecompose = null;
    onMore = null;
    _notifyListenersSoon();
  }

  void setHubMode(EditorHubMode mode) {
    if (hubMode == mode) return;
    hubMode = mode;
    _notifyListenersSoon();
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
    _notifyListenersSoon();
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

  void _notifyListenersSoon() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    Future<void>.microtask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}
