import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/studio_route_utils.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/services/shell_nav_config_store.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/desktop/desktop_chrome.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/shell_bottom_fade_overlay.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/shell_nav_items.dart';
import '../../../studio/presentation/studio_editor_shell_bridge.dart';
import '../../../studio/presentation/widgets/studio_editor_save_button.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';
import '../../../upload/presentation/widgets/editor/editor_hub_bottom_bar.dart';
import '../utils/shell_nav_navigation.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/shell_create_glass_button.dart';
import '../widgets/shell_nav_config_sheet.dart';

class AdaptiveShellPage extends StatefulWidget {
  const AdaptiveShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<AdaptiveShellPage> createState() => _AdaptiveShellPageState();
}

class _AdaptiveShellPageState extends State<AdaptiveShellPage> {
  final _navConfig = ShellNavConfigStore.instance;
  bool _didSyncInitialTab = false;
  String? _lastSyncedFirstOptionId;

  @override
  void initState() {
    super.initState();
    _navConfig.addListener(_onNavConfigChanged);
    _navConfig.initialize();
  }

  @override
  void dispose() {
    _navConfig.removeListener(_onNavConfigChanged);
    super.dispose();
  }

  StatefulNavigationShell get navigationShell => widget.navigationShell;

  void _onNavConfigChanged() {
    if (!mounted || !_navConfig.isInitialized || _navConfig.slotCount == 0) return;
    final state = GoRouter.of(context).state;
    if (isStudioEditorRoute(state)) return;

    final first = _navConfig.optionForSlot(0);
    final shouldSync = !_didSyncInitialTab || _lastSyncedFirstOptionId != first.id;
    if (!shouldSync) return;

    _didSyncInitialTab = true;
    _lastSyncedFirstOptionId = first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _goToOptionAsRoot(first);
    });
  }

  void _goToOptionAsRoot(ShellNavOption option) {
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
    GoRouter.of(context).go(route);
  }

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  int _mobilePrimarySelectedIndex(
    String path,
    List<ShellNavItem> navItems,
  ) {
    if (navigationShell.currentIndex == mobileCreateNavItem.branchIndex) {
      return -1;
    }
    final selected = _navConfig.selectedSlotIndex(
      currentBranch: navigationShell.currentIndex,
      path: path,
    );
    if (selected >= 0) return selected;

    for (var i = 0; i < navItems.length; i++) {
      final item = navItems[i];
      if (item.branchIndex == navigationShell.currentIndex) {
        return i;
      }
      final route = item.stackRoute;
      if (route != null &&
          route.isNotEmpty &&
          (path == route || path.startsWith('$route/'))) {
        return i;
      }
    }

    return navItems.isNotEmpty ? 0 : -1;
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    final bridge = StudioEditorShellBridge.instance;
    final router = GoRouter.of(context);
    final createBranch = mobileCreateNavItem.branchIndex!;

    return ListenableBuilder(
      listenable: Listenable.merge([
        bridge,
        router.routerDelegate,
        _navConfig,
      ]),
      builder: (context, _) {
        final showEditorActions = isStudioEditorRoute(router.state);
        if (showEditorActions) {
          bridge.ensureEditorSession();
        }
        final showEditorHubBar = showEditorActions;
        final onCreate = navigationShell.currentIndex == createBranch;
        final path = router.state.uri.path;
        final navItems = _navConfig.navItems;

        void openNavConfig() => showShellNavConfigSheet(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.floatingBarMarginHorizontal,
            0,
            AppDimensions.floatingBarMarginHorizontal,
            AppDimensions.floatingBarMarginBottom,
          ),
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showEditorHubBar)
                  const EditorHubBottomBar()
                else if (navItems.isNotEmpty)
                  AppBottomNavBar(
                    wrapPadding: false,
                    items: navItems,
                    selectedIndex: _mobilePrimarySelectedIndex(path, navItems),
                    onItemSelected: (index) {
                      navigateShellNavOption(
                        context,
                        navigationShell,
                        _navConfig.optionForSlot(index),
                      );
                    },
                    onItemLongPress: (_) => openNavConfig(),
                    onBarLongPress: openNavConfig,
                  ),
                if (showEditorHubBar) ...[
                  const SizedBox(width: AppDimensions.bottomNavSecondaryTabGap),
                  StudioEditorShellGlassButton(
                    tooltip: 'AI 探索',
                    icon: Icons.auto_awesome_outlined,
                    onPressed: bridge.hasHubCallbacks
                        ? () => bridge.onAiDecompose!()
                        : null,
                  ),
                  const SizedBox(width: AppDimensions.bottomNavSecondaryTabGap),
                  StudioEditorShellGlassButton(
                    tooltip: '更多',
                    icon: Icons.more_horiz,
                    onPressed: bridge.hasHubCallbacks
                        ? () => bridge.onMore!()
                        : null,
                  ),
                ] else ...[
                  const SizedBox(width: AppDimensions.bottomNavSecondaryTabGap),
                  ShellCreateGlassButton(
                    selected: onCreate,
                    onPressed: () => _goToBranch(createBranch),
                  ),
                ],
                AnimatedSize(
                  duration: StudioEditorShellGlassButton.motionDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.none,
                  child: _EditorShellActions(
                    visible: showEditorActions,
                    saveLoading: bridge.saveBusy,
                    canSave: bridge.canSave,
                    onSave: bridge.saveFromShell,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final useSidebar = Breakpoints.useSidebarShell(context);

    if (useSidebar) {
      return ScrollNotificationObserver(
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.all(DesktopChrome.gap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DesktopSidebar(),
                const SizedBox(width: DesktopChrome.gap),
                Expanded(
                  child: ShellBranchTransition(
                    navigationShell: navigationShell,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bottomClearance = ShellInsets.mobileTabBarClearance(context);

    return ScrollNotificationObserver(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ShellInsets(
              bottomClearance: bottomClearance,
              child: ShellBranchTransition(navigationShell: navigationShell),
            ),
            const ShellBottomFadeOverlay(),
          ],
        ),
        bottomNavigationBar: _buildMobileBottomBar(context),
      ),
    );
  }
}

class _EditorShellActions extends StatefulWidget {
  const _EditorShellActions({
    required this.visible,
    required this.saveLoading,
    required this.canSave,
    required this.onSave,
  });

  final bool visible;
  final bool saveLoading;
  final bool canSave;
  final VoidCallback onSave;

  @override
  State<_EditorShellActions> createState() => _EditorShellActionsState();
}

class _EditorShellActionsState extends State<_EditorShellActions> {
  bool _onStage = false;

  @override
  void initState() {
    super.initState();
    _onStage = widget.visible;
  }

  @override
  void didUpdateWidget(covariant _EditorShellActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !_onStage) {
      setState(() => _onStage = true);
      return;
    }
    if (!widget.visible && _onStage) {
      Future<void>.delayed(
        StudioEditorShellGlassButton.exitSettleDuration,
        () {
          if (mounted && !widget.visible) {
            setState(() => _onStage = false);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_onStage) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: AppDimensions.bottomNavSecondaryTabGap),
        StudioEditorSaveButton(
          visible: widget.visible,
          loading: widget.saveLoading,
          onPressed: widget.canSave ? widget.onSave : null,
        ),
      ],
    );
  }
}
