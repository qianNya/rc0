import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import 'script_editor_navigation.dart';class SceneEditorBottomBar extends StatelessWidget {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
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
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppColors.textSecondary),
      label: Text(
        label,
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
      ),
    );
  }
}

void showSceneAiAssistant(BuildContext context) {
  openAiCreationHub(context);
}
