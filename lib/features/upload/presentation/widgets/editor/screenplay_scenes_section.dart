import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../scene/data/scene_repository.dart';
import '../../../../scene/domain/scene_entry.dart';
import '../../../../scene/presentation/widgets/scene_picker_sheet.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/data/screenplay_scene_binding.dart';
import '../../../../studio/domain/script_editor_selection.dart';
import '../script_editor/script_editor_actions.dart';

/// Screenplay-level scene roster for the script editor and project settings.
class ScreenplayScenesSection extends StatelessWidget {
  const ScreenplayScenesSection({
    super.key,
    required this.draft,
    required this.onChanged,
    this.selection,
    this.actions,
    this.compact = false,
  });

  final ScreenplayDraft draft;
  final VoidCallback onChanged;
  final ScriptEditorSelection? selection;
  final ScriptEditorActions? actions;
  final bool compact;

  Future<void> _addScene(BuildContext context) async {
    final picked = await ScenePickerSheet.show(context);
    if (!context.mounted || picked == null) return;
    _linkScene(picked);
    onChanged();
  }

  void _linkScene(SceneEntry entry) {
    ensureDraftSceneLinked(
      draft,
      id: entry.id,
      title: entry.title,
    );
  }

  void _removeScene(String id) {
    draft.linkedScenes.removeWhere((s) => s.id == id);
    onChanged();
  }

  Future<void> _applyToSelectedScene(SceneEntry entry) async {
    final sel = selection;
    final editorActions = actions;
    if (sel == null ||
        editorActions == null ||
        !sel.hasScene ||
        sel.actIndex == null ||
        sel.sceneIndex == null) {
      return;
    }
    final scene =
        editorActions.draft.acts[sel.actIndex!].scenes[sel.sceneIndex!];
    applyLibrarySceneToSceneDraft(entry, scene, draft);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final scenes = collectLinkedScenesFromDraft(draft);
    final canApplyToScene = selection?.hasScene == true && actions != null;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.characterCardDark
            : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('剧本场景', style: AppTextStyles.label),
              ),
              TextButton.icon(
                onPressed: () => _addScene(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加场景'),
              ),
            ],
          ),
          if (scenes.isEmpty)
            Text(
              '添加场景后可在场次中快速绑定拍摄地点',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in scenes)
                  InputChip(
                    label: Text(link.title),
                    avatar: const CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.accentLight,
                      child: Icon(
                        Icons.landscape_outlined,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ),
                    onPressed: canApplyToScene
                        ? () async {
                            final result =
                                await SceneRepository.instance.fetchDetail(
                              link.id,
                            );
                            final entry = result.scene;
                            if (entry != null) {
                              await _applyToSelectedScene(entry);
                            }
                          }
                        : () => context.push(AppRoutes.sceneDetailPath(link.id)),
                    onDeleted: draft.linkedScenes.any((s) => s.id == link.id)
                        ? () => _removeScene(link.id)
                        : null,
                  ),
              ],
            ),
          if (canApplyToScene) ...[
            const SizedBox(height: 8),
            Text(
              '点击场景可绑定到当前场次',
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 11,
                color: AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<SceneEntry?> pickAndLinkScreenplayScene(
  BuildContext context, {
  required ScreenplayDraft draft,
  String? selectedSceneId,
}) async {
  final picked = await ScenePickerSheet.show(
    context,
    selectedSceneId: selectedSceneId,
  );
  if (picked != null) {
    ensureDraftSceneLinked(draft, id: picked.id, title: picked.title);
  }
  return picked;
}
