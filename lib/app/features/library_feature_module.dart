import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rc0_core/rc0_core.dart';

import '../router/routes.dart';

/// Library shell contribution.
final class LibraryFeatureModule implements FeatureModule {
  const LibraryFeatureModule();

  @override
  String get id => 'library';

  @override
  List<RouteBase> get routes => const [];

  @override
  List<NavEntry> get navEntries => const [
        NavEntry(
          id: 'library',
          label: '库',
          routePath: AppRoutes.library,
          icon: Icons.collections_bookmark_outlined,
        ),
      ];

  @override
  Map<Type, Object> get ports => const {};
}
