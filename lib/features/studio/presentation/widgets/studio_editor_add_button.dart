import 'package:flutter/material.dart';

import 'studio_editor_shell_glass_button.dart';

class StudioEditorAddButton extends StatelessWidget {
  const StudioEditorAddButton({
    super.key,
    required this.onPressed,
    this.visible = true,
    this.animationDelay = const Duration(milliseconds: 70),
    this.exitDelay = Duration.zero,
  });

  final VoidCallback? onPressed;
  final bool visible;
  final Duration animationDelay;
  final Duration exitDelay;

  @override
  Widget build(BuildContext context) {
    return StudioEditorShellGlassButton(
      onPressed: onPressed,
      icon: Icons.add,
      visible: visible,
      animationDelay: animationDelay,
      exitDelay: exitDelay,
      tooltip: '添加幕 / 场',
    );
  }
}
