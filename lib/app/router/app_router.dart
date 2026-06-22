import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_about_page.dart';
import '../../features/profile/presentation/pages/profile_coming_soon_page.dart';
import '../../features/profile/presentation/pages/profile_likes_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_works_page.dart';
import '../../features/screenplay/presentation/pages/screenplay_detail_page.dart';
import '../../features/shell/presentation/pages/adaptive_shell_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/user/presentation/pages/user_profile_page.dart';
import '../../features/upload/presentation/pages/upload_page.dart';
import 'routes.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static const _protectedRoutes = <String>[
    AppRoutes.upload,
    AppRoutes.tasks,
    AppRoutes.favorites,
    AppRoutes.profileWorks,
    AppRoutes.profileLikes,
    AppRoutes.profileEdit,
  ];

  static String? _redirect(BuildContext context, GoRouterState state) {
    final auth = AuthRepository.instance;
    final path = state.uri.path;
    final isAuthRoute =
        path == AppRoutes.login || path == AppRoutes.register;

    if (!auth.isLoggedIn && _protectedRoutes.contains(path)) {
      return AppRoutes.loginWithRedirect(state.uri.toString());
    }

    if (auth.isLoggedIn && auth.profile != null && isAuthRoute) {
      final from = state.uri.queryParameters['from'];
      if (from != null && from.isNotEmpty) return from;
      return AppRoutes.explore;
    }

    return null;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.explore,
    refreshListenable: AuthRepository.instance,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => LoginPage(
          redirectFrom: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => RegisterPage(
          redirectFrom: state.uri.queryParameters['from'],
        ),
      ),
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
        path: AppRoutes.userProfile,
        name: 'user-profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return UserProfilePage(userId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.profileWorks,
        name: 'profile-works',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileWorksPage(),
      ),
      GoRoute(
        path: AppRoutes.profileLikes,
        name: 'profile-likes',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileLikesPage(),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        name: 'profile-edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.profileAbout,
        name: 'profile-about',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileAboutPage(),
      ),
      GoRoute(
        path: AppRoutes.profileComingSoon,
        name: 'profile-coming-soon',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? '功能';
          return ProfileComingSoonPage(title: title);
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
                pageBuilder: (context, state) {
                  final tab =
                      int.tryParse(state.uri.queryParameters['tab'] ?? '') ??
                          0;
                  return NoTransitionPage(
                    child: FavoritesPage(initialTab: tab),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
