import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/shell_nav_config_store.dart';

void navigateShellNavOption(
  BuildContext context,
  StatefulNavigationShell navigationShell,
  ShellNavOption option,
) {
  final branch = option.branchIndex;
  if (branch != null) {
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
    return;
  }

  final route = option.route;
  if (route == null || route.isEmpty) return;

  if (option.usePush) {
    context.push(route);
    return;
  }
  context.go(route);
}
