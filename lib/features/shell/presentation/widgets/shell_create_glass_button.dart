import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_brand_icon.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';

/// Trailing glass capsule for the detached「创作」/ rc0 entry.
class ShellCreateGlassButton extends StatelessWidget {
  const ShellCreateGlassButton({
    super.key,
    required this.selected,
    required this.onPressed,
  });

  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return StudioEditorShellGlassButton(
      onPressed: onPressed,
      visible: true,
      tooltip: '创作',
      child: AppBrandIcon(
        size: AppDimensions.bottomNavBrandIconSize,
        selected: selected,
      ),
    );
  }
}
