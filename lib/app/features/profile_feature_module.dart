import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rc0_core/rc0_core.dart';

import '../router/routes.dart';

/// Profile shell contribution.
final class ProfileFeatureModule implements FeatureModule {
  const ProfileFeatureModule();

  @override
  String get id => 'profile';

  @override
  List<RouteBase> get routes => const [];

  @override
  List<NavEntry> get navEntries => const [
        NavEntry(
          id: 'profile',
          label: '我的',
          routePath: AppRoutes.profile,
          icon: Icons.person_outline,
        ),
      ];

  @override
  Map<Type, Object> get ports => const {};
}
