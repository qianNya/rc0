import 'package:flutter/material.dart';

import 'script_studio_theme.dart';

/// Clean white backdrop for Script Studio.
class ScriptStudioBackdrop extends StatelessWidget {
  const ScriptStudioBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: ScriptStudioColors.background);
  }
}
