import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../screenplay/data/screenplay_bundle_service.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../screenplay_editor_host.dart';

class ScriptStudioWorkspaceAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ScriptStudioWorkspaceAppBar({
    super.key,
    required this.controller,
    required this.onBatchEdit,
    required this.onOpenSettings,
    required this.onPreview,
    this.onShare,
  });

  final ScreenplayEditorController controller;
  final VoidCallback onBatchEdit;
  final VoidCallback onOpenSettings;
  final VoidCallback onPreview;
  final VoidCallback? onShare;

  String get _saveLabel {
    switch (controller.saveStatus) {
      case EditorSaveStatus.saving:
        return '保存中…';
      case EditorSaveStatus.saved:
        return _relativeSaveTime();
      case EditorSaveStatus.error:
        return '保存失败';
      case EditorSaveStatus.idle:
        return '自动保存';
    }
  }

  String _relativeSaveTime() {
    final saved = controller.lastSavedAt;
    if (saved == null) return '已保存';
    final diff = DateTime.now().difference(saved);
    if (diff.inSeconds < 60) return '${diff.inSeconds} 秒前保存';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前保存';
    return '已保存';
  }

  Future<void> _exportBundle(BuildContext context) async {
    final id = controller.editScriptId;
    if (id == null) {
      await controller.onSaveLocal(goHome: false);
      if (!context.mounted) return;
      final newId = controller.editScriptId;
      if (newId == null) return;
      await _exportById(context, newId);
      return;
    }
    await _exportById(context, id);
  }

  Future<void> _exportById(BuildContext context, String id) async {
    final doc = ScreenplayLocalRepository.instance.documentById(id);
    if (doc == null) return;
    final result = await ScreenplayBundleService.instance.exportToFile(doc);
    if (!context.mounted) return;
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    if (result.path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出: ${result.path}')),
      );
    }
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.batch_prediction_outlined),
              title: const Text('批量操作'),
              onTap: () {
                Navigator.pop(context);
                onBatchEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('项目设置'),
              onTap: () {
                Navigator.pop(context);
                onOpenSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.preview_outlined),
              title: const Text('预览'),
              onTap: () {
                Navigator.pop(context);
                onPreview();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('分享/导出'),
              onTap: () {
                Navigator.pop(context);
                _exportBundle(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final projects = ScreenplayLocalRepository.instance.localScreenplays;
    final isMobile = Breakpoints.isMobile(context);
    final title = controller.titleController.text.trim().isEmpty
        ? 'Script Studio'
        : controller.titleController.text.trim();
    final scriptId = controller.editScriptId ?? '';

    return AppBar(
      leading: TextButton(
        onPressed: controller.onCancel,
        child: Text(controller.isCreateMode ? '返回' : '取消'),
      ),
      leadingWidth: 72,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                Text(
                  'Script Studio',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 11,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: PopupMenuButton<String>(
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
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textSecondary,
                      ),
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
                    if (id != scriptId) {
                      context.go(AppRoutes.studioEdit(id));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '创作中',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '$_saveLabel · ${controller.hierarchySummary}',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: '撤销',
          onPressed: controller.canUndo ? controller.onUndo : null,
          icon: const Icon(Icons.undo),
        ),
        IconButton(
          tooltip: '重做',
          onPressed: controller.canRedo ? controller.onRedo : null,
          icon: const Icon(Icons.redo),
        ),
        if (!isMobile) ...[
          TextButton(onPressed: onBatchEdit, child: const Text('批量')),
          TextButton(onPressed: onOpenSettings, child: const Text('设置')),
          TextButton(onPressed: onPreview, child: const Text('预览')),
          TextButton(
            onPressed: () => _exportBundle(context),
            child: const Text('分享'),
          ),
        ] else
          IconButton(
            tooltip: '更多',
            onPressed: () => _showMoreSheet(context),
            icon: const Icon(Icons.more_vert),
          ),
        TextButton(
          onPressed: controller.isPublishing
              ? null
              : () => controller.onSaveLocal(goHome: false),
          child: const Text('保存'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilledButton(
            onPressed: controller.isPublishing
                ? null
                : controller.onPublishToCloud,
            child: Text(controller.isEditing ? '同步' : '发布'),
          ),
        ),
      ],
    );
  }
}
