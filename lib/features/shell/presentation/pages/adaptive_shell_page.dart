import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/studio_route_utils.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/desktop/desktop_chrome.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/shell_nav_items.dart';
import '../../../studio/presentation/studio_editor_shell_bridge.dart';
import '../../../studio/presentation/widgets/studio_editor_save_button.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';
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

  double _shellBottomBarMaxWidth(BuildContext context, bool showEditorActions) {
    final width = MediaQuery.sizeOf(context).width;
    final margins = AppDimensions.floatingBarMarginHorizontal * 2;
    final available = width - margins;
    if (!Breakpoints.useConstrainedBottomBar(context)) {
      return available;
    }
    final cap = showEditorActions
        ? AppDimensions.floatingBottomNavEditorMaxWidth
        : AppDimensions.floatingBottomNavMaxWidth;
    return available < cap ? available : cap;
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    final bridge = StudioEditorShellBridge.instance;
    final router = GoRouter.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([bridge, router.routerDelegate]),
      builder: (context, _) {
        final showEditorActions = isStudioEditorRoute(router.state);
        final maxBarWidth =
            _shellBottomBarMaxWidth(context, showEditorActions);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.floatingBarMarginHorizontal,
            0,
            AppDimensions.floatingBarMarginHorizontal,
            AppDimensions.floatingBarMarginBottom,
          ),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBarWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AppBottomNavBar(
                        wrapPadding: false,
                        selectedIndex: _mobileSelectedIndex(),
                        onItemSelected: (index) {
                          _goToBranch(mobileNavItems[index].branchIndex!);
                        },
                      ),
                    ),
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
              Expanded(child: navigationShell),
            ],
          ),
        ),
      );
    }

    final bottomClearance = ShellInsets.mobileTabBarClearance(context);

    return Scaffold(
      extendBody: true,
      body: ShellInsets(
        bottomClearance: bottomClearance,
        child: navigationShell,
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
        const SizedBox(width: AppDimensions.spacingSm),
        StudioEditorSaveButton(
          visible: widget.visible,
          loading: widget.saveLoading,
          onPressed: widget.canSave ? widget.onSave : null,
        ),
      ],
    );
  }
}
