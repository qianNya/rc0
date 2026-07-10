import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../shared/widgets/glass/glass.dart';

class EditorFooterActions extends StatelessWidget {
  const EditorFooterActions({
    super.key,
    required this.onSave,
    this.onDelete,
    this.saveLabel = '保存',
    this.isSaving = false,
  });

  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final String saveLabel;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: GlassButton(
                filled: true,
                expand: true,
                label: saveLabel,
                onPressed: isSaving ? null : onSave,
                loading: isSaving,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: '删除',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
