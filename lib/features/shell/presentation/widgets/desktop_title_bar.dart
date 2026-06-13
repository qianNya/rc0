import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

class DesktopTitleBar extends StatefulWidget {
  const DesktopTitleBar({super.key});

  @override
  State<DesktopTitleBar> createState() => _DesktopTitleBarState();
}

class _DesktopTitleBarState extends State<DesktopTitleBar> with WindowListener {
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
    return Material(
      color: AppColors.surface,
      child: Container(
        height: 40,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Rc0Logo(fontSize: 18),
            ),
            Expanded(
              child: DragToMoveArea(
                child: const SizedBox.expand(),
              ),
            ),
            _WindowControlButton(
              icon: Icons.remove,
              tooltip: '最小化',
              onPressed: windowManager.minimize,
            ),
            _WindowControlButton(
              icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
              tooltip: _isMaximized ? '还原' : '最大化',
              onPressed: _toggleMaximize,
            ),
            _WindowControlButton(
              icon: Icons.close,
              tooltip: '关闭',
              hoverColor: AppColors.error,
              onPressed: windowManager.close,
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  const _WindowControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hoverColor,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onPressed;
  final Color? hoverColor;

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
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
            height: 40,
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
