import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rc0_core/rc0_core.dart';

import '../router/routes.dart';

/// Explore / discovery shell contribution.
final class ExploreFeatureModule implements FeatureModule {
  const ExploreFeatureModule();

  @override
  String get id => 'explore';

  @override
  List<RouteBase> get routes => const [];

  @override
  List<NavEntry> get navEntries => const [
        NavEntry(
          id: 'discovery',
          label: '发现',
          routePath: AppRoutes.discovery,
          icon: Icons.explore_outlined,
        ),
      ];

  @override
  Map<Type, Object> get ports => const {};
}
