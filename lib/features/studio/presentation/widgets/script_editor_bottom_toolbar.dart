import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/bottom_bar_glass_chrome.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../screenplay/data/screenplay_bundle_service.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_batch_edit_sheet.dart';
import '../screenplay_editor_host.dart';
import 'script_editor_center_panel.dart';

class ScriptEditorBottomToolbar extends StatelessWidget {
  const ScriptEditorBottomToolbar({
    super.key,
    required this.controller,
    required this.allRefs,
    required this.checkedRefs,
    required this.onCheckedRefsChanged,
    required this.onImportComplete,
  });

  final ScreenplayEditorController controller;
  final List<DraftFrameRef> allRefs;
  final Set<String> checkedRefs;
  final ValueChanged<Set<String>> onCheckedRefsChanged;
  final VoidCallback onImportComplete;

  bool get _allSelected =>
      allRefs.isNotEmpty && checkedRefs.length == allRefs.length;

  List<DraftFrameRef> get _checkedFrameRefs {
    return allRefs
        .where((r) => checkedRefs.contains(refKeyForFrame(r)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BottomBarGlassChrome(
      height: AppDimensions.bottomNavFloatingHeight + 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: _allSelected,
                tristate: true,
                onChanged: allRefs.isEmpty
                    ? null
                    : (v) {
                        if (v == true) {
                          onCheckedRefsChanged(
                            allRefs.map(refKeyForFrame).toSet(),
                          );
                        } else {
                          onCheckedRefsChanged({});
                        }
                      },
              ),
              Text(
                '全选 (${checkedRefs.length}/${allRefs.length})',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: checkedRefs.isEmpty
                    ? null
                    : () => ScriptEditorBatchEditSheet.show(
                          context,
                          draft: controller.draft,
                          scope: BatchEditScope.entireScript,
                          frameRefs: _checkedFrameRefs,
                          onApply: controller.onChanged,
                        ),
                child: const Text('批量参数'),
              ),
              TextButton(
                onPressed: checkedRefs.isEmpty
                    ? null
                    : () => ScriptEditorBatchEditSheet.show(
                          context,
                          draft: controller.draft,
                          scope: BatchEditScope.entireScript,
                          frameRefs: _checkedFrameRefs,
                          tagsOnly: true,
                          onApply: controller.onChanged,
                        ),
                child: const Text('批量标签'),
              ),
              TextButton(
                onPressed: checkedRefs.isEmpty ? null : () => _batchDelete(context),
                child: const Text(
                  '批量删除',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _importBundle(context),
                child: const Text('导入剧本'),
              ),
              TextButton(
                onPressed: () => _exportBundle(context),
                child: const Text('导出剧本'),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.labsFeature('version_history')),
                child: const Text('版本历史'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _batchDelete(BuildContext context) async {
    final confirmed = await showGlassDialog<bool>(
      context,
      child: GlassDialog(
        title: const Text('批量删除'),
        onClose: () => Navigator.pop(context, false),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ),
        child: Text('确定删除选中的 ${checkedRefs.length} 个分镜吗？'),
      ),
    );
    if (confirmed == true) {
      await controller.removeFrames(_checkedFrameRefs);
      onCheckedRefsChanged({});
    }
  }

  Future<void> _exportBundle(BuildContext context) async {
    final id = controller.editScriptId;
    if (id == null) return;
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

  Future<void> _importBundle(BuildContext context) async {
    final result = await ScreenplayBundleService.instance.importFromFile();
    if (result.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    if (result.document != null) {
      await ScreenplayLocalRepository.instance
          .importDocument(result.document!);
      onImportComplete();
      if (context.mounted) {
        context.go(AppRoutes.studioEdit(result.document!.meta.localId));
      }
    }
  }
}
