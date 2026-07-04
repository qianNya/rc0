import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/rc0_page_scaffold.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_outline_tab.dart';
import '../screenplay_editor_host.dart';
import '../studio_editor_shell_bridge.dart';

/// 新建 / 编辑剧本 — 脚本工坊详情式 Hub（封面 / 工具栏 / 幕场大纲）。
class ScriptStudioCreatePage extends StatelessWidget {
  const ScriptStudioCreatePage({
    super.key,
    this.editScriptId,
    this.initialCharacterId,
    this.initialCharacterName,
    this.initialLightingSchemeId,
  });

  final String? editScriptId;
  final int? initialCharacterId;
  final String? initialCharacterName;
  final String? initialLightingSchemeId;

  bool get _isEditing =>
      editScriptId != null && editScriptId!.trim().isNotEmpty;

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.studio);
  }

  @override
  Widget build(BuildContext context) {
    StudioEditorShellBridge.instance.ensureEditorSession();

    return ScreenplayEditorHost(
      key: _isEditing ? ValueKey(editScriptId) : null,
      editScriptId: editScriptId,
      initialCharacterId: initialCharacterId,
      initialCharacterName: initialCharacterName,
      initialLightingSchemeId: initialLightingSchemeId,
      enableAutoSave: true,
      registerShellBridge: true,
      builder: (context, controller) {
        final actions = controller.buildEditorActions();
        final fallbackTitle = _isEditing ? '编辑剧本' : '新建剧本';

        return Rc0PageScaffold(
          body: ScriptEditorOutlineTab(
            draft: controller.draft,
            actions: actions,
            onAddAct: controller.addAct,
            onAddScene: controller.addScene,
            onRemoveAct: controller.removeAct,
            canRemoveAct: (_) => controller.canRemoveAct(),
            onReorderActs: controller.reorderActs,
            onMoveScene: controller.moveScene,
            structureEditor: controller.buildStructureMode(),
            editScriptId: controller.editScriptId,
            onOpenSettings: controller.openProjectSettings,
            hubLayout: true,
            hubFallbackTitle: fallbackTitle,
            titleListenable: controller.titleController,
            onBack: () => _onBack(context),
            scriptMenuItems: [
              for (final script
                  in ScreenplayLocalRepository.instance.localScreenplays)
                PopupMenuItem<String>(
                  value: script.id,
                  child: Text(
                    script.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onScriptSelected: (id) {
              if (id == controller.editScriptId) return;
              context.go(
                Uri(
                  path: AppRoutes.studioEditorCreate,
                  queryParameters: {'edit': id},
                ).toString(),
              );
            },
          ),
        );
      },
    );
  }
}
