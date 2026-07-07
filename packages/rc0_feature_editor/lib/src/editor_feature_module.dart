import 'package:go_router/go_router.dart';
import 'package:rc0_core/rc0_core.dart';

import 'editor_routes.dart';

/// Placeholder [FeatureModule] until studio/upload pages migrate into this package.
final class EditorFeatureModule implements FeatureModule {
  const EditorFeatureModule();

  @override
  String get id => 'editor';

  @override
  List<RouteBase> get routes => const [
        // Shell branch routes are assembled in app via [EditorShellRoutes]
        // until editor pages migrate into this package.
      ];

  @override
  List<NavEntry> get navEntries => const [
        NavEntry(
          id: 'studio',
          label: '创作',
          routePath: EditorRoutes.studio,
        ),
      ];

  @override
  Map<Type, Object> get ports => const {};
}