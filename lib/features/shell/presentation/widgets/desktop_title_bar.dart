import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/platform/platform_features.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

/// Desktop window chrome height — alias of [AppDimensions.titleBarHeight].
const double kDesktopTitleBarHeight = AppDimensions.titleBarHeight;

bool get _isMacOS =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

/// Full-width desktop window chrome: drag region + platform window controls.
///
/// Prefer [DesktopWindowChromeOverlay] for shell (does not push content).
/// Use this bar on stack pages without a sidebar.
///
/// macOS: traffic lights on the left. Windows/Linux: caption buttons on the right.
class DesktopWindowChromeBar extends StatelessWidget {
  const DesktopWindowChromeBar({
    super.key,
    this.height = AppDimensions.titleBarHeight,
    this.child,
  });

  final double height;

  /// Optional content drawn inside the drag region (e.g. page title).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (!shouldUseDesktopWindowChrome) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (_isMacOS)
              SizedBox(
                width: AppDimensions.macTitleBarLeadingInset,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: DesktopWindowControls(buttonHeight: height),
                ),
              ),
            Expanded(
              child: DesktopWindowDragRegion(
                child: child ?? const SizedBox.expand(),
              ),
            ),
            if (!_isMacOS) DesktopWindowControls(buttonHeight: height),
          ],
        ),
      ),
    );
  }
}

/// Overlay chrome that does **not** take layout space (no Column push).
///
/// - Windows/Linux: floating caption buttons top-right (+ small drag strip)
/// - macOS: optional top-left traffic lights (off in shell — lights live in sidebar logo)
class DesktopWindowChromeOverlay extends StatelessWidget {
  const DesktopWindowChromeOverlay({
    super.key,
    required this.child,
    this.showMacTrafficLights = true,
  });

  final Widget child;

  /// When false (shell), mac lights are omitted so [DesktopSidebarWindowHeader] owns them.
  final bool showMacTrafficLights;

  @override
  Widget build(BuildContext context) {
    if (!shouldUseDesktopWindowChrome) return child;

    if (_isMacOS) {
      if (!showMacTrafficLights) return child;
      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          const Positioned(
            top: 0,
            left: 0,
            child: DesktopWindowControls(),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 72,
                height: AppDimensions.titleBarHeight,
                child: const DesktopWindowDragRegion(
                  child: SizedBox.expand(),
                ),
              ),
              const DesktopWindowControls(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Wraps [child] with a layout chrome bar above (stack pages).
class DesktopWindowChromeScope extends StatelessWidget {
  const DesktopWindowChromeScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!shouldUseDesktopWindowChrome) return child;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DesktopWindowChromeBar(),
        Expanded(child: child),
      ],
    );
  }
}

/// macOS sidebar header: traffic lights + logo, both in a drag region.
class DesktopSidebarWindowHeader extends StatelessWidget {
  const DesktopSidebarWindowHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final logo = const Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Rc0Logo(),
    );

    if (!shouldUseDesktopWindowChrome || !_isMacOS) {
      return logo;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppDimensions.titleBarHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: DesktopWindowControls(
              buttonHeight: AppDimensions.titleBarHeight,
            ),
          ),
        ),
        DesktopWindowDragRegion(child: logo),
      ],
    );
  }
}

/// Global shortcuts: F11 (Win/Linux) / Control+Meta+F (mac) toggle fullscreen.
class DesktopWindowShortcuts extends StatelessWidget {
  const DesktopWindowShortcuts({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!shouldUseDesktopWindowChrome) return child;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        if (_isMacOS)
          const SingleActivator(
            LogicalKeyboardKey.keyF,
            control: true,
            meta: true,
          ): const _ToggleFullscreenIntent(),
        if (!_isMacOS)
          const SingleActivator(LogicalKeyboardKey.f11):
              const _ToggleFullscreenIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ToggleFullscreenIntent: CallbackAction<_ToggleFullscreenIntent>(
            onInvoke: (_) async {
              final full = await windowManager.isFullScreen();
              await windowManager.setFullScreen(!full);
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _ToggleFullscreenIntent extends Intent {
  const _ToggleFullscreenIntent();
}

class DesktopWindowDragRegion extends StatelessWidget {
  const DesktopWindowDragRegion({super.key, required this.child});

  final Widget child;

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: _toggleMaximize,
      child: DragToMoveArea(child: child),
    );
  }
}

/// Platform-adaptive window controls: mac traffic lights / Win·Linux caption buttons.
class DesktopWindowControls extends StatefulWidget {
  const DesktopWindowControls({
    super.key,
    this.buttonHeight = AppDimensions.titleBarHeight,
  });

  final double buttonHeight;

  @override
  State<DesktopWindowControls> createState() => _DesktopWindowControlsState();
}

class _DesktopWindowControlsState extends State<DesktopWindowControls>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((value) {
      if (mounted) setState(() => _isMaximized = value);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  Future<void> _toggleMaximize() async {
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isMacOS) {
      return Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MacWindowButton(
              color: AppColors.macWindowClose,
              onPressed: windowManager.close,
              tooltip: '关闭',
            ),
            const SizedBox(width: 8),
            _MacWindowButton(
              color: AppColors.macWindowMinimize,
              onPressed: windowManager.minimize,
              tooltip: '最小化',
            ),
            const SizedBox(width: 8),
            _MacWindowButton(
              color: AppColors.macWindowZoom,
              onPressed: _toggleMaximize,
              tooltip: _isMaximized ? '还原' : '最大化',
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowsWindowButton(
          height: widget.buttonHeight,
          icon: Icons.remove,
          tooltip: '最小化',
          onPressed: windowManager.minimize,
        ),
        _WindowsWindowButton(
          height: widget.buttonHeight,
          icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
          tooltip: _isMaximized ? '还原' : '最大化',
          onPressed: _toggleMaximize,
        ),
        _WindowsWindowButton(
          height: widget.buttonHeight,
          icon: Icons.close,
          tooltip: '关闭',
          hoverColor: AppColors.error,
          onPressed: windowManager.close,
        ),
      ],
    );
  }
}

@Deprecated('Use DesktopWindowChromeBar')
class DesktopMergedTitleBar extends StatelessWidget {
  const DesktopMergedTitleBar({
    super.key,
    required this.child,
    this.height = AppDimensions.titleBarHeight,
    this.decoration,
  });

  final Widget child;
  final double height;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return DesktopWindowChromeBar(height: height, child: child);
  }
}

@Deprecated('Use DesktopWindowChromeBar')
class DesktopMinimalTitleBar extends StatelessWidget {
  const DesktopMinimalTitleBar({super.key});

  static const double height = AppDimensions.titleBarHeight;

  @override
  Widget build(BuildContext context) {
    return const DesktopWindowChromeBar();
  }
}

class _MacWindowButton extends StatefulWidget {
  const _MacWindowButton({
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  final Color color;
  final Future<void> Function() onPressed;
  final String tooltip;

  @override
  State<_MacWindowButton> createState() => _MacWindowButtonState();
}

class _MacWindowButtonState extends State<_MacWindowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Semantics(
            button: true,
            label: widget.tooltip,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _hovering
                    ? widget.color.withValues(alpha: 0.85)
                    : widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowsWindowButton extends StatefulWidget {
  const _WindowsWindowButton({
    required this.height,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hoverColor,
  });

  final double height;
  final IconData icon;
  final String tooltip;
  final Future<void> Function() onPressed;
  final Color? hoverColor;

  @override
  State<_WindowsWindowButton> createState() => _WindowsWindowButtonState();
}

class _WindowsWindowButtonState extends State<_WindowsWindowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = widget.hoverColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Semantics(
          button: true,
          label: widget.tooltip,
          child: Container(
            width: 46,
            height: widget.height,
            color: _hovering
                ? (hoverColor ?? AppColors.background)
                : Colors.transparent,
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovering && hoverColor != null
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
