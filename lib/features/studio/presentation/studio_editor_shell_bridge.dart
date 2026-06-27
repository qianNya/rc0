import 'package:flutter/foundation.dart';

/// Bridges screenplay editor actions to [AdaptiveShellPage] bottom bar.
class StudioEditorShellBridge extends ChangeNotifier {
  StudioEditorShellBridge._();

  static final StudioEditorShellBridge instance = StudioEditorShellBridge._();

  VoidCallback? onAddAct;
  VoidCallback? onAddScene;
  Future<void> Function({bool goHome, bool? requireFrames})? onSaveLocal;
  bool saveBusy = false;

  bool get hasActions => onAddAct != null && onAddScene != null;

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

  /// Persists the current draft locally without cloud sync or navigation.
  Future<void> saveFromShell() async {
    final save = onSaveLocal;
    if (save == null || saveBusy) return;
    await save(
      goHome: false,
      requireFrames: false,
    );
  }

  void clear() {
    register(
      onAddAct: null,
      onAddScene: null,
      onSaveLocal: null,
      saveBusy: false,
    );
  }
}
