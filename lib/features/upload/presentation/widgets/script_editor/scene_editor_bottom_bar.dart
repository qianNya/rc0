import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../shared/widgets/bottom_bar_glass_chrome.dart';
import 'script_editor_navigation.dart';

class SceneEditorBottomBar extends StatelessWidget {
  const SceneEditorBottomBar({
    super.key,
    required this.onBatchEdit,
    required this.onPreset,
    required this.onAiAssistant,
  });

  final VoidCallback onBatchEdit;
  final VoidCallback onPreset;
  final VoidCallback onAiAssistant;

  @override
  Widget build(BuildContext context) {
    return BottomBarGlassChrome(
      height: AppDimensions.bottomNavFloatingHeight,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BarItem(
              icon: Icons.checklist_outlined,
              label: '批量操作',
              onTap: onBatchEdit,
            ),
            _BarItem(
              icon: Icons.tune_outlined,
              label: '参数预设',
              onTap: onPreset,
            ),
            _BarItem(
              icon: Icons.auto_awesome_outlined,
              label: 'AI 助手',
              onTap: onAiAssistant,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      icon: Icon(icon, size: 22, color: AppColors.glassNavIconLight),
    );
  }
}

void showSceneAiAssistant(BuildContext context) {
  openAiCreationHub(context);
}
