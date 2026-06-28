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

  @override
  void initState() {
    super.initState();
    _navConfig.initialize();
  }

  StatefulNavigationShell get navigationShell => widget.navigationShell;

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  int _mobilePrimarySelectedIndex(String path) {
    if (navigationShell.currentIndex == mobileCreateNavItem.branchIndex) {
      return -1;
    }
    return _navConfig.selectedSlotIndex(
      currentBranch: navigationShell.currentIndex,
      path: path,
    );
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: showEditorHubBar
                      ? const EditorHubBottomBar()
                      : navItems.isEmpty
                          ? const SizedBox.shrink()
                          : AppBottomNavBar(
                              wrapPadding: false,
                              items: navItems,
                              selectedIndex: _mobilePrimarySelectedIndex(path),
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
      return Scaffold(
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
      );
    }

    final bottomClearance = ShellInsets.mobileTabBarClearance(context);

    return Scaffold(
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
