import 'editor_save_status.dart';

/// Immutable editor session snapshot (package boundary for controller migration).
class EditorSessionSnapshot {
  const EditorSessionSnapshot({
    required this.saveStatus,
    required this.isPublishing,
    required this.isPicking,
    required this.canUndo,
    required this.canRedo,
    this.saveError,
    this.lastSavedAt,
  });

  final EditorSaveStatus saveStatus;
  final bool isPublishing;
  final bool isPicking;
  final bool canUndo;
  final bool canRedo;
  final String? saveError;
  final DateTime? lastSavedAt;

  bool get isSaving => saveStatus == EditorSaveStatus.saving;

  bool get hasSaveError => saveStatus == EditorSaveStatus.error;
}

/// Open-mode flags for the screenplay editor host.
enum EditorOpenMode {
  create,
  editLocal,
  editRemote,
}
