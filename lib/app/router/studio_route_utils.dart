import 'package:go_router/go_router.dart';

import 'routes.dart';

bool isStudioEditorRoute(GoRouterState state) {
  final path = state.uri.path;
  final matched = state.matchedLocation;
  if (path.startsWith('/studio/edit/') || matched.startsWith('/studio/edit/')) {
    return true;
  }
  if (path == AppRoutes.studioCreate ||
      matched == AppRoutes.studioCreate ||
      path.endsWith('/studio/create') ||
      path == AppRoutes.studioEditorCreate ||
      path.startsWith('${AppRoutes.studioEditorCreate}?')) {
    return true;
  }
  if (path == AppRoutes.studio || matched == AppRoutes.studio) {
    final edit = state.uri.queryParameters['edit'];
    return edit != null && edit.isNotEmpty;
  }
  return false;
}
