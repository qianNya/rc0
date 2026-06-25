import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

class ShellBarIconButton extends StatelessWidget {
  const ShellBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: AppDimensions.shellBarHeight,
        minHeight: AppDimensions.shellBarHeight,
      ),
    );
  }
}
