import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/community/presentation/pages/community_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/screenplay/presentation/pages/screenplay_detail_page.dart';
import '../../features/shell/presentation/pages/adaptive_shell_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/upload/presentation/pages/upload_page.dart';
import 'routes.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.explore,
    routes: [
      GoRoute(
        path: AppRoutes.scriptDetail,
        name: 'script-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ScreenplayDetailPage(scriptId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.poseDetail,
        name: 'pose-detail',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null) return AppRoutes.explore;
          return AppRoutes.script(id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                name: 'explore',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ExplorePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                name: 'community',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CommunityPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.upload,
                name: 'upload',
                pageBuilder: (context, state) {
                  final editId = state.uri.queryParameters['edit'];
                  return NoTransitionPage(
                    child: UploadPage(editScriptId: editId),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tasks,
                name: 'tasks',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TasksPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                name: 'favorites',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FavoritesPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
