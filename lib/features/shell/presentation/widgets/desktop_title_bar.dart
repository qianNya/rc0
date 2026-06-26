import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../app/theme/app_colors.dart';

/// 桌面自定义标题栏高度（探索页顶栏与窗口控件共用）。
const double kDesktopTitleBarHeight = 52;

/// 平台自适应窗口控件：macOS 居左交通灯，Windows/Linux 居右图标按钮。
class DesktopWindowControls extends StatefulWidget {
  const DesktopWindowControls({super.key, this.buttonHeight = kDesktopTitleBarHeight});

  final double buttonHeight;

  @override
  State<DesktopWindowControls> createState() => _DesktopWindowControlsState();
}

class _DesktopWindowControlsState extends State<DesktopWindowControls>
    with WindowListener {
  bool _isMaximized = false;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

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
              color: const Color(0xFFFF5F57),
              onPressed: windowManager.close,
              tooltip: '关闭',
            ),
            const SizedBox(width: 8),
            _MacWindowButton(
              color: const Color(0xFFFEBC2E),
              onPressed: windowManager.minimize,
              tooltip: '最小化',
            ),
            const SizedBox(width: 8),
            _MacWindowButton(
              color: const Color(0xFF28C840),
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

/// 将页面内容与系统窗口控件合并为单行顶栏（Windows 控件在右侧）。
class DesktopMergedTitleBar extends StatelessWidget {
  const DesktopMergedTitleBar({
    super.key,
    required this.child,
    this.height = kDesktopTitleBarHeight,
    this.decoration,
  });

  final Widget child;
  final double height;
  final BoxDecoration? decoration;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        decoration: decoration ??
            const BoxDecoration(
              color: AppColors.surface,
            ),
        child: Row(
          children: [
            Expanded(
              child: DragToMoveArea(child: child),
            ),
            if (!_isMacOS) DesktopWindowControls(buttonHeight: height),
          ],
        ),
      ),
    );
  }
}

/// 非探索页使用的极简顶栏：仅拖拽区 + 窗口控件。
class DesktopMinimalTitleBar extends StatelessWidget {
  const DesktopMinimalTitleBar({super.key});

  static const double height = 40;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (_isMacOS) const DesktopWindowControls(buttonHeight: height),
            Expanded(
              child: DragToMoveArea(
                child: const SizedBox.expand(),
              ),
            ),
            if (!_isMacOS) const DesktopWindowControls(buttonHeight: height),
          ],
        ),
      ),
    );
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
                color: _hovering ? widget.color.withValues(alpha: 0.85) : widget.color,
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
