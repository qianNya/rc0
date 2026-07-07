import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rc0_feature_editor/rc0_feature_editor.dart';

import '../../features/studio/presentation/pages/script_studio_create_page.dart';
import '../../features/studio/presentation/pages/script_studio_page.dart';
import 'routes.dart';

/// App-layer route builders contributed by the editor feature module.
///
/// Route *paths* live in [EditorRoutes]; page builders stay in app until
/// studio/upload presentation migrates into `rc0_feature_editor`.
abstract final class EditorShellRoutes {
  static StatefulShellBranch studioShellBranch({
    required ScriptStudioCreatePage Function(GoRouterState state)
        scriptStudioCreatePage,
  }) {
    return StatefulShellBranch(
      routes: [
        GoRoute(
          path: EditorRoutes.studio,
          name: 'studio',
          pageBuilder: (context, state) {
            final editId = state.uri.queryParameters['edit'];
            final child = editId != null && editId.isNotEmpty
                ? ScriptStudioCreatePage(editScriptId: editId)
                : const ScriptStudioPage();
            return NoTransitionPage(
              key: state.pageKey,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: 'create',
              name: 'studio-create',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: scriptStudioCreatePage(state),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static List<RouteBase> get legacyRedirects => [
        GoRoute(
          path: AppRoutes.upload,
          redirect: (context, state) {
            final edit = state.uri.queryParameters['edit'];
            if (edit != null && edit.isNotEmpty) {
              return AppRoutes.studioEdit(edit);
            }
            return AppRoutes.studioCreate;
          },
        ),
        GoRoute(
          path: AppRoutes.create,
          name: 'create',
          redirect: (context, state) {
            final edit = state.uri.queryParameters['edit'];
            if (edit != null && edit.isNotEmpty) {
              return AppRoutes.studioEdit(edit);
            }
            return AppRoutes.studioCreate;
          },
        ),
      ];
}
