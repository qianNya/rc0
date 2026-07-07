import 'editor_routes.dart';

/// Arguments for opening the screenplay editor (L4 Studio work page).
class EditorOpenArgs {
  const EditorOpenArgs({
    this.localScriptId,
    this.remoteScreenplayId,
    this.initialAct,
    this.initialScene,
    this.initialFrame,
  });

  final String? localScriptId;
  final int? remoteScreenplayId;
  final int? initialAct;
  final int? initialScene;
  final int? initialFrame;

  String get routePath {
    if (localScriptId != null && localScriptId!.isNotEmpty) {
      return '${EditorRoutes.studioEdit}/$localScriptId';
    }
    return EditorRoutes.studioEdit;
  }
}
