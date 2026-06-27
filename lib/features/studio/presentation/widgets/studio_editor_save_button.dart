import 'package:flutter/material.dart';

import 'studio_editor_shell_glass_button.dart';

class StudioEditorSaveButton extends StatelessWidget {
  const StudioEditorSaveButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    this.visible = true,
    this.animationDelay = Duration.zero,
    this.exitDelay = const Duration(milliseconds: 70),
  });

  final VoidCallback? onPressed;
  final bool loading;
  final bool visible;
  final Duration animationDelay;
  final Duration exitDelay;

  @override
  Widget build(BuildContext context) {
    return StudioEditorShellGlassButton(
      onPressed: onPressed,
      icon: Icons.save_outlined,
      loading: loading,
      visible: visible,
      animationDelay: animationDelay,
      exitDelay: exitDelay,
      tooltip: '保存',
    );
  }
}
