import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/action/presentation/pages/action_wiki_page.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/gallery/presentation/pages/my_gallery_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/character/presentation/pages/character_ai_page.dart';
import '../../features/character/presentation/pages/character_create_page.dart';
import '../../features/character/presentation/pages/character_detail_page.dart';
import '../../features/character/presentation/pages/character_edit_page.dart';
import '../../features/character/presentation/pages/character_list_page.dart';
import '../../features/character/presentation/pages/my_characters_page.dart';
import '../../features/scene/presentation/pages/my_scenes_page.dart';
import '../../features/scene/presentation/pages/scene_ai_page.dart';
import '../../features/scene/presentation/pages/scene_create_page.dart';
import '../../features/scene/presentation/pages/scene_detail_page.dart';
import '../../features/scene/presentation/pages/scene_edit_page.dart';
import '../../features/scene/presentation/pages/scene_list_page.dart';
import '../../features/ip/presentation/pages/ip_detail_page.dart';
import '../../features/ip/presentation/pages/ip_edit_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_about_page.dart';
import '../../features/profile/presentation/pages/profile_coming_soon_page.dart';
import '../../features/profile/presentation/pages/profile_likes_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_works_page.dart';
import '../../features/screenplay/presentation/pages/screenplay_detail_page.dart';
import '../../features/shell/presentation/pages/adaptive_shell_page.dart';
import '../../features/shell/presentation/pages/wiki_hub_page.dart';
import '../../features/studio/presentation/pages/script_studio_create_page.dart';
import '../../features/studio/presentation/pages/script_studio_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/user/presentation/pages/user_profile_page.dart';
import '../../features/upload/presentation/pages/ai_creation_hub_page.dart';
import '../../features/upload/presentation/pages/frame_editor_detail_page.dart';
import '../../features/upload/presentation/pages/scene_editor_detail_page.dart';
import '../../features/upload/presentation/pages/shoot_preset_picker_page.dart';
import '../../features/upload/presentation/widgets/script_editor/script_editor_actions.dart';
import 'routes.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static const _protectedRoutes = <String>[
    AppRoutes.library,
    AppRoutes.favorites,
    AppRoutes.tasks,
    AppRoutes.messages,
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
      return AppRoutes.discovery;
    }

    return null;
  }

  static GoRoute _comingSoonRoute(String path, String title, {String? name}) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => ProfileComingSoonPage(title: title),
    );
  }

  static Map<String, dynamic>? _asMapExtra(GoRouterState state) {
    final extra = state.extra;
    if (extra is Map<String, dynamic>) return extra;
    return null;
  }

  static ScriptStudioCreatePage _scriptStudioCreatePage(GoRouterState state) {
    final characterId =
        int.tryParse(state.uri.queryParameters['characterId'] ?? '');
    final characterName = state.uri.queryParameters['characterName'];
    final editId = state.uri.queryParameters['edit'];
    return ScriptStudioCreatePage(
      editScriptId: editId,
      initialCharacterId: characterId,
      initialCharacterName: characterName,
    );
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.discovery,
    refreshListenable: AuthRepository.instance,
    redirect: _redirect,
    routes: [
      // Legacy path redirects
      GoRoute(
        path: AppRoutes.explore,
        redirect: (_, _) => AppRoutes.discovery,
      ),
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
        path: AppRoutes.community,
        name: 'community',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CommunityPage(),
      ),
      GoRoute(
        path: AppRoutes.follow,
        redirect: (_, _) => AppRoutes.discovery,
      ),
      GoRoute(
        path: AppRoutes.recommend,
        redirect: (_, _) => AppRoutes.discovery,
      ),
      GoRoute(
        path: AppRoutes.wikiScript,
        redirect: (_, _) => AppRoutes.scriptList,
      ),
      GoRoute(
        path: AppRoutes.wikiCharacter,
        redirect: (_, _) => AppRoutes.character,
      ),
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
        path: AppRoutes.scriptList,
        name: 'script-list',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CommunityPage(),
      ),
      GoRoute(
        path: AppRoutes.scriptExport,
        name: 'script-export',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const ProfileComingSoonPage(title: '导出分镜'),
      ),
      GoRoute(
        path: AppRoutes.scriptShotDetail,
        name: 'script-shot-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const ProfileComingSoonPage(title: '分镜详情'),
      ),
      GoRoute(
        path: AppRoutes.scriptSceneDetail,
        name: 'script-scene-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const ProfileComingSoonPage(title: '场景详情'),
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
        path: AppRoutes.imageAnalysis,
        name: 'image-analysis',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const ProfileComingSoonPage(title: 'AI 视觉分析'),
      ),
      GoRoute(
        path: AppRoutes.imageDetail,
        name: 'image-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const ProfileComingSoonPage(title: '图片详情'),
      ),
      GoRoute(
        path: AppRoutes.ipCreate,
        name: 'ip-create',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const IpEditPage(),
      ),
      GoRoute(
        path: AppRoutes.ipEdit,
        name: 'ip-edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return IpEditPage(ipId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.ipDetail,
        name: 'ip-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return IpDetailPage(ipId: id);
        },
      ),
      GoRoute(
        path: '/characters',
        redirect: (context, state) {
          final uri = state.uri;
          if (uri.path == '/characters/create') {
            final workId = uri.queryParameters['work_id'];
            if (workId != null && workId.isNotEmpty) {
              return '${AppRoutes.characterCreate}?work_id=$workId';
            }
            return AppRoutes.characterCreate;
          }
          final segments = uri.pathSegments;
          if (segments.length == 2) {
            return AppRoutes.characterDetailPath(int.parse(segments[1]));
          }
          final workId = uri.queryParameters['work_id'];
          if (workId != null && workId.isNotEmpty) {
            return '${AppRoutes.character}?work_id=$workId';
          }
          return AppRoutes.character;
        },
      ),
      GoRoute(
        path: '/characters/create',
        redirect: (context, state) {
          final workId = state.uri.queryParameters['work_id'];
          if (workId != null && workId.isNotEmpty) {
            return '${AppRoutes.characterCreate}?work_id=$workId';
          }
          return AppRoutes.characterCreate;
        },
      ),
      GoRoute(
        path: '/characters/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AppRoutes.characterDetailPath(int.parse(id));
        },
      ),
      GoRoute(
        path: AppRoutes.character,
        name: 'character',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final workId = int.tryParse(state.uri.queryParameters['work_id'] ?? '');
          return CharacterListPage(
            workId: workId != null && workId > 0 ? workId : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myCharacters,
        name: 'my-characters',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyCharactersPage(),
      ),
      GoRoute(
        path: AppRoutes.characterAi,
        name: 'character-ai',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CharacterAiPage(),
      ),
      GoRoute(
        path: AppRoutes.characterCreate,
        name: 'character-create',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final workId = int.tryParse(state.uri.queryParameters['work_id'] ?? '');
          final summary = state.uri.queryParameters['summary'];
          final cover = state.uri.queryParameters['cover'];
          return CharacterCreatePage(
            workId: workId != null && workId > 0 ? workId : null,
            initialSummary: summary,
            initialCoverPath: cover,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.characterEdit,
        name: 'character-edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return CharacterEditPage(characterId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.characterDetail,
        name: 'character-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return CharacterDetailPage(characterId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.studioEditorCreate,
        name: 'studio-editor-create',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => _scriptStudioCreatePage(state),
      ),
      GoRoute(
        path: AppRoutes.screenplays,
        redirect: (_, _) => AppRoutes.scenes,
      ),
      GoRoute(
        path: AppRoutes.myScenes,
        name: 'my-scenes',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyScenesPage(),
      ),
      GoRoute(
        path: AppRoutes.sceneAi,
        name: 'scene-ai',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SceneAiPage(),
      ),
      GoRoute(
        path: AppRoutes.sceneCreate,
        name: 'scene-create',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final description = state.uri.queryParameters['description'];
          final cover = state.uri.queryParameters['cover'];
          return SceneCreatePage(
            initialDescription: description,
            initialCoverPath: cover,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sceneEdit,
        name: 'scene-edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SceneEditPage(sceneId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.sceneDetail,
        name: 'scene-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SceneDetailPage(sceneId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.preset,
        name: 'preset-list',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final mode = parseShootPresetPickerMode(
            state.uri.queryParameters['mode'],
          );
          final scope = state.uri.queryParameters['scope'] ?? 'screenplay';
          final actIndex = int.tryParse(state.uri.queryParameters['act'] ?? '');
          final sceneIndex =
              int.tryParse(state.uri.queryParameters['scene'] ?? '');
          final frameIndex =
              int.tryParse(state.uri.queryParameters['frame'] ?? '');
          return ShootPresetPickerPage(
            mode: mode,
            scopeLabel: scopeLabelForPicker(
              scope: scope,
              actIndex: actIndex,
              sceneIndex: sceneIndex,
              frameIndex: frameIndex,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.presetDetail,
        name: 'preset-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const ProfileComingSoonPage(title: '预设详情'),
      ),
      _comingSoonRoute(AppRoutes.search, '全局搜索', name: 'search'),
      _comingSoonRoute(AppRoutes.settings, '设置', name: 'settings'),
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
        path: AppRoutes.library,
        name: 'library',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyGalleryPage(),
      ),
      GoRoute(
        path: AppRoutes.messages,
        name: 'messages',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const ProfileComingSoonPage(title: '消息'),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final tab =
              int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return FavoritesPage(initialTab: tab);
        },
      ),
      GoRoute(
        path: AppRoutes.tasks,
        name: 'tasks',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: AppRoutes.poseDetail,
        name: 'pose-detail',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null) return AppRoutes.discovery;
          return AppRoutes.script(id);
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
      GoRoute(
        path: AppRoutes.studioEditScript,
        name: 'studio-edit-script',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final scriptId = state.pathParameters['scriptId'] ?? '';
          if (scriptId.isEmpty) return AppRoutes.studioCreate;
          return AppRoutes.studioEdit(scriptId);
        },
      ),
      GoRoute(
        path: AppRoutes.studioEditScene,
        name: 'studio-edit-scene',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final map = _asMapExtra(state);
          final actions = map?['actions'] as ScriptEditorActions?;
          final actIndex = map?['actIndex'] as int?;
          final sceneIndex = map?['sceneIndex'] as int?;
          final initialTabIndex = map?['initialTabIndex'] as int? ?? 0;
          final initialFrameIndex = map?['initialFrameIndex'] as int?;
          if (actions == null || actIndex == null || sceneIndex == null) {
            final scriptId = state.pathParameters['scriptId'] ?? '';
            return ScriptStudioCreatePage(
              editScriptId: scriptId.isEmpty ? null : scriptId,
            );
          }
          return SceneEditorDetailPage(
            actions: actions,
            actIndex: actIndex,
            sceneIndex: sceneIndex,
            initialTabIndex: initialTabIndex,
            initialFrameIndex: initialFrameIndex,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.studioEditFrame,
        name: 'studio-edit-frame',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final map = _asMapExtra(state);
          final actions = map?['actions'] as ScriptEditorActions?;
          final actIndex = map?['actIndex'] as int?;
          final sceneIndex = map?['sceneIndex'] as int?;
          final frameIndex = map?['frameIndex'] as int?;
          if (actions == null ||
              actIndex == null ||
              sceneIndex == null ||
              frameIndex == null) {
            final scriptId = state.pathParameters['scriptId'] ?? '';
            return ScriptStudioCreatePage(
              editScriptId: scriptId.isEmpty ? null : scriptId,
            );
          }
          return FrameEditorDetailPage(
            actions: actions,
            actIndex: actIndex,
            sceneIndex: sceneIndex,
            frameIndex: frameIndex,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createAiHubPath,
        name: 'create-ai-hub',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AiCreationHubPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discovery,
                name: 'discovery',
                pageBuilder: (context, state) {
                  final hubTab =
                      int.tryParse(state.uri.queryParameters['hubTab'] ?? '') ??
                          0;
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: WikiHubPage(initialTabIndex: hubTab),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.studio,
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
                      child: _scriptStudioCreatePage(state),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scenes,
                name: 'scenes',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SceneListPage(embeddedInHub: true),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProfilePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.action,
                name: 'action',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ActionWikiPage(embeddedInHub: true),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
