import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/desktop/desktop_chrome.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(DesktopChrome.gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DesktopSidebar(),
              const SizedBox(width: DesktopChrome.gap),
              Expanded(child: navigationShell),
            ],
          ),
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
      ),
    );
  }
}
