import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../shared/widgets/rc0_app_bar.dart';
import '../../../../screenplay/data/screenplay_local_repository.dart';

class ScriptEditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScriptEditorAppBar({
    super.key,
    required this.title,
    required this.currentScriptId,
    required this.onCancel,
    required this.onBatchEdit,
    required this.onSaveLocal,
    this.isSaving = false,
    this.onOpenSettings,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String currentScriptId;
  final VoidCallback onCancel;
  final VoidCallback onBatchEdit;
  final VoidCallback onSaveLocal;
  final bool isSaving;
  final VoidCallback? onOpenSettings;

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final projects = ScreenplayLocalRepository.instance.localScreenplays;
    final isMobile = Breakpoints.isMobile(context);

    return Rc0AppBar(
      toolbarHeight: subtitle != null ? 72 : kToolbarHeight,
      leading: TextButton(
        onPressed: onCancel,
        child: const Text('取消'),
      ),
      leadingWidth: 72,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String>(
            tooltip: '切换剧本',
            offset: const Offset(0, 40),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
            itemBuilder: (context) => [
              for (final script in projects)
                PopupMenuItem<String>(
                  value: script.id,
                  child: Text(
                    script.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onSelected: (id) {
              if (id != currentScriptId) {
                context.go(AppRoutes.studioEdit(id));
              }
            },
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        if (onOpenSettings != null)
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: '项目设置',
          ),
        if (!isMobile)
          TextButton(
            onPressed: onBatchEdit,
            child: const Text('批量编辑'),
          ),
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            if (isMobile)
              const PopupMenuItem(
                value: 'batch',
                child: Text('批量编辑'),
              ),
            PopupMenuItem(
              value: 'save',
              enabled: !isSaving,
              child: const Text('保存到本地'),
            ),
          ],
          onSelected: (value) {
            if (value == 'save') {
              onSaveLocal();
            } else if (value == 'batch') {
              onBatchEdit();
            }
          },
        ),
      ],
    );
  }
}
