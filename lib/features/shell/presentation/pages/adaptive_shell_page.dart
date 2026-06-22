import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/shell_nav_items.dart';
import '../widgets/desktop_sidebar.dart';

class AdaptiveShellPage extends StatelessWidget {
  const AdaptiveShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  int _mobileSelectedIndex() {
    final branch = navigationShell.currentIndex;
    final match =
        mobileNavItems.indexWhere((item) => item.branchIndex == branch);
    return match >= 0 ? match : 0;
  }

  void _onDesktopNavItem(ShellNavItem item, BuildContext context) {
    if (item.stackRoute != null) {
      context.push(item.stackRoute!);
      return;
    }
    if (item.branchIndex != null) {
      _goToBranch(item.branchIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            DesktopSidebar(
              currentBranch: navigationShell.currentIndex,
              onNavItemTap: (item) => _onDesktopNavItem(item, context),
              onProfileTap: () => _goToBranch(4),
              onUploadTap: () => _goToBranch(2),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _mobileSelectedIndex(),
        onItemSelected: (index) {
          _goToBranch(mobileNavItems[index].branchIndex!);
        },
        onCreateTap: () => _goToBranch(2),
      ),
    );
  }
}
