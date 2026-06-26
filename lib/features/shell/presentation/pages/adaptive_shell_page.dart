import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/shell_nav_items.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    // Desktop: child pages (e.g. ExplorePage) own the full viewport chrome.
    if (isDesktop) {
      return navigationShell;
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _mobileSelectedIndex(),
        onItemSelected: (index) {
          _goToBranch(mobileNavItems[index].branchIndex!);
        },
      ),
    );
  }
}
